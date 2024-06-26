function df_combined = clean_weird_shapes(df)
    %df = mat_combined;
    % Load the pre-trained radial SVM model from the same folder as the function
    model_path = fullfile(fileparts(mfilename('fullpath')), 'svm_radial_model.mat');
    svm_radial_model = load(model_path);
    
    % Remove unnecessary columns
    columns_to_remove = [2, 9, 10, 11, 12, 13, 14];
    df_copy = df;
    df_copy = struct2table(df_copy);
    df_copy(:, columns_to_remove) = [];
    
    % Normalize and scale all numeric columns of the combined dataframe
    df_combined_scaled = array2table(zscore(table2array(df_copy)));
    df_combined_scaled.Properties.VariableNames = df_copy.Properties.VariableNames;
    
    % Apply the pre-trained model to the new dataframe
    predictions = predict(svm_radial_model.svm_radial_model, table2array(df_combined_scaled));
     % Convert struct array to cell array of structs
    df_cell = num2cell(df);
    
    % Assign predictions to each struct in the cell array
    for i = 1:numel(df_cell)
        df_cell{i}.predictions = predictions(i);
    end
    
    % Convert cell array of structs back to struct array
    df = [df_cell{:}];
     % Remove rows where the 'predictions' column is equal to "y"
    mask = [df.predictions] == "n";
    filtered_df = df(mask);
    df = struct2table(df);
    filtered_df = struct2table(filtered_df);
    % Remove the 'predictions' column
    df_combined = filtered_df(:, ~strcmp(df.Properties.VariableNames, 'predictions'));
    
    df_combined = table2struct(df_combined);
    
end

