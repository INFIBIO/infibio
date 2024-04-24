function df_combined = clean_weird_shapes(df, model)
    % Carga el modelo SVM radial pre-entrenado. El modelo debe ser la ruta donde se encuentra el modelo
    svm_radial_model = load(model);
    
    % Normaliza y escala todas las columnas numéricas del dataframe combinado
    numeric_columns = df(:, cellfun(@isnumeric, df.Properties.VariableNames));
    df_combined_scaled = array2table(zscore(table2array(numeric_columns)));
    df_combined_scaled.Properties.VariableNames = numeric_columns.Properties.VariableNames;
    
    % Combina las columnas no numéricas con las escaladas
    df_combined_scaled = [df(:, ~cellfun(@isnumeric, df.Properties.VariableNames)), df_combined_scaled];
    
    % Elimina las columnas que no son necesarias
    columns_to_remove = [2, 3, 10, 11, 12];
    df_combined_scaled(:, columns_to_remove) = [];
    
    % Aplica el modelo pre-entrenado al nuevo dataframe
    predictions = predict(svm_radial_model, table2array(df_combined_scaled));
    
    % Agrega las predicciones como una columna al dataframe original
    df.predictions = predictions;
    
    % Elimina las filas donde la columna 'predictions' es igual a "y"
    filtered_df = df(df.predictions ~= "y", :);
    
    % Elimina la columna 'predictions'
    df_combined = filtered_df(:, ~strcmp(df.Properties.VariableNames, 'predictions'));
    
    % Convierte la columna 'replica' a tipo numérico
    df_combined.replica = str2double(df_combined.replica);
end
