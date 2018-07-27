% t = Tiff('C05_UHD.tif','r'); 
% rgb = read(t); 

% reading RGB .png type image 
rgb = imread('InputImages/InputImage28.png'); 

alpha = 0.7 

beta = 0.3

% imshow(rgb);
% title('C19_HD')
% close(t); 

% Converting to CIE 1931 XYZ colorspace     
XYZ = rgb2xyz(rgb, 'WhitePoint','d65'); 

% Extract color channels 
X = XYZ(:,:,1); % Red channel
Y = XYZ(:,:,2); % Green channel
Z = XYZ(:,:,3); % Blue channel

% Converting the color channels matrices to vectors 
Xv = X(:); 
Yv = Y(:); 
Zv = Z(:); 

% Converting from CIE XYZ 1931 ro CIE xyY 
XplusYplusZ = Xv + Yv + Zv; 

xv = Xv ./ XplusYplusZ; 
yv = Yv ./ XplusYplusZ; 

figure 
plotChromaticity(); 
hold on 
scatter(xv, yv, 'Marker', 'x', 'MarkerEdgeColor', 'k', 'LineWidth', 1); 

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
% The format of Ul  tra High Definition Television 
% plotted in black 

line([0.708, 0.170], [0.292, 0.797], 'Color', 'black', 'LineWidth', 2) 
line([0.170, 0.131], [0.797, 0.046], 'Color', 'black', 'LineWidth', 2) 
line([0.131, 0.708], [0.046, 0.292], 'Color', 'black', 'LineWidth', 2) 


xbhd = [0.64, 0.30, 0.15, 0.64]; 
ybhd = [0.33, 0.60, 0.06, 0.33]; 

xuhd = [0.708, 0.170, 0.131, 0.708]; 
yuhd = [0.292, 0.797, 0.046, 0.292]; 
    
% beta 

xhds = xbhd - TWPx; 
yhds = ybhd - TWPy; 

xhd = round(xbhd - beta * xhds, 2); 
yhd = round(ybhd - beta * yhds, 2); 


% alpha on the basis of beta 

xhds = xhd - TWPx; 
yhds = yhd - TWPy; 

xahd = round(xhd - (1 - alpha) * xhds, 2); 
yahd = round(yhd - (1 - alpha) * yhds, 2); 


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

% xahd(1)
line([xahd(1), xahd(2)], [yahd(1), yahd(2)], 'Color', 'red', 'LineWidth', 2) 
line([xahd(2), xahd(3)], [yahd(2), yahd(3)], 'Color', 'red', 'LineWidth', 2) 
line([xahd(3), xahd(1)], [yahd(3), yahd(1)], 'Color', 'red', 'LineWidth', 2) 


size(xv) 
size(yv) 
size(X) 
size(Y) 
size(Z) 

% saveName = ['InputImages/InputImage1C.png'];
% imwrite(figure, saveName); 
% figure
% imshowpair(rgb, xyz, 'montage');
% title('Image in RGB Color Space (Left) and XYZ Color Space (Right)'); 

% colorcloud(rgb,'rgb'); 