function [flag, xr, yr] = ratio_longline(x, y) 

% defining White Point Illuminant D65 
TWPx = 0.3127; 
TWPy = 0.3290; 

% slope = get_slope(x, y, TWPx, TWPy); 

x0 = TWPx; 
y0 = TWPy; 

r = 20; 

flag = "lol no flag"; 

xr = ((1 - r) * x0) + (r * x); 
yr = ((1 - r) * y0) + (r * y); 
end 
