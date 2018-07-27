function [flag, xl, yl] = nearest_longline(x, y) 

% defining White Point Illuminant D65 
TWPx = 0.3127 
TWPy = 0.3290

slope = get_slope(x, y, TWPx, TWPy); 

long1 = TWPy + slope * ( 1 - TWPy ) 

long0 = TWPy + slope * ( -1 - TWPy )

flag = 2 

xl = 1 
yl = long1

if ((abs(x - 1)) < (abs(x + 1)))
    xl = 1
    yl = long1 
    flag = 1 
else
    x1 = - 1
    yl = long0 
    flag = - 1 
end

end 
