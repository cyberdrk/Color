% plotting the CIE 1931 XY Chromaticity diagram 
figure 
plotChromaticity 
hold on % hold on figure, there's more to come 

% plotting the Illuminant D65, popularly known as the White Point 
plot(0.3127, 0.3290, 'x', 'MarkerEdgeColor','white', 'MarkerSize', 25)
hold on 

TWP = [0.3127, 0.3290]

% plotting the ITU-R Recommendation BT.709 
% The format of High Definition Television 
% plotted in yellow 

line([0.64, 0.30], [0.33, 0.60], 'Color', 'yellow')
line([0.30, 0.15], [0.60, 0.06], 'Color', 'yellow')
line([0.15, 0.64], [0.06, 0.33], 'Color', 'yellow') 


% plotting the ITU-R Recommendation BT.2020 
% The format of Ultra High Definition Television 
% plotted in black 

line([0.708, 0.170], [0.292, 0.797], 'Color', 'black')
line([0.170, 0.131], [0.797, 0.046], 'Color', 'black')
line([0.131, 0.708], [0.046, 0.292], 'Color', 'black')

xhd = [0.64, 0.30, 0.15, 0.64] 
yhd = [0.33, 0.60, 0.06, 0.33] 

xuhd = [0.708, 0.170, 0.131, 0.708] 
yuhd = [0.292, 0.797, 0.046, 0.292] 

% plotting the TWP projection lines for UHD 

% line([0.708, 0.3127], [0.292, 0.3290], 'Color', 'white')
% line([0.170, 0.3127], [0.797, 0.3290], 'Color', 'white')
% line([0.131, 0.3127], [0.046, 0.3290], 'Color', 'white')

line([0.64, 0.3127], [0.33, 0.3290], 'Color', 'white')
line([0.30, 0.3127], [0.60, 0.3290], 'Color', 'white')
line([0.15, 0.3127], [0.06, 0.3290], 'Color', 'white')
