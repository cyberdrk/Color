"""HD → UHD colour gamut expansion with an adaptive reference gamut (α, β).

Python reference implementation of the MATLAB research code in `MATLAB scripts/`.

Problem
-------
A UHD display can show BT.2020 colours, but most content is mastered for the
smaller BT.709 (HD) gamut, so the extra colours the panel can show go unused.
Gamut expansion pushes each pixel's chromaticity outward along the line from
the white point (Towards White Point, TWP), so the content fills more of the
display's gamut without changing hue or luminance.

Method
------
Azimi et al. (IEEE ICC 2017) expand every colour that lies outside an inner
gamut, the HD gamut scaled towards the white point by α:

    x = x_m + (D − d) · (x_m − d_α) / (d − d_α)      for x_m > d_α
    x = x_m                                           otherwise

    x_m  distance of the pixel's chromaticity from the white point
    D    distance from the white point to the UHD (BT.2020) border, along the same line
    d    distance from the white point to the HD (BT.709) border, along the same line
    d_α  α · d

Contribution (Imaging Systems Lab, Changwon National University, 2018)
--------------------------------------------------------------------
Most real images occupy only a small region around the white point, far from
the HD border. Their colours barely move, and many α values do nothing at all.
A second factor β shrinks the reference HD gamut towards the white point, so it
fits the image's own colours more tightly, and every calculation uses this
β·HD gamut in place of HD:

    d_β = (1 − β) · d        d_α = α · d_β

β = 0 reproduces the original method. Larger β expands small-gamut images more
strongly and more evenly.

The mapping is done in CIE 1931 xy chromaticity with luminance Y preserved,
exactly as in the MATLAB pipeline (`readRGB.m` → `validPointEA.m` /
`validbEAoriginal.m` → `createRGB.m`).

Usage
-----
    python gamut_expansion.py input.png output.png --alpha 0.3 --beta 0.3
"""

from __future__ import annotations

import argparse
from dataclasses import dataclass

import numpy as np
from PIL import Image

# --- Colorimetry -------------------------------------------------------------

WHITE_POINT = np.array([0.3127, 0.3290])  # CIE Illuminant D65

# Primaries as (x, y) for red, green, blue.
BT709 = np.array([[0.640, 0.330], [0.300, 0.600], [0.150, 0.060]])  # HD
BT2020 = np.array([[0.708, 0.292], [0.170, 0.797], [0.131, 0.046]])  # UHD

# sRGB (BT.709 primaries, D65) <-> CIE XYZ
SRGB_TO_XYZ = np.array(
    [
        [0.4124564, 0.3575761, 0.1804375],
        [0.2126729, 0.7151522, 0.0721750],
        [0.0193339, 0.1191920, 0.9503041],
    ]
)
XYZ_TO_SRGB = np.linalg.inv(SRGB_TO_XYZ)


def srgb_to_linear(c: np.ndarray) -> np.ndarray:
    return np.where(c <= 0.04045, c / 12.92, ((c + 0.055) / 1.055) ** 2.4)


def linear_to_srgb(c: np.ndarray) -> np.ndarray:
    c = np.clip(c, 0.0, 1.0)
    return np.where(c <= 0.0031308, 12.92 * c, 1.055 * c ** (1 / 2.4) - 0.055)


# --- Geometry ----------------------------------------------------------------


def ray_exit_distance(directions: np.ndarray, triangle: np.ndarray) -> np.ndarray:
    """Distance from the white point to the triangle border along each unit direction.

    The white point lies inside both gamuts, so every ray leaves through exactly one edge.
    """
    best = np.full(len(directions), np.inf)
    w = WHITE_POINT
    for i in range(3):
        a, b = triangle[i], triangle[(i + 1) % 3]
        e = b - a
        aw = a - w
        denom = directions[:, 0] * e[1] - directions[:, 1] * e[0]
        with np.errstate(divide="ignore", invalid="ignore"):
            t = (aw[0] * e[1] - aw[1] * e[0]) / denom
            s = (aw[0] * directions[:, 1] - aw[1] * directions[:, 0]) / denom
        ok = (np.abs(denom) > 1e-12) & (t > 0) & (s >= -1e-9) & (s <= 1 + 1e-9)
        best = np.where(ok & (t < best), t, best)
    return best


GRID = 0.01  # chromaticity cell size used to measure how much of a gamut is in use


def _inside_triangle(p: np.ndarray, tri: np.ndarray) -> np.ndarray:
    def side(a, b):
        return (b[0] - a[0]) * (p[:, 1] - a[1]) - (b[1] - a[1]) * (p[:, 0] - a[0])

    s1, s2, s3 = side(tri[0], tri[1]), side(tri[1], tri[2]), side(tri[2], tri[0])
    return ((s1 >= 0) & (s2 >= 0) & (s3 >= 0)) | ((s1 <= 0) & (s2 <= 0) & (s3 <= 0))


def _uhd_cells() -> set:
    xs = np.arange(0, 0.8, GRID) + GRID / 2
    gx, gy = np.meshgrid(xs, xs)
    centers = np.column_stack([gx.ravel(), gy.ravel()])
    inside = centers[_inside_triangle(centers, BT2020)]
    return set(map(tuple, np.floor(inside / GRID).astype(int)))


UHD_CELLS = _uhd_cells()


def gamut_usage(xy: np.ndarray) -> float:
    """Share of the UHD gamut's 0.01×0.01 chromaticity cells that contain at least one pixel."""
    cells = set(map(tuple, np.floor(xy / GRID).astype(int)))
    return len(cells & UHD_CELLS) / len(UHD_CELLS)


# --- Expansion ---------------------------------------------------------------


@dataclass
class Result:
    rgb: np.ndarray  # expanded image, sRGB uint8 (colours beyond sRGB are clipped)
    xy_before: np.ndarray  # chromaticities of reliable pixels, before
    xy_after: np.ndarray  # chromaticities of the same pixels, after
    expanded_fraction: float  # share of pixels that moved
    saturation_gain: float  # mean distance from the white point, after / before − 1
    usage_before: float  # share of the UHD gamut's colour cells in use, before
    usage_after: float


def expand(rgb: np.ndarray, alpha: float, beta: float = 0.0, min_luminance: float = 0.01) -> Result:
    """Expand an 8-bit sRGB image from the HD gamut towards the UHD gamut.

    alpha: inner-gamut scale in [0, 1). Colours inside α·(β·HD) are left alone;
           smaller α expands more colours.
    beta:  shrink of the reference HD gamut in [0, 1). 0 = original method.
    """
    if not (0 <= alpha < 1 and 0 <= beta < 1):
        raise ValueError("alpha and beta must be in [0, 1)")

    h, w, _ = rgb.shape
    lin = srgb_to_linear(rgb.reshape(-1, 3).astype(np.float64) / 255.0)
    xyz = lin @ SRGB_TO_XYZ.T
    total = xyz.sum(axis=1)
    Y = xyz[:, 1]

    valid = total > 1e-9
    xy = np.zeros((len(xyz), 2))
    xy[valid] = xyz[valid, :2] / total[valid, None]

    offset = xy - WHITE_POINT
    xm = np.linalg.norm(offset, axis=1)
    chromatic = valid & (xm > 1e-6)

    u = np.zeros_like(offset)
    u[chromatic] = offset[chromatic] / xm[chromatic, None]

    D = np.zeros(len(xy))
    d = np.zeros(len(xy))
    D[chromatic] = ray_exit_distance(u[chromatic], BT2020)
    d[chromatic] = ray_exit_distance(u[chromatic], BT709)

    d_beta = (1 - beta) * d
    d_alpha = alpha * d_beta

    move = chromatic & (xm > d_alpha)
    x_new = xm.copy()
    x_new[move] = xm[move] + (D[move] - d_beta[move]) * (xm[move] - d_alpha[move]) / (
        d_beta[move] - d_alpha[move]
    )
    # Colours already beyond the β·HD border would land outside UHD: stop at the UHD border.
    x_new = np.minimum(x_new, np.where(chromatic, D, x_new))

    xy_new = xy.copy()
    xy_new[chromatic] = WHITE_POINT + u[chromatic] * x_new[chromatic, None]

    # Rebuild XYZ with the original luminance (createRGB.m), then back to sRGB.
    out_xyz = xyz.copy()
    yv = xy_new[chromatic, 1]
    out_xyz[chromatic, 0] = xy_new[chromatic, 0] * Y[chromatic] / yv
    out_xyz[chromatic, 2] = (1 - xy_new[chromatic, 0] - yv) * Y[chromatic] / yv
    out = linear_to_srgb(out_xyz @ XYZ_TO_SRGB.T)
    out_rgb = np.round(out * 255).astype(np.uint8).reshape(h, w, 3)

    reliable = chromatic & (Y > min_luminance)
    before, after = xy[reliable], xy_new[reliable]
    return Result(
        rgb=out_rgb,
        xy_before=before,
        xy_after=after,
        expanded_fraction=float(move[reliable].mean()) if reliable.any() else 0.0,
        saturation_gain=float(x_new[reliable].mean() / xm[reliable].mean() - 1) if reliable.any() else 0.0,
        usage_before=gamut_usage(before),
        usage_after=gamut_usage(after),
    )


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    parser.add_argument("input")
    parser.add_argument("output")
    parser.add_argument("--alpha", type=float, default=0.3, help="inner-gamut scale, 0–1 (default 0.3)")
    parser.add_argument("--beta", type=float, default=0.0, help="reference-gamut shrink, 0–1 (default 0 = paper)")
    args = parser.parse_args()

    rgb = np.asarray(Image.open(args.input).convert("RGB"))
    r = expand(rgb, args.alpha, args.beta)
    Image.fromarray(r.rgb).save(args.output)
    print(
        f"alpha={args.alpha} beta={args.beta}  "
        f"pixels expanded {r.expanded_fraction:.1%}  "
        f"saturation +{r.saturation_gain:.1%}  "
        f"UHD gamut in use {r.usage_before:.1%} → {r.usage_after:.1%}"
    )


if __name__ == "__main__":
    main()
