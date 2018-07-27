% plotting the CIE 1931 XY Chromaticity diagram 
figure 
plotChromaticity 
hold on % hold on figure, there's more to come 


TWPx = 0.3127; 
TWPy = 0.3290; 


xhd = [0.64, 0.30, 0.15, 0.64]; 
yhd = [0.33, 0.60, 0.06, 0.33]; 

xuhd = [0.708, 0.170, 0.131, 0.708]; 
yuhd = [0.292, 0.797, 0.046, 0.292]; 

alpha = 0.3; 
    
xhds = xhd - TWPx; 
yhds = yhd - TWPy; 

xahd = round(xhd - alpha * xhds, 2); 
yahd = round(yhd - alpha * yhds, 2); 


% xahd(1)
line([xahd(1), xahd(2)], [yahd(1), yahd(2)], 'Color', 'red', 'LineWidth', 2) 
line([xahd(2), xahd(3)], [yahd(2), yahd(3)], 'Color', 'red', 'LineWidth', 2) 
line([xahd(3), xahd(1)], [yahd(3), yahd(1)], 'Color', 'red', 'LineWidth', 2) 


% plotting the TWP projection lines for HD 

% plot([0.64, 0.3127], [0.33, 0.3290], 'Color', 'white') 
% plot([0.30, 0.3127], [0.60, 0.3290], 'Color', 'white') 
% plot([0.15, 0.3127], [0.06, 0.3290], 'Color', 'white') 

hold on 

% CIE Locus X-Coordinates 
xq = [0.175596 0.172787 0.170806 0.170085 0.160343 0.146958 0.139149 ...
      0.133536 0.126688 0.115830 0.109616 0.099146 0.091310 0.078130 ...
      0.068717 0.054675 0.040763 0.027497 0.016270 0.008169 0.004876 ...
      0.003983 0.003859 0.004646 0.007988 0.013870 0.022244 0.027273 ...
      0.032820 0.038851 0.045327 0.052175 0.059323 0.066713 0.074299 ...
      0.089937 0.114155 0.138695 0.154714 0.192865 0.229607 0.265760 ...
      0.301588 0.337346 0.373083 0.408717 0.444043 0.478755 0.512467 ...
      0.544767 0.575132 0.602914 0.627018 0.648215 0.665746 0.680061 ...
      0.691487 0.700589 0.707901 0.714015 0.719017 0.723016 0.734674 ] 

% CIE Locus Y-Coordinates 
yq = [0.005295 0.004800 0.005472 0.005976 0.014496 0.026643 0.035211 ...
      0.042704 0.053441 0.073601 0.086866 0.112037 0.132737 0.170464 ... 
      0.200773 0.254155 0.317049 0.387997 0.463035 0.538504 0.587196 ...
      0.610526 0.654897 0.675970 0.715407 0.750246 0.779682 0.792153 ...
      0.802971 0.812059 0.819430 0.825200 0.829460 0.832306 0.833833 ...
      0.833316 0.826231 0.814796 0.805884 0.781648 0.754347 0.724342 ...
      0.692326 0.658867 0.624470 0.589626 0.554734 0.520222 0.486611 ...
      0.454454 0.424252 0.396516 0.372510 0.351413 0.334028 0.319765 ...
      0.308359 0.299317 0.292044 0.285945 0.280951 0.276964 0.265326 ] 
 
plot(xq, yq, 'kp') 
hold on 

% Logical Matrix 
[in,on] = inpolygon(xq,yq, xuhd,yuhd); 

inon = in | on;                                             % Combine ‘in’ And ‘on’
idx = find(inon(:));                                        % Linear Indices Of ‘inon’ Points
xcoord = xq(idx);                                           % X-Coordinates Of ‘inon’ Points
ycoord = yq(idx);                                           % Y-Coordinates Of ‘inon’ Points
 
plot(xcoord, ycoord, 'bp')                                  % Overplot ‘inon’ Points 
hold on 

% points within the smaller gamut 
[in,on] = inpolygon(xcoord,ycoord, xahd,yahd); 

inon = in | on;                                             % Combine ‘in’ And ‘on’ 
idx = find(inon(:));                                        % Linear Indices Of ‘inon’ Points 
xacoord = xcoord(idx);                                           % X-Coordinates Of ‘inon’ Points 
yacoord = ycoord(idx);                                           % Y-Coordinates Of ‘inon’ Points 
 
plot(xacoord, yacoord, 'gp')                                  % Overplot ‘inon’ Points 

% points outside the smaller gamut but inside the UHD gamut 
validpoint = inpolygon(xq, yq, xuhd, yuhd) & (~inpolygon(xq, yq, xahd, yahd)); 
idx = find(validpoint(:));                                        % Linear Indices Of ‘validpoint’ Points 
xvald = xq(idx);                                           % X-Coordinates Of ‘validpoint’ Points 
yvald = yq(idx);                                           % Y-Coordinates Of ‘validpoint’ Points 

plot(xvald, yvald, 'bp')                                  % Overplot ‘inon’ Points 

% plotting the Illuminant D65, popularly known as the White Point 
plot(0.3127, 0.3290, 'x', 'MarkerEdgeColor','white', 'MarkerSize', 25, 'LineWidth', 1)
hold on 

% plotting the ITU-R Recommendation BT.709 
% The format of High Definition Television 
% plotted in yellow 

line([0.64, 0.30], [0.33, 0.60], 'Color', 'yellow', 'LineWidth', 2) 
line([0.30, 0.15], [0.60, 0.06], 'Color', 'yellow', 'LineWidth', 2) 
line([0.15, 0.64], [0.06, 0.33], 'Color', 'yellow', 'LineWidth', 2) 


% plotting the ITU-R Recommendation BT.2020 
% The format of Ultra High Definition Television 
% plotted in black 

line([0.708, 0.170], [0.292, 0.797], 'Color', 'black', 'LineWidth', 2) 
line([0.170, 0.131], [0.797, 0.046], 'Color', 'black', 'LineWidth', 2) 
line([0.131, 0.708], [0.046, 0.292], 'Color', 'black', 'LineWidth', 2) 


% plotting the TWP projection lines for UHD 

% line([0.708, 0.3127], [0.292, 0.3290], 'Color', 'white', 'LineWidth', 2) 
% line([0.170, 0.3127], [0.797, 0.3290], 'Color', 'white', 'LineWidth', 2) 
% line([0.131, 0.3127], [0.046, 0.3290], 'Color', 'white', 'LineWidth', 2) 


% point wise distance calculator 

% x = [0.219, TWPx] 
% y = [0.6254, TWPy] 


% extrapolating line on the UHD and HD gamut along the TWP from the point 

% [xi,yi] = polyxpoly(xhd, yhd, x, y) 
hold on 
scatter(xvald, yvald,'Marker', 'x', 'MarkerEdgeColor', 'k', 'LineWidth', 2)  


% acquiring extrapolated point's coordinates 

[flag, xr, yr] = ratio_longline(xvald, yvald) 

scatter(xr, yr, 'Marker', 's', 'MarkerFaceColor', 'y', 'LineWidth', 2) 

disp(flag) 



% plotting a dotted long line that intersects the HD and UHD gamuts 

lxr = length(xr)
D = [] 
d = [] 


for i = 1:lxr

    % creating long line's coordinates by clubbing them together 

    xlong = [xr(i), TWPx] 
    ylong = [yr(i), TWPy] 

    line(xlong, ylong, 'LineStyle', '--', 'Color', 'yellow', 'LineWidth', 2) 
    % plot(xr, yr, TWPx, TWPy, 'LineStyle', '--', 'Color', 'yellow', 'LineWidth', 2) 
    
    % acquiring the intersection of the long line with the UHD gamut 

    [xD, yD] = polyxpoly(xuhd, yuhd, xlong, ylong) 
    plot(xD, yD, 'Marker', 'o', 'Color', 'white', 'LineWidth', 2) 


    % acquiring the intersection of the long line with the HD gamut 

    [xd, yd] = polyxpoly(xhd, yhd, xlong, ylong) 
    plot(xd, yd, 'Marker','o', 'Color', 'white', 'LineWidth', 2) 

    % line([x(1), xi], [y(1), yi], 'Color', 'white', 'LineWidth', 2) 
    
    D = [D, calc_distance(xD, yD, TWPx, TWPy)]; 
    d = [d, calc_distance(xd, yd, TWPx, TWPy)]; 
end 

xdist = calc_distance(xvald, yvald, TWPx, TWPy); 

xm = gamut_compression(D, d, xdist, alpha); 

cr = xm ./ xdist; 

xc = ((1 - cr) * TWPx) + (cr .* xvald) 
yc = ((1 - cr) * TWPy) + (cr .* yvald) 

scatter(xc, yc, 'Marker','p', 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'b', 'LineWidth', 2) 
