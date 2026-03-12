# Visible–Thermal Image Registration (MATLAB)

⚠️ This repository contains the **official implementation** associated with the following paper submitted to *The Visual Computer*:

**Enhanced Image Registration for Visible-Light and Thermal Infrared Modalities via Dual-Objective Calibration and Adaptive Feature Matching**

The code is released to improve **research transparency and reproducibility**.  
Researchers are encouraged to reproduce the experiments and evaluate the results using the provided implementation.

If you use this code in your research, please cite the corresponding paper.

---

## Paper–Code Relationship

This repository provides the **experimental implementation** used in the paper:

Enhanced Image Registration for Visible-Light and Thermal Infrared Modalities via Dual-Objective Calibration and Adaptive Feature Matching  
(submitted to *The Visual Computer*)

The repository includes:

- algorithm implementation
- calibration parameters
- experiment scripts
- visualization tools

These resources allow readers to **reproduce the experiments reported in the paper**.

---

## Citation

If you use this code or dataset, please cite:

@article{visible_thermal_registration,
  title={Enhanced Image Registration for Visible-Light and Thermal Infrared Modalities via Dual-Objective Calibration and Adaptive Feature Matching},
  journal={The Visual Computer},
  year={2026}
}

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

