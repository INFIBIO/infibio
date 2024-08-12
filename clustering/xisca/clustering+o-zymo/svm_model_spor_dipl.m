% Specify the folder path
folder_path = 'C:/Users/uib/Desktop/diploid-spor diff/';

% Get a list of all .m files in the folder
file_list = dir(fullfile(folder_path, '*.mat'));
concatenated_code = table();
% Loop through each .m file
for i = 1:length(file_list)
    % Read the contents of the file
    file_path = fullfile(folder_path, file_list(i).name);
    file_contents = load(file_path);
    file_contents = struct2table(file_contents.features);
    file_contents(:,[2,3]) = [];
    % Concatenate the code
    concatenated_code = [concatenated_code;file_contents];
end

% Convertir la columna 'rare' a factor
yeast = concatenated_code;
yeast.id = categorical(yeast.id);


% Crear un nuevo conjunto de datos sin las columnas especificadas
yeast_new = yeast;


% Escalar y centrar los datos
scaled_centered_yeast_new = array2table(zscore(table2array(yeast_new(:, 1:2))));
yeast_new(:, 1:2) = scaled_centered_yeast_new;
scaled_centered_yeast_new = yeast_new;
scaled_centered_yeast_new.Properties.VariableNames = yeast_new.Properties.VariableNames;


% Combinar los datos escalados y centrados con la columna 'rare'
scaled_normalized_data = scaled_centered_yeast_new;



% Crear índices para la división de datos (67% train, 33% test)
rng('default'); % Restablecer la semilla aleatoria para reproducibilidad
train_index = randperm(size(scaled_normalized_data, 1), round(0.67 * size(scaled_normalized_data, 1)));
train_data = scaled_normalized_data(train_index, :);
test_data = scaled_normalized_data;
test_data(train_index, :) = [];
% Definir el control de entrenamiento
ctrl = cvpartition(size(train_data, 1), 'KFold', 3);

% Definir los hiperparámetros
C_values = 1.6:0.01:1.8;
sigma_values = 0.0005:0.001:0.2;
[CC, SigmaSigma] = meshgrid(C_values, sigma_values);
hyperparameters = [CC(:), SigmaSigma(:)];

% Realizar la optimización de hiperparámetros del modelo SVM radial
svm_radial_model = fitcsvm(train_data(:, 1:end-1), train_data(:, end), ...
    'KernelFunction', 'RBF', 'OptimizeHyperparameters', 'auto', ...
    'HyperparameterOptimizationOptions', struct('ShowPlots', false, 'CVPartition', ctrl, 'AcquisitionFunctionName', 'expected-improvement-plus'));
% Realizar predicciones en los datos de prueba
predictions = predict(svm_radial_model, test_data(:, 1:end-1));

% Obtener las etiquetas reales de los datos de prueba
actual_labels = test_data(:, end);
% Extraer los datos de la tabla 'actual_labels' como un array
actual_labels_array = table2array(actual_labels);

% Convertir los datos a tipo categórico
actual_labels_categorical = categorical(actual_labels_array);

% Convertir las predicciones a tipo categórico
predictions_categorical = categorical(predictions);

% Calcular la matriz de confusión
confusion_matrix = confusionmat(actual_labels_categorical, predictions_categorical);

% Mostrar la matriz de confusión
disp('Matriz de Confusión:');
disp(confusion_matrix);

% Calcular estadísticas adicionales
TP = confusion_matrix(1,1); % Verdaderos positivos
TN = confusion_matrix(2,2); % Verdaderos negativos
FP = confusion_matrix(2,1); % Falsos positivos
FN = confusion_matrix(1,2); % Falsos negativos

% Calcular la precisión
precision = TP / (TP + FP);

% Calcular la sensibilidad (recall)
sensitivity = TP / (TP + FN);

% Calcular la especificidad
specificity = TN / (TN + FP);

% Mostrar estadísticas adicionales
disp('Estadísticas adicionales:');
fprintf('Precisión: %.4f\n', precision);
fprintf('Sensibilidad: %.4f\n', sensitivity);
fprintf('Especificidad: %.4f\n', specificity);

