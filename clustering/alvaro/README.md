# Folder distribution:

We can find different files and folders. Each folder will have their own README.md file, but as an introduction:

- Functions: Functions used in the cluster_analysis script.
  
- Cluster analysis: script of R to analyse the output from script_image_analysis_V1.m
    
- script_image_analysis_V1.m: script in matlab to binarize tif images and extract some parameters. Uses the functions inside YeastFunctions.


## Workflows:

### Matlab:

This workflow is developed to substitute the previous one developed in R to have everything related to yeast analyses in the same language.

First two steps are exactly as previously:

1 -  Binarization and extract features: first of all is needed to binarize the TIF images. To do so, you'll have to use the
     [script_image_analysis_V1.m](https://github.com/INFIBIO/infibio/blob/main/clustering/alvaro/script_image_analysis_AR_V1.m) script. In this script you can change the function to use, in this case you have to use the [image_analysis_aggregates_AR_V1](https://github.com/INFIBIO/infibio/blob/main/clustering/alvaro/image_analysis_aggregates_AR_V1.m)
     function in the YeastFunctions/Clustering folder. As input expects a folder with tif images and output are csv and m files with features (for more info, 
     go inside the script)

2 - Check binarization: since in the process of taking the pictures some artefact might appear, is recommended to check the binarized images to be sure
    there are not artifacts that can give wrong results.

3 - Data analyses: The cluster_analysis.m file integrates four functions:

a - comineMatFiles: combine the .mat files obtained from the binarization.

b - clean_weird_shapes: applies an SVM model to remove those weird shapes obtained in the binarization. It presents > 99% of accuracy.

c - plots: a function that creates different plots to analyse the data. For more details, check the function.

d - test: checks the normality and homocedasticity of the Normalized Area and applies a Kruskal test and Tukey post-hoc test.



### R:

This workflow is developed to analyse the yeast clustering experiments run in the laboratory. This analyse has three steps:

1 -  Binarization and extract features: first of all is needed to binarize the TIF images. To do so, you'll have to use the
     [script_image_analysis_V1.m](https://github.com/INFIBIO/infibio/blob/main/clustering/alvaro/script_image_analysis_AR_V1.m) script. In this script you can change the function to use, in this case you have to use the [image_analysis_aggregates_AR_V1](https://github.com/INFIBIO/infibio/blob/main/clustering/alvaro/image_analysis_aggregates_AR_V1.m)
     function in the YeastFunctions/Clustering folder. As input expects a folder with tif images and output are csv and m files with features (for more info, 
     go inside the script)

2 - Check binarization: since in the process of taking the pictures some artefact might appear, is recommended to check the binarized images to be sure
    there are not artifacts that can give wrong results.

3 - Data analysis: to analyse the data obtained in the first step, you'll use the [cluster_analysis](https://github.com/INFIBIO/infibio/blob/main/clustering/alvaro/cluster_analysis.R) R script. It calls the functions inside the folder [Functions](https://github.com/INFIBIO/infibio/tree/main/clustering/alvaro/Functions).
    This step will clean weird cell shapes with a SVM algorithm developed, merge all csv files for the experiment and produce some plots and test. The expected
    input is the folder with the csv files and the output is a result folder with some plots and a kruskal test and the wilcoxon post-hoc.

To Do:

a - Since the type of analysis will change, decide whether to use just Matlab for the whole workflow or keep using R (probably the first is the best)

b - Study implementing data quality test, normality and homocedasticity testing, and check if the test applied are the best for our data.


