In order to preprocess the data, it's been developed the file 'classification_cells_not_wanted.rds', inside the 'Cluster analysis' folder, a kernlab model developed with the library Caret to distinguish between weird shaped yeast cells (because of the binarization) from normal shaped cells.
This RDS file has been created using the 'predict_weird_shape_kernlab_model.rmd' file and the database 'labeled' folder. It can be improved and retrained. To implement the filtering, you can follow the first lines of the 'check_population_equality.Rmd' file.
2024, March, 27:
In the cluster analysis folder there's the 'cluster_analysis.R' file that uses the functions developed in the functions folder to analyse a given folder with the csv files with the features obtaind from regionprops, and apply directly a csv combination from all the pictures, remove weird shapes and saving the plots and analysis. Plots function is ready to be used, tests function needs to sort out how to save the results. The idea is to loop over different folders to automatically obtain the results.

The model 'classification_cells_not_wanted.rds' has the following caracteristics:

Model (caret package):
svm_radial_model <- train(rare ~ ., data = train_data, 
                          method = "svmRadial", trControl = ctrl, 
                          metric = 'Accuracy',
                          tuneGrid = expand.grid(C = 1.74, 
                               sigma = 0.01))
those are the hyperparameters that has been showns as the best for classification.

|          | Reference |
|----------|-----------|
| Prediction |   n   |   y   |
|--------|------|------|
|      n   | 279  |  2    |
|      y   |   2   |   7   |

- Accuracy : 0.9862
- 95% CI : (0.9651, 0.9962)
- No Information Rate : 0.969
- P-Value [Acc > NIR] : 0.05235
- Kappa : 0.7707

                  
The model has been saved as a RDS file with name 'classification_cells_not_wanted.rds'. Because of the high P-value, would be a good practice to re-run the model with more training dataset and see if it improves since
the "y" class (weird shapes), are scarcely found.

Accuracy: percentage of correct predictions made by a model.
Kappa:  In machine learning, "kappa" typically refers to Cohen's kappa coefficient, which is a statistic that measures inter-rater agreement for categorical items. It is generally used when there are two or more raters (or classifiers) who each classify items into mutually exclusive categories. Cohen's kappa takes into account the possibility of the agreement occurring by chance.
$$\kappa = \frac{p_o - p_e}{1 - p_e}$$

$p_o$ =  represents the observed agreement among raters.

$p_e$ = represents the expected agreement by chance.
