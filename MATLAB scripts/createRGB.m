function [newRGB] = createRGB(xq, yq, image_name)

% reading RGB .png type image 
rgb = imread(image_name); 

[rows, columns, n] = size(rgb); 

% converting to CIE 1931 XYZ colorspace     
XYZ = rgb2xyz(rgb, 'WhitePoint','d65'); 

% Extract color channels 
X = XYZ(:,:,1); % Red channel
Y = XYZ(:,:,2); % Green channel
Z = XYZ(:,:,3); % Blue channel

% Converting the color channels matrices to vectors 
Xv = X(:); 
Yv = Y(:); 
Zv = Z(:); 

% Converting from CIE XYZ 1931 to CIE xyY 
XplusYplusZ = Xv + Yv + Zv; 

xv = round(Xv ./ XplusYplusZ, 2); 
yv = round(Yv ./ XplusYplusZ, 2); 

% Creating a matrix of the XY coordinates 

XY = horzcat(xv, yv); 

origxv = xv; 
origyv = yv; 

origXY = XY; 
length(XY) 

% Getting only unique values 

[C,ia,ic] = unique(XY(:,1:2),'rows', 'stable'); 
uXY = XY(ia,:); 

length(uXY) 

% xq = uXY(:, 1); 
% yq = uXY(:, 2); 

uXY(:, 1) = xq; 
uXY(:, 2) = yq; 

XY = uXY(ic, :); 

xv = XY(:, 1); 
yv = XY(:, 2); 

size(xv) 
size(yv) 
size(Xv) 
size(Yv) 
size(Z) 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('reconstruction time') 
newX = xv .* Yv ./ yv; 
size(newX)  
nX = reshape(newX, [rows columns]);
size(nX) 

newY = Y; 
size(newY) 

newZ = (1 - xv - yv).* Yv ./ yv; 
size(newZ) 
nZ = reshape(newZ, [rows columns]); 
size(nZ) 

recnXYZ = cat(3, nX, newY, nZ); 
% imshow(recnXYZ); 

newRGB = xyz2rgb(recnXYZ, 'WhitePoint','d65'); 

figure 
imshow(newRGB) 

% imwrite(newRGB, 'res/resC07_HDalpha05beta02.png', 'png'); 
end 


%{
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



% figure
% imshowpair(rgb, xyz, 'montage');
% title('Image in RGB Color Space (Left) and XYZ Color Space (Right)'); 

% colorcloud(rgb,'rgb'); 
%}
