# Yeast Image Analysis

In this repository we can find several tools for the analysis of yeast images. First of all, let's explain the distribution:

## Branch distribution:

As a gitflow repository, there will be three branches (usually there are many more, but we don't really need them)

1 - main. In this branch there will be the scripts and functions we know for sure are already functioning correctly.

2 - develop. Here there's located the most updated files, but since they're under constant changes, it's possible to find errors or unfinished scripts.

3 - feature/x. This branch will vary on number and names since they're are created for the different changes that the develop branch will suffer. It's created
   	       for each developer to avoid overlapping changes in the same file. Once the feature under development is implemented, this branch will be merged into
	       the develop branch and this will be deleted.

## Folder distribution:

We can find different files and folders. Each folder will have their own README.md file, but as an introduction:

- Functions: Functions used in the cluster_analysis script.
  
- rename_img: python scripts to rename images.
  
- YeastFunctions: functions and script specifically for yeast analysis.
  
- ZenFunctions: scripts for the usage of the Axio Observer 5.
  
- Cluster analysis: script of R to analyse the output from script_image_analysis_V1.m
  
- from_czi_to_tiff: python script to change images from the czi extension to tif, necessary for script_image_analysis_V1.m.
  
- script_image_analysis_V1.m: script in matlab to binarize tif images and extract some parameters. Uses the functions inside YeastFunctions.


## Workflows:

### Clustering:

This workflow is developed to analyse the yeast clustering experiments run in the laboratory. This analyse has three steps:

1 -  Binarization and extract features: first of all is needed to binarize the TIF images. To do so, you'll have to use the
     [script_image_analysis_V1.m](https://github.com/alvarorm906/infibio/blob/develop/script_image_analysis_AR_V1.m) script. In this script you can change the function to use, in this case you have to use the [image_analysis_aggregates_AR_V1](https://github.com/alvarorm906/infibio/blob/develop/YeastFunctions/Clustering/image_analysis_aggregates_AR_V1.m)
     function in the YeastFunctions/Clustering folder. As input expects a folder with tif images and output are csv and m files with features (for more info, 
     go inside the script)

2 - Check binarization: since in the process of taking the pictures some artefact might appear, is recommended to check the binarized images to be sure
    there are not artifacts that can give wrong results.

3 - Data analysis: to analyse the data obtained in the first step, you'll use the [cluster_analysis](https://github.com/alvarorm906/infibio/blob/develop/cluster_analysis.R) R script. It calls the functions inside the folder [Functions](https://github.com/alvarorm906/infibio/tree/develop/Functions).
    This step will clean weird cell shapes with a SVM algorithm developed, merge all csv files for the experiment and produce some plots and test. The expected
    input is the folder with the csv files and the output is a result folder with some plots and a kruskal test and the wilcoxon post-hoc.

To Do:

a - Since the type of analysis will change, decide whether to use just Matlab for the whole workflow or keep using R (probably the first is the best)

b - Study implementing data quality test, normality and homocedasticity testing, and check if the test applied are the best for our data.

### Zymoliase:

Since all the workflow is to be changed, this section will be updated later.


