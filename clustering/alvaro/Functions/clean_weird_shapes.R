clean_weird_shapes <- function(df, model){

# Load the pre-trained SVM radial model. Model should be the pathway where the model is located
  svm_radial_model <- readRDS(model)
  
  # Normalize and scale all numeric columns of the combined dataframe
  df_combined_scaled <- as.data.frame(scale(df[, sapply(df, is.numeric)]))
  
  # Assign column names
  colnames(df_combined_scaled) <- colnames(df)[sapply(df, is.numeric)]
  
  # Combine non-numeric columns with scaled ones
  df_combined_scaled <- cbind(df[!sapply(df, is.numeric)], df_combined_scaled)
  # Reorder columns of df_combined_scaled according to df_combined order
  df_combined_scaled <- df_combined_scaled[, colnames(df)]
  columns_to_remove <- c(2, 3, 10, 11, 12)
  df_combined_scaled <- df_combined_scaled[,-columns_to_remove]
  # Apply the pre-trained model to the new dataframe
  predictions <- predict(svm_radial_model, newdata = df_combined_scaled)
  
  # Add the predictions list as a column to df_combined
  df$predictions <- predictions
  
  # Remove rows where the 'predictions' column is equal to "y"
  filtered_df <- df[df$predictions != "y", ]
  
  # Remove the 'predictions' column
  df_combined <- filtered_df[, -which(names(filtered_df) == "predictions")]
  df_combined$replica <- as.numeric(df_combined$replica)
return(df_combined)
}
