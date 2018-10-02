# Color Gamut Mapping 

The MATLAB scripts in this repository is an implementation of the following paper: ["A Color Mapping Scheme for Backward Compatible UHD Video Distribution"](https://ieeexplore.ieee.org/document/7996741) published in 2017 IEEE International Conference on Communications (Maryam Azimi ; Timothée-Florian Bronner ; Panos Nasiopoulos ; Mahsa T. Pourazad ) 

PDF: http://www.ece.ubc.ca/~maryama/2017_ICC_Azimi.pdf 
 

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. 

Open the Terminal (cmd in case of Windows), navigate to your desired folder and type in the following command to download the repository: 

``` 
git clone https://github.com/cyberdrk/Color 
``` 

### Prerequisites

The code can be run on MATLAB. Please make sure you have at least MATLAB 2017a running on your machine. 

```
*Software: 
MATLAB 2017a or greater 

*Toolboxes: 
Image Processing Toolbox 
Math Toolbox 
```

## Running

### Necessary Steps before we begin 

Download the repository along with all the dependencies.  

Once you've started MATLAB, 

Navigate to the folder where you've downloaded the repository contents inside MATLAB and add it to the MATLAB File Path. 

Create a folder with the name 'res'. The algorithm will store all the results in this folder. 

### Loading the image and Getting Started 

Open 'validPointEA.m',  

Make sure you add your image filename in the first few lines of the script: 

```
image_name = 'InputImage25.png'; 
```

Once you've made the above changes, vary the value of 'alpha', save and hit RUN! 

```
alpha = 0.9 
```

The chromaticity plots and the resulting image will be generated. 

The results will be stored in the 'res' folder with the alpha value specified. 


## Chromaticity Plot legend 

The plotChromaticity() function of MATLAB plots the CIE 1931 color space chromaticity diagram. 

The REC 2020 or UHD Gamut is displayed by the biggest black triangle. 

The REC 709 or UHD Gamut is displayed by the yellow triangle. 

The White Point Illuminant D65 has been indicated using a white 'X'. 

The points to be scaled have been indicated using a black 'x'. 

The points after expansion have been shown by blue stars. 

The white circles on the boundaries of the UHD and HD Gamut indicate the intersection of a line drawn from the point under consideration to the White Point D65. (Towards White Point Projection) 
