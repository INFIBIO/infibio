library(tidyverse)

# This script is developed to analyse the clustering of yeast under different
# stresses.  
# A.R.M. 2024, April, 2nd.

# Work directory. Recommended to set the set as wd the path with the data to be
# analysed.
setwd("C:\\Users\\uib\\Nextcloud\\LAB\\Wetlab\\Yeast_experiments\\Clustering experiments\\Exps_clustering_20240327_tiff\\SK1_1000_30_0.1zymo")
path <- "C:\\Users\\uib\\Nextcloud\\LAB\\Wetlab\\Yeast_experiments\\Clustering experiments\\Exps_clustering_20240327_tiff\\SK1_1000_30_0.1zymo"


# The following lines will charge the functions to be used later.

source('~/Functions/clean_weird_shapes.r')
source('~/Functions/combine_csv.r')
source('~/Functions/plots.r')
source('~/Functions/tests.r')


# Here you have to indicate the path were the model used to difference between 
# well shaped cells and weird ones because of binarization is located.

model_path <- paste0('~/Functions/classification_cells_not_wanted.rds')

# combine_csv combines all csv files produced from the image analyses script 
# from matlab. The expected input is the path were the csv files are located 
# of the same experiment. The output is a csv file containing all the original 
# csv files merged and other features:
# - area_norm: normalized area for each csv file with the mean of the 25% lower 
# areas.
# - well replica: the sub-sample for each well (from 0 to 3)
# - Time: time at which the sample was taken.

csv_combined <- combine_csv(path)

# clean_weird_shapes cleans the weird cell shapes from the good ones. I uses a
# pre-trained SVM radial model. The input is the previous csv combined and the
# path where the model is located.

csv_cleaned <- clean_weird_shapes(csv_combined, model_path)

# plots generate different graphs based on area_norm to check if there are differences
# in the area distribution between times. It's expected an increase of clusters
# as increase the time of clustering, in that case we would see a displacement
# to the right on the distribution plot (bigger clusters). Input are the csv
# file that you want to analyse, the bins in which the distribution plots
# will bin the data and the path where you want to save the plots. The outputs 
# will be the different plots with png extensions in the desired folder.


plots(csv_combined, 100, path)

# tests performs kruskal test to check if are there significant differences between
# norm_areas time to time. Also, a wilcoxon test is performed to see where are the
# differences. The input is the csv file to be analysed and the path to save the
# results. The output are two csv files, one with the kruskal results and another
# with the wilcoxon results.

tests(csv_combined, path)
