function df_combined = clean_weird_shapes(df)
    % CLEAN_WEIRD_SHAPES Processes the input dataframe to remove certain columns, 
    % normalize data, apply a pre-trained SVM model, and filter rows based on predictions.
    %
    % INPUT:
    %   df - A table (dataframe) containing multiple columns of data.
    %       This table should have rows and columns that you wish to process.
    %
    % OUTPUT:
    %   df_combined - A table that contains rows filtered based on predictions from the SVM model,
    %                 and does not include the 'predictions' column.
    
    % Load the pre-trained radial SVM model from the same folder as the function
    model_path = fullfile(fileparts(mfilename('fullpath')), 'svm_radial_model.mat');
    svm_radial_model = load(model_path);
    
    % Remove unnecessary columns from the dataframe
    columns_to_remove = [2, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18];
    df_copy = df;
    df_copy(:, columns_to_remove) = [];
    
    % Normalize and scale all numeric columns of the dataframe
    df_combined_scaled = array2table(zscore(table2array(df_copy)));
    df_combined_scaled.Properties.VariableNames = df_copy.Properties.VariableNames;
    
    % Apply the pre-trained model to the normalized dataframe
    predictions = predict(svm_radial_model.svm_radial_model, table2array(df_combined_scaled));
    
    % Ensure predictions is a column vector
    predictions = predictions(:);
    
    % Check if the number of predictions matches the number of rows in the input dataframe
    if numel(predictions) == height(df)
        % Add the predictions as a new column to the original dataframe
        df.predictions = predictions;
    else
        error('The number of predictions does not match the number of rows in the table.');
    end
    
    % Filter out rows where the 'predictions' column is equal to "y"
    filtered_df = df(df.predictions == "n", :);
    
    % Remove the 'predictions' column from the filtered dataframe
    df_combined = filtered_df(:, ~strcmp(df.Properties.VariableNames, 'predictions'));
end
