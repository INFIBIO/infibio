# Clustering analysis with or without zymoliase

This folder holds the necessary Matlab scripts for the clustering analysis in presence or absence of zymoliase.

## Usage:

1 - The script_image_analysis_AR_V1.m script binarizes and extracts the yeast characteristics of each image. It also implements the classification model to differentiate between haploid/diploid, sporulated and cluster.

NOTE: This script runs slow, it takes several hours. (It's necessary study the possibility or running it using GPU instead of CPU)
NOTE 2: It's necessary to follow the (instalation steps)[https://github.com/INFIBIO/infibio/tree/main/clustering/xisca/clustering%2Bo-zymo] to use yolov5.

2 - The do_cluster_analysis.m takes the tables generated in the 1st step to run different tests and create different plots 

NOTE: It's necessary to improve the workflow to avoid introducing files by hand and havind to modify the scripts depending on the number of experiments to compare.

