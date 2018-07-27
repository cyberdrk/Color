% plotting the CIE 1931 XY Chromaticity diagram 
figure 
plotChromaticity 
hold on % hold on figure, there's more to come 


TWPx = 0.3127; 
TWPy = 0.3290; 

alpha = 0.7 

% alpha = 1 - alpha

beta = 0.3  

xbhd = [0.64, 0.30, 0.15, 0.64]; 
ybhd = [0.33, 0.60, 0.06, 0.33]; 

xuhd = [0.708, 0.170, 0.131, 0.708]; 
yuhd = [0.292, 0.797, 0.046, 0.292]; 
    

xhds = xbhd - TWPx; 
yhds = ybhd - TWPy; 


xhd = round(xbhd - beta * xhds, 2); 
yhd = round(ybhd - beta * yhds, 2); 

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

% Reading the xy points (CIE 1931 xyY) after conversion from the RGB image 
% [xq, yq] = readRGB(); 
%{
% Random X-Coordinates 
xq = rand(1,1000); 
% Random Y-Coordinates 
yq = rand(1,1000); 
%} 

[xq, yq] = readRGB(); 

length(xq) 
length(yq) 

% Logical Matrix 
[in,on] = inpolygon(xq,yq, xhd,yhd); 

inon = in | on;                                             % Combine ‘in’ And ‘on’
idx = find(inon(:));                                        % Linear Indices Of ‘inon’ Points
xcoord = xq(idx);                                           % X-Coordinates Of ‘inon’ Points
ycoord = yq(idx);                                           % Y-Coordinates Of ‘inon’ Points
 
% plot(xcoord, ycoord, 'bp')                                  % Overplot ‘inon’ Points 
% hold on 

% points within the smaller gamut 
[in,on] = inpolygon(xcoord,ycoord, xahd,yahd); 

inon = in | on;                                             % Combine ‘in’ And ‘on’ 
idx = find(inon(:));                                        % Linear Indices Of ‘inon’ Points 
xacoord = xcoord(idx);                                           % X-Coordinates Of ‘inon’ Points 
yacoord = ycoord(idx);                                           % Y-Coordinates Of ‘inon’ Points 
 
plot(xacoord, yacoord, 'gp')                                  % Overplot ‘inon’ Points 


% points outside the smaller gamut but inside the HD gamut 
% Since it's expansion, all points are assumed to be within HD 

validpoint = inpolygon(xq, yq, xhd, yhd) & (~inpolygon(xq, yq, xahd, yahd)); 
idx = find(validpoint(:));                                        % Linear Indices Of ‘validpoint’ Points 
xvald = xq(idx);                                           % X-Coordinates Of ‘validpoint’ Points 
yvald = yq(idx);                                           % Y-Coordinates Of ‘validpoint’ Points 

scatter(xvald, yvald)                                  % Overplot ‘inon’ Points 

% plotting the Illuminant D65, popularly known as the White Point 

plot(0.3127, 0.3290, 'x', 'MarkerEdgeColor','white', 'MarkerSize', 25, 'LineWidth', 1)
hold on 

% plotting the ITU-R Recommendation BT.709 
% The format of High Definition Television 
% plotted in yellow 

line([0.64, 0.30], [0.33, 0.60], 'Color', 'yellow', 'LineWidth', 2) 
line([0.30, 0.15], [0.60, 0.06], 'Color', 'yellow', 'LineWidth', 2) 
line([0.15, 0.64], [0.06, 0.33], 'Color', 'yellow', 'LineWidth', 2) 


% plotting the ITU-R Recommendation BT.709 x beta 
% The format of High Definition Television 
% plotted in yellow 


line([xhd(1), xhd(2)], [yhd(1), yhd(2)], 'Color', 'cyan', 'LineWidth', 2) 
line([xhd(2), xhd(3)], [yhd(2), yhd(3)], 'Color', 'cyan', 'LineWidth', 2) 
line([xhd(3), xhd(1)], [yhd(3), yhd(1)], 'Color', 'cyan', 'LineWidth', 2) 

% plotting the ITU-R Recommendation BT.2020 
% The format of Ul  tra High Definition Television 
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
hold on 

% acquiring extrapolated point's coordinates 

[flag, xr, yr] = ratio_longline(xvald, yvald); 

% scatter(xr, yr, 'Marker', 's', 'MarkerFaceColor', 'y', 'LineWidth', 2) 

disp(flag); 


% plotting a dotted long line that intersects the HD and UHD gamuts 

lxr = length(xr) 
D = []; 
d = []; 


for i = 1:lxr

    % creating long line's coordinates by clubbing them together 

    xlong = [xr(i), TWPx]; 
    ylong = [yr(i), TWPy]; 

    % line(xlong, ylong, 'LineStyle', '--', 'Color', 'yellow', 'LineWidth', 2) 
    % plot(xr, yr, TWPx, TWPy, 'LineStyle', '--', 'Color', 'yellow', 'LineWidth', 2) 
    
    % acquiring the intersection of the long line with the UHD gamut 

    [xD, yD] = polyxpoly(xuhd, yuhd, xlong, ylong); 
    plot(xD, yD, 'Marker', 'o', 'Color', 'white', 'LineWidth', 2) 
    hold on 


    % acquiring the intersection of the long line with the HD gamut 

    [xd, yd] = polyxpoly(xhd, yhd, xlong, ylong);  
    plot(xd, yd, 'Marker','o', 'Color', 'white', 'LineWidth', 2) 
    hold on 

    % line([x(1), xi], [y(1), yi], 'Color', 'white', 'LineWidth', 2) 
    
    D = [D, calc_distance(xD, yD, TWPx, TWPy)]; 
    d = [d, calc_distance(xd, yd, TWPx, TWPy)]; 
end 

disp('loop complete'); 

disp('D'); 
size(D) 

disp('d'); 
size(d) 

size(xvald) 
size(yvald) 

% xm is xdist 
xdist = calc_distance(xvald, yvald, TWPx, TWPy); 

% da = alpha * d

disp('xdist'); 
size(xdist) 

xdist = xdist.'; 

size(xdist) 

x = gamut_expansion(D, d, xdist, alpha); 

disp('x'); 
size(x) 

cr = x ./ xdist 

disp('cr'); 
size(cr) 

xvaldT = xvald.'; 
yvaldT = yvald.'; 

xc = ((1 - cr) * TWPx) + (cr .* xvaldT); 
yc = ((1 - cr) * TWPy) + (cr .* yvaldT); 

size(xc) 
size(yc)

scatter(xc, yc, 'Marker','p', 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'b', 'LineWidth', 2) 

disp('size of points within the aHD'); 
size(xacoord) 
size(yacoord) 

resX = horzcat(xc, xacoord.'); 
resY = horzcat(yc, yacoord.'); 

disp('size of points of the restored xy array'); 
size(resX) 
size(resY) 

% Reconstructing xq and yq 

disp(xq); 
size(xq) 

xq(idx) = xc; 
yq(idx) = yc; 


size(xq) 
size(yq) 

newRGB = createRGB(xq, yq); 
imwrite(newRGB, 'C:/Users/HP-PC/Documents/MATLAB/GamutMapping/res/resInputImage5alpha02beta05.png', 'png'); 
