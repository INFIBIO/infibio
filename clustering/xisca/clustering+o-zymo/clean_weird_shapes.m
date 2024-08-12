function df_combined = clean_weird_shapes(df)
    %df = mat_combined;
    % Load the pre-trained radial SVM model from the same folder as the function
    model_path = fullfile(fileparts(mfilename('fullpath')), 'svm_radial_model.mat');
    svm_radial_model = load(model_path);
    
    % Remove unnecessary columns
    columns_to_remove = [2, 9, 10, 11, 12, 13, 14, 15, 16, 17];
    df_copy = df;
    df_copy(:, columns_to_remove) = [];
    
    % Normalize and scale all numeric columns of the combined dataframe
    df_combined_scaled = array2table(zscore(table2array(df_copy)));
    df_combined_scaled.Properties.VariableNames = df_copy.Properties.VariableNames;
    
    % Apply the pre-trained model to the new dataframe
    predictions = predict(svm_radial_model.svm_radial_model, table2array(df_combined_scaled));

   
    
% Ensure predictions is a column vector
predictions = predictions(:);

% Check if the dimensions match
if numel(predictions) == height(df)
    % Assign predictions directly to the table
    df.predictions = predictions;
else
    error('The number of predictions does not match the number of rows in the table.');
end
   
     % Remove rows where the 'predictions' column is equal to "y"
    filtered_df = df(df.predictions == "n",:);
    % Remove the 'predictions' column
    df_combined = filtered_df(:, ~strcmp(df.Properties.VariableNames, 'predictions'));
    
end

