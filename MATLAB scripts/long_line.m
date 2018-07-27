function [long1, long0] = long_line(x, y) 

% defining White Point Illuminant D65 
TWPx = 0.3127 
TWPy = 0.3290

slope = get_slope(x, y, TWPx, TWPy); 

long1 = TWPy + slope * ( 1 - TWPx ) 

long0 = TWPy + slope * ( -1 - TWPy )

end 

