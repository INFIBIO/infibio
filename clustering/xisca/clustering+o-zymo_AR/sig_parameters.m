function sig_parameters(data, pathsave)
    
    % Check if the 'results' folder exists, if not, create it
    results_folder = fullfile(pathsave, 'results');
    if ~exist(results_folder, 'dir')
        mkdir(results_folder);
    end
    
    % Drop rows with missing 'Time' values
    data_cleaned = data(~ismissing(data.Time), :);


    % Perform correlation analysis and display the correlation matrix
    correlation_matrix = corr(table2array(data_cleaned(:, {'Area', 'Perimeter', 'Circularity', 'Eccentricity', 'Solidity', 'MinorAxisLength', 'MajorAxisLength'})));
    figure;
    % Define los nombres de las variables que deseas utilizar
    variableNames = {'Area', 'Perimeter', 'Circularity', 'Eccentricity', 'Solidity', 'MinorAxisLength', 'MajorAxisLength'};
    
    % Asegúrate de que todos los nombres existen en 'data_cleaned'
    validNames = intersect(variableNames, data_cleaned.Properties.VariableNames);
    
    % Crea el heatmap usando los nombres de las variables válidas
    heatmap(correlation_matrix, ...
        'XData', validNames, ...
        'YData', validNames, ...
        'ColorbarVisible', 'on');
    %heatmap(correlation_matrix, 'XData', data_cleaned.Properties.VariableNames('Area', 'Perimeter', 'Circularity', 'Eccentricity', 'Solidity', 'MinorAxisLength', 'MajorAxisLength'), 'YData', data_cleaned.Properties.VariableNames('Area', 'Perimeter', 'Circularity', 'Eccentricity', 'Solidity', 'MinorAxisLength', 'MajorAxisLength'), 'ColorbarVisible', 'on');
    title('Correlation Matrix of Cell Parameters');
    saveas(gcf, fullfile(results_folder, 'correlation_matrix.png'));
    close(gcf);

    % Save the correlation matrix as a table
correlation_table = array2table(correlation_matrix(1:length(validNames), 1:length(validNames)), ...
        'VariableNames', validNames, 'RowNames', validNames);    
writetable(correlation_table, fullfile(results_folder, 'correlation_matrix.csv'), 'WriteRowNames', true);

    % Initialize results for intra-variability
    results_intravariability = {};

    % Calculate intra-variability measures for each parameter
    for i = 1:width(data_cleaned)
        if isnumeric(data_cleaned{:, i})
            param = data_cleaned.Properties.VariableNames{i};
            mean_val = mean(data_cleaned{:, i});
            std_val = std(data_cleaned{:, i});
            var_val = var(data_cleaned{:, i});
            cv_val = std_val / mean_val;
            results_intravariability = [results_intravariability; {param, mean_val, std_val, var_val, cv_val}];
        end
    end

    % Save intra-variability results as table
    if ~isempty(results_intravariability)
        intravariability_table = cell2table(results_intravariability, 'VariableNames', {'Parameter', 'Mean', 'StandardDeviation', 'Variance', 'CoefficientOfVariation'});
        writetable(intravariability_table, fullfile(results_folder, 'intravariability_results.csv'));
    end

    disp(['Analysis complete. Results saved in ' results_folder]);
end
