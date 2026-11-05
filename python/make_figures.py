"""Regenerate the README figures in docs/figures from the test images.

    python make_figures.py
"""

from __future__ import annotations

from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
from matplotlib.path import Path as MplPath
from PIL import Image

from gamut_expansion import BT709, BT2020, WHITE_POINT, XYZ_TO_SRGB, expand, linear_to_srgb

ROOT = Path(__file__).resolve().parent.parent
IMAGES = ROOT / "images" / "test"
OUT = ROOT / "docs" / "figures"

# CIE 1931 2° spectral locus, 380–700 nm in 5 nm steps
LOCUS = np.array([
    [0.1741, 0.005], [0.174, 0.005], [0.1738, 0.0049], [0.1736, 0.0049], [0.1733, 0.0048],
    [0.173, 0.0048], [0.1726, 0.0048], [0.1721, 0.0048], [0.1714, 0.0051], [0.1703, 0.0058],
    [0.1689, 0.0069], [0.1669, 0.0086], [0.1644, 0.0109], [0.1611, 0.0138], [0.1566, 0.0177],
    [0.151, 0.0227], [0.144, 0.0297], [0.1355, 0.0399], [0.1241, 0.0578], [0.1096, 0.0868],
    [0.0913, 0.1327], [0.0687, 0.2007], [0.0454, 0.295], [0.0235, 0.4127], [0.0082, 0.5384],
    [0.0039, 0.6548], [0.0139, 0.7502], [0.0389, 0.812], [0.0743, 0.8338], [0.1142, 0.8262],
    [0.1547, 0.8059], [0.1929, 0.7816], [0.2296, 0.7543], [0.2658, 0.7243], [0.3016, 0.6923],
    [0.3373, 0.6589], [0.3731, 0.6245], [0.4087, 0.5896], [0.4441, 0.5547], [0.4788, 0.5202],
    [0.5125, 0.4866], [0.5448, 0.4544], [0.5752, 0.4242], [0.6029, 0.3965], [0.627, 0.3725],
    [0.6482, 0.3514], [0.6658, 0.334], [0.6801, 0.3197], [0.6915, 0.3083], [0.7006, 0.2993],
    [0.7079, 0.292], [0.714, 0.2859], [0.719, 0.2809], [0.723, 0.277], [0.726, 0.274],
    [0.7283, 0.2717], [0.73, 0.27], [0.7311, 0.2689], [0.732, 0.268], [0.7327, 0.2673],
    [0.7334, 0.2666], [0.734, 0.266], [0.7344, 0.2656], [0.7346, 0.2654], [0.7347, 0.2653],
])

NAVY = "#0b2e59"
HD_COLOR = "#e0b400"
BETA_COLOR = "#00a6c7"
ALPHA_COLOR = "#e0402f"
plt.rcParams.update({"font.family": "DejaVu Sans", "font.size": 10, "axes.edgecolor": "#888"})


def load(name: str) -> np.ndarray:
    return np.asarray(Image.open(IMAGES / f"{name}.jpg").convert("RGB"))


def chromaticity_background(ax, res: int = 400) -> None:
    xs = np.linspace(0, 0.8, res)
    ys = np.linspace(0, 0.9, res)
    gx, gy = np.meshgrid(xs, ys)
    x, y = gx.ravel(), gy.ravel()
    Y = 1.0
    X = x * Y / np.maximum(y, 1e-6)
    Z = (1 - x - y) * Y / np.maximum(y, 1e-6)
    rgb = np.column_stack([X, Y * np.ones_like(x), Z]) @ XYZ_TO_SRGB.T
    rgb = np.clip(rgb, 0, None)
    rgb = rgb / np.maximum(rgb.max(axis=1, keepdims=True), 1e-6)
    rgb = linear_to_srgb(rgb)
    inside = MplPath(np.vstack([LOCUS, LOCUS[:1]])).contains_points(np.column_stack([x, y]))
    img = np.ones((len(x), 4))
    img[:, :3] = rgb
    img[~inside, 3] = 0
    ax.imshow(img.reshape(res, res, 4), origin="lower", extent=(0, 0.8, 0, 0.9), interpolation="bilinear")
    ax.plot(*np.vstack([LOCUS, LOCUS[:1]]).T, color="#555", lw=0.8)


def triangle(ax, tri, color, label, lw=1.8, ls="-"):
    t = np.vstack([tri, tri[:1]])
    ax.plot(t[:, 0], t[:, 1], color=color, lw=lw, ls=ls, label=label)


def scaled(tri, k):
    return WHITE_POINT + k * (tri - WHITE_POINT)


def diagram(ax, rgb, alpha, beta, title):
    r = expand(rgb, alpha, beta)
    chromaticity_background(ax)
    rng = np.random.default_rng(0)
    idx = rng.choice(len(r.xy_before), size=min(6000, len(r.xy_before)), replace=False)
    ax.scatter(*r.xy_before[idx].T, s=2, c="black", alpha=0.45, lw=0, label="pixels before")
    ax.scatter(*r.xy_after[idx].T, s=2, c="#1f4fff", alpha=0.45, lw=0, label="pixels after")
    triangle(ax, BT2020, NAVY, "UHD (BT.2020)")
    triangle(ax, BT709, HD_COLOR, "HD (BT.709)")
    if beta > 0:
        triangle(ax, scaled(BT709, 1 - beta), BETA_COLOR, f"β·HD (β = {beta})")
    triangle(ax, scaled(BT709, alpha * (1 - beta)), ALPHA_COLOR, f"inner gamut (α = {alpha})", ls="--")
    ax.plot(*WHITE_POINT, marker="x", color="black", ms=9, mew=2)
    ax.set_xlim(0, 0.8)
    ax.set_ylim(0, 0.9)
    ax.set_aspect("equal")
    ax.set_xlabel("x")
    ax.set_ylabel("y")
    ax.set_title(f"{title}\nsaturation +{r.saturation_gain:.0%}, UHD gamut in use "
                 f"{r.usage_before:.0%} → {r.usage_after:.0%}", fontsize=10, color=NAVY)
    leg = ax.legend(loc="upper right", fontsize=7, framealpha=0.9, markerscale=6)
    for h in leg.legend_handles:
        h.set_alpha(1)


def fig_diagrams():
    rgb = load("portrait")
    fig, axes = plt.subplots(1, 2, figsize=(11, 5.6), dpi=130)
    diagram(axes[0], rgb, 0.3, 0.0, "Original method (Azimi et al., 2017): α = 0.3")
    diagram(axes[1], rgb, 0.3, 0.3, "With β·HD reference gamut: α = 0.3, β = 0.3")
    fig.tight_layout()
    fig.savefig(OUT / "chromaticity_comparison.png", bbox_inches="tight")
    plt.close(fig)


def fig_results():
    names = ["portrait", "motocross", "ski"]
    settings = [(None, None, "Original"), (0.3, 0.0, "Paper method\nα = 0.3"), (0.3, 0.3, "With β\nα = 0.3, β = 0.3")]
    fig, axes = plt.subplots(len(names), 3, figsize=(9, 11.5), dpi=90)
    for i, name in enumerate(names):
        rgb = load(name)
        for j, (a, b, label) in enumerate(settings):
            ax = axes[i, j]
            if a is None:
                ax.imshow(rgb)
                caption = label
            else:
                r = expand(rgb, a, b)
                ax.imshow(r.rgb)
                caption = f"{label}\nsaturation +{r.saturation_gain:.0%}"
            ax.set_xticks([])
            ax.set_yticks([])
            if i == 0 or a is not None:
                ax.set_title(caption, fontsize=9, color=NAVY)
    fig.tight_layout()
    fig.savefig(OUT / "results_grid.jpg", bbox_inches="tight", pil_kwargs={"quality": 88})
    plt.close(fig)


def fig_alpha_sweep():
    rgb = load("portrait")
    alphas = np.round(np.arange(0.0, 0.95, 0.05), 2)
    fig, ax = plt.subplots(figsize=(7.5, 4.2), dpi=130)
    for beta, color in [(0.0, "#888888"), (0.2, BETA_COLOR), (0.4, NAVY)]:
        gains = [expand(rgb, a, beta).saturation_gain * 100 for a in alphas]
        label = "β = 0 (paper)" if beta == 0 else f"β = {beta}"
        ax.plot(alphas, gains, marker="o", ms=3.5, lw=2, color=color, label=label)
    ax.set_xlabel("α (inner gamut scale)")
    ax.set_ylabel("mean saturation gain (%)")
    ax.set_title("Portrait: how much colour each α adds, with and without β", color=NAVY)
    ax.grid(alpha=0.3)
    ax.legend()
    ax.spines[["top", "right"]].set_visible(False)
    fig.tight_layout()
    fig.savefig(OUT / "alpha_sweep.png", bbox_inches="tight")
    plt.close(fig)


if __name__ == "__main__":
    OUT.mkdir(parents=True, exist_ok=True)
    fig_diagrams()
    fig_results()
    fig_alpha_sweep()
    print("figures written to", OUT)
