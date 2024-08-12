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
    heatmap(correlation_matrix, 'XData', data_cleaned.Properties.VariableNames(1:9), 'YData', data_cleaned.Properties.VariableNames(1:9), 'ColorbarVisible', 'on');
    title('Correlation Matrix of Cell Parameters');
    saveas(gcf, fullfile(results_folder, 'correlation_matrix.png'));
    close(gcf);

    % Save the correlation matrix as a table
    correlation_table = array2table(correlation_matrix, 'VariableNames', data_cleaned.Properties.VariableNames(1:9), 'RowNames', data_cleaned.Properties.VariableNames(1:9));
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
