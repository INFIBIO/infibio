function plots_v2_ar(df, path_save)
% This function generates grouped bar plots that show the probability distribution of
% normalized area for different parameter combinations at unique time points.
% The parameters involved are Zymolyase, Velocity, and Temperature.
% The function first cleans the data by removing rows where Time is NaN.
% It then processes each unique time point, generating and saving probability
% distribution plots for combinations of the parameters and normalized area.
% It handles both normal and extreme cases (where NormalizedArea > 2)
% by generating and saving the plots in the specified directory, avoiding
% duplication if the plots already exist.


% Set default save path if not provided
if ~exist('path_save', 'var')
    path_save = '';
end

% Filter rows where Time is not NaN
clean_data = df(~isnan(df.Time), :);
unique_times = unique(clean_data.Time);  % Get unique time points
unique_conc = unique(clean_data.Concentration);  % Get unique concentrations
subfolder = 'plots_2';

% Create subfolder if it doesn't exist
if ~exist(fullfile(path_save, subfolder), 'dir')
    mkdir(fullfile(path_save, subfolder));
end

% Define parameter combinations and names for legends
params_combinations = {'Zymolyase', 'Velocity', 'Temperature'};
params_names = {'Zymolyase', 'Velocity', 'Temperature'};  % Use actual column names
legend_labels = {'Zymolyase (mg/mL)', 'Velocity (rpm)', 'Temperature (ºC)'};  % Legends with units

% Loop through each unique time point
for i = 1:length(unique_times)
    current_time_data = df(df.Time == unique_times(i), :);  % Filter data by the current time

    % Obtain unique values for Zymolyase, Velocity, and Temperature
    unique_zym = unique(current_time_data.Zymolyase);
    unique_velocity = unique(current_time_data.Velocity);
    unique_temperature = unique(current_time_data.Temperature);
    unique_area = unique(current_time_data.NormalizedArea);  % Unique areas for the probability matrix

    % Create parameter combinations
    params_combinations = {unique_zym, unique_velocity, unique_temperature};

    % Iterate through each parameter combination
    for p = 1:length(params_combinations)
        unique_param = params_combinations{p};  % Get unique values of the current parameter
        param_name = params_names{p};  % Get the name of the parameter

        % Check if the plot already exists
        file_name_png = sprintf('combined_plot_%s_time_%d.png', param_name, unique_times(i));
        file_path_png = fullfile(path_save, subfolder, file_name_png);
        file_name_fig = sprintf('combined_plot_%s_time_%d.fig', param_name, unique_times(i));
        file_path_fig = fullfile(path_save, subfolder, file_name_fig);

        if exist(file_path_png, 'file') && exist(file_path_fig, 'file')
            fprintf('Plot for %s at time %d already exists, skipping...\n', param_name, unique_times(i));
            continue;  % Skip if the plot already exists
        end

        % Create the probability matrix for the current parameter combination
        prob_matrix = zeros(length(unique_param), length(unique_area));

        % Fill the probability matrix for each combination of parameter and area
        for v = 1:length(unique_param)
            for a = 1:length(unique_area)
                % Filter data by the current parameter and area combination
                current_combination_data = current_time_data( ...
                    current_time_data.(param_name) == unique_param(v) & ...
                    current_time_data.NormalizedArea == unique_area(a), :);

                % Calculate the probability for the current combination
                total_area_for_param = sum(current_time_data.NormalizedArea(current_time_data.(param_name) == unique_param(v)));
                prob = sum(current_combination_data.NormalizedArea) / total_area_for_param;

                % Store the probability in the matrix
                prob_matrix(v, a) = prob;
            end
        end

        % Plot the probability matrix
        figure;  % Create a new figure for each plot
        bar(prob_matrix', 'grouped');  % Grouped bar plot
        set(gca, 'XTickLabel', unique_area);  % Set X-axis labels to the unique areas
        xlabel('Normalized Area');
        ylabel('Probability');

        % Create legend with parameter values and units
        legend(arrayfun(@(x) sprintf('%s: %.2f', legend_labels{p}, x), unique_param, 'UniformOutput', false), 'Location', 'best');

        % Set the plot title
        title(sprintf('Time: %d s - %s', unique_times(i), legend_labels{p}));

        % Save the plot as .png and .fig files
        saveas(gcf, file_path_png);
        saveas(gcf, file_path_fig);

        % Close the figure after saving
        close(gcf);
    end
end

% Filter extreme values (NormalizedArea > 2)
df_extreme = clean_data(clean_data.NormalizedArea > 2, :);

% Loop through each unique time point for extreme data
for i = 1:length(unique_times)
    current_time_data = df_extreme(df_extreme.Time == unique_times(i), :);  % Filter data by current time
    unique_area = unique(current_time_data.NormalizedArea);  % Get unique areas for the probability matrix

    % Iterate through each parameter combination (Zymolyase, Velocity, Temperature)
    for p = 1:length(params_combinations)
        param_name = params_names{p};  % Get parameter name
        unique_param = unique(current_time_data.(param_name));  % Get unique parameter values

        % Check if the extreme plot already exists
        extreme_plot_file_name_png = sprintf('extreme_combined_plot_%s_time_%d.png', param_name, unique_times(i));
        extreme_plot_file_path_png = fullfile(path_save, subfolder, extreme_plot_file_name_png);
        extreme_plot_file_name_fig = sprintf('extreme_combined_plot_%s_time_%d.fig', param_name, unique_times(i));
        extreme_plot_file_path_fig = fullfile(path_save, subfolder, extreme_plot_file_name_fig);

        if exist(extreme_plot_file_path_png, 'file') && exist(extreme_plot_file_path_fig, 'file')
            fprintf('Extreme plot for %s at time %d already exists, skipping...\n', param_name, unique_times(i));
            continue;  % Skip if the extreme plot already exists
        end

        % Create probability matrix for the extreme combination
        prob_matrix = zeros(length(unique_param), length(unique_area));

        % Fill the probability matrix
        for v = 1:length(unique_param)
            for a = 1:length(unique_area)
                % Filter data for the current parameter and area combination
                current_combination_data = current_time_data( ...
                    current_time_data.(param_name) == unique_param(v) & ...
                    current_time_data.NormalizedArea == unique_area(a), :);

                % Calculate the probability for the current combination
                total_area_for_param = sum(current_time_data.NormalizedArea(current_time_data.(param_name) == unique_param(v)));
                prob = sum(current_combination_data.NormalizedArea) / total_area_for_param;

                % Store the probability in the matrix
                prob_matrix(v, a) = prob;
            end
        end

        % Plot the probability matrix
        figure;  % Create a new figure for each parameter combination
        bar(prob_matrix', 'grouped');  % Grouped bar plot
        set(gca, 'XTickLabel', unique_area);  % Set X-axis labels to the unique areas
        xlabel('Normalized Area');
        ylabel('Probability');

        % Create the legend with parameter values and units
        legend(arrayfun(@(x) sprintf('%s: %.2e', legend_labels{p}, x), unique_param, 'UniformOutput', false), 'Location', 'best');

        % Set the plot title for extreme particle size distributions
        title(sprintf('Extreme Particle Size Distribution (>2) for Time: %d s - %s', unique_times(i), legend_labels{p}));

        % Save the extreme plot as .png and .fig files
        saveas(gcf, extreme_plot_file_path_png);
        saveas(gcf, extreme_plot_file_path_fig);

        % Close the figure after saving
        close(gcf);
    end
end

end


