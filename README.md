# visible-thermal-registration
Visible-light and thermal infrared image registration based on improved KAZE and epipolar constraint
This repository contains the MATLAB implementation of the paper:

**Enhanced Image Registration for Visible-Light and Thermal Infrared Modalities via Dual-Objective Calibration and Adaptive Feature Matching**

## Method Overview

The proposed framework includes:

1. Gradient Variance Weighted KAZE feature detection
2. Epipolar constraint guided feature filtering
3. RANSAC affine transformation estimation
4. Overlap region detection
5. Multi-scale gradient pyramid fusion

## Requirements

MATLAB R2022a or newer

Required toolboxes:

Computer Vision Toolbox  
Image Processing Toolbox

## Running the code
main.m 
The program will:
load RGB and thermal images
perform feature matching
estimate geometric transformation
align thermal image to RGB image
visualize the registration results
display fused images

## License
This project is released for academic and research purposes.

## Paper
Enhanced Image Registration for Visible-Light and Thermal Infrared Modalities via Dual-Objective Calibration and Adaptive Feature Matching
