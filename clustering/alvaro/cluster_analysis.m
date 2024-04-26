% This script is developed to have all the code developed for cluster
% analysis under the same language (Matlab) so it's easier to adapt all
% changes more straightforward. The main functions in this analysis will
% merge the .mat files generated in the binarization for each experiment.
% It will generate plots for Normalized Area Distribution (NAD), NAD for areas > 2,
% Probability of different size of clusters. Also it will aply different
% statistics to determine differences in Area Distribution per time with
% the Kruskal-Wallis test and the post-hoc Wilcoxon.
% INPUT: folder with the .mat files of a given experiment generated by the
% image_script_analysis.m.
% OUTPUT: A plot folder with the plots generated. A test folder with the
% test files in .csv
% Raya-Marin, Alvaro. 25.04.2024.

% Specify the folder of interest with the .mat files.
path = ['C:\Users\uib\Nextcloud\LAB\Wetlab\Yeast_experiments\Clustering ' ...
    'experiments\Exps_clustering_20240327_tiff\SK1_1000_30_0.1zymo'];

% % Path where the model used to differentiate between cells with normal 
% and weird shapes is located
% model_path = 'C:\\Users\\uib\\Desktop\\infibio_repository_new\\infibio
% \\clustering\\alvaro\\Functions\\classification_cells_not_wanted.rds'

% The combineMatFiles is the function that will combine all .mat files with 
% the results. 
mat_combined = combineMatFiles(path);

% Clean up weird cell shapes. An SVM model with > 99% of accuracy
% distinguish between weird shapes produced in the binarization and good
% shaped cells to delete those rows.
mat_cleaned = clean_weird_shapes(mat_combined);

% Plots function will generate the plots specified in the function. 
% INPUT: mat_combined file, number of bins and the path to save the plots.
plots(mat_combined, 100, path);

% Tests function will apply the test specified in the function. 
% INPUT: mat_combined file and path to store the results.
tests(mat_combined, path);





