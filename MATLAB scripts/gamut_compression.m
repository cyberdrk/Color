function xm = gamut_compression(D, d, x, alpha) 

da = alpha * d; 

Dd = D - d; 

xm = x - Dd .* ( x - da ) ./ (D - da); 

end 