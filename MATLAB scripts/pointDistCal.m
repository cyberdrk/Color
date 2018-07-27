% plotting the CIE 1931 XY Chromaticity diagram 
figure 
plotChromaticity 
hold on % hold on figure, there's more to come 


TWPx = 0.3127 
TWPy = 0.3290


xhd = [0.64, 0.30, 0.15, 0.64] 
yhd = [0.33, 0.60, 0.06, 0.33] 

xuhd = [0.708, 0.170, 0.131, 0.708] 
yuhd = [0.292, 0.797, 0.046, 0.292] 

alpha = 0.1 
    
xhds = xhd - TWPx 
yhds = yhd - TWPy 

xahd = round(xhd - alpha * xhds, 2) 
yahd = round(yhd - alpha * yhds, 2) 


% xahd(1)
line([xahd(1), xahd(2)], [yahd(1), yahd(2)], 'Color', 'red', 'LineWidth', 2) 
line([xahd(2), xahd(3)], [yahd(2), yahd(3)], 'Color', 'red', 'LineWidth', 2) 
line([xahd(3), xahd(1)], [yahd(3), yahd(1)], 'Color', 'red', 'LineWidth', 2) 


% plotting the TWP projection lines for HD 

% plot([0.64, 0.3127], [0.33, 0.3290], 'Color', 'white') 
% plot([0.30, 0.3127], [0.60, 0.3290], 'Color', 'white') 
% plot([0.15, 0.3127], [0.06, 0.3290], 'Color', 'white') 

hold on 

% Random X-Coordinates 
xq = rand(1,10000); 
% Random Y-Coordinates 
yq = rand(1,10000); 

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

plot(xvald, yvald, 'rp')                                  % Overplot ‘inon’ Points 

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

line([0.708, 0.3127], [0.292, 0.3290], 'Color', 'white', 'LineWidth', 2) 
line([0.170, 0.3127], [0.797, 0.3290], 'Color', 'white', 'LineWidth', 2) 
line([0.131, 0.3127], [0.046, 0.3290], 'Color', 'white', 'LineWidth', 2) 

% point wise distance calculator 
x = [0.1945, TWPx] 
y = [0.04466, TWPy] 

% [xi,yi] = polyxpoly(xhd, yhd, x, y) 
% plot(xi,yi,'Marker','o', 'Color', 'white', 'LineWidth', 2)  

[long1, long0] = long_line(x(1), y(1)) 

xlong1 = [1, TWPx] 
ylong1 = [long1, TWPy]

xlong0 = [-1, TWPx] 
ylong0 = [long0, TWPy]

[xi,yi] = polyxpoly(xuhd, yuhd, xlong1, ylong1) 
plot(xi,yi,'Marker','o', 'Color', 'white', 'LineWidth', 2) 

[xi,yi] = polyxpoly(xhd, yhd, xlong1, ylong1) 
plot(xi,yi,'Marker','o', 'Color', 'white', 'LineWidth', 2) 

[xi,yi] = polyxpoly(xuhd, yuhd, xlong0, ylong0) 
plot(xi,yi,'Marker','o', 'Color', 'white', 'LineWidth', 2) 

[xi,yi] = polyxpoly(xhd, yhd, xlong0, ylong0) 
plot(xi,yi,'Marker','o', 'Color', 'white', 'LineWidth', 2) 