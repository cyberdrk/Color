function x = gamut_expansion(D, d, xm, alpha) 

da = alpha * d; 

Dd = D - d; 

x = xm + (Dd .* ((xm - da ) ./ (d - da))); 

end 