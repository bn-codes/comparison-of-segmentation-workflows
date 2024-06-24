# Comparison of Segmentation Workflows
This repository contains the source code of my final project for the MB100P08 4EU+ Quantitative Microscopy course at the Faculty of Science at Charles University in Prague.

The main body of the project is available [here](https://github.com/bn-codes/comparison-of-segmentation-workflows/blob/main/Project.pdf).

## Structure of the Repository

* `Instructions/` contain technical instructions for the implementation of segmentation workflows in both Ilastik and Fiji
* `macros/` contain macros for counting the cells from segmented images obtained with Ilastik and Fiji
* `Results.xlsx` contains the cell counts obtained with Ilastik and Fiji workflows, as well as the ground truth provided by the dataset
* `Statistics.R` contains the code for running the statistical analysis

## Abstract

As counting the cells is the basis of image analysis, this project aims to compare two segmentation workflows in Ilastik and Fiji, respectively. The cell counts obtained by these segmentation workflows were contrasted with cell counts acquired by manual observation of the images.
