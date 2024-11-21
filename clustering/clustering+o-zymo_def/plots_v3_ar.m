function plots_v3_ar(df, path_save)
% Function to generate probability plots and statistical calculations based on data combinations
% involving Time, Velocity, Zymolyase, Temperature, and Normalized Area. The function generates
% both regular and extreme plots, and computes probabilities and standard deviations for various 
% parameter combinations.


    % Check if path_save exists, if not set it to an empty string
    if ~exist('path_save', 'var')
        path_save = '';
    end

    % Filter out rows where Time is NaN
    clean_data = df(~isnan(df.Time), :);
    unique_times = unique(clean_data.Time);  % Unique time points
    subfolder = 'plots_3';  % Subfolder to save the plots

    % Create the subfolder if it doesn't exist
    if ~exist(fullfile(path_save, subfolder), 'dir')
        mkdir(fullfile(path_save, subfolder));
    end

    % Loop through each unique time point to generate regular plots
    for i = 1:length(unique_times)
        % Filter data for the current time point
        current_time_data = df(df.Time == unique_times(i), :);  
        unique_velocity = unique(current_time_data.Velocity);  % Unique velocities
        unique_area = unique(current_time_data.NormalizedArea);  % Unique areas
        
        % Create a matrix where rows represent velocities and columns represent areas
        prob_matrix = zeros(length(unique_velocity), length(unique_area));

        % Populate the matrix with probability values for each combination of velocity and area
        for v = 1:length(unique_velocity)
            for a = 1:length(unique_area)
                % Filter data by current velocity and area
                current_combination_data = current_time_data( ...
                    current_time_data.Velocity == unique_velocity(v) & ...
                    current_time_data.NormalizedArea == unique_area(a), :);
                
                % Calculate the probability for the current combination
                total_area_for_velocity = sum(current_time_data.NormalizedArea(current_time_data.Velocity == unique_velocity(v)));
                prob = sum(current_combination_data.NormalizedArea) / total_area_for_velocity;

                % Store the probability in the matrix
                prob_matrix(v, a) = prob;
            end
        end

        % Generate and save the plot for the current time point
        figure;
        bar(prob_matrix', 'grouped');  % Grouped bar chart
        set(gca, 'XTickLabel', unique_area);  % Set X-axis labels to unique areas
        xlabel('Cluster size (Number of cells)');
        ylabel('Probability');
        legend(arrayfun(@(x) sprintf('Velocity: %.2f rpm', x), unique_velocity, 'UniformOutput', false), 'Location', 'best');
        title(['Time: ', num2str(unique_times(i)), ' s']);
        
        % Save plot as .png and .fig
        file_name_png = sprintf('combined_plot_time_%d.png', unique_times(i));
        file_path_png = fullfile(path_save, subfolder, file_name_png);
        saveas(gcf, file_path_png);

        file_name_fig = sprintf('combined_plot_time_%d.fig', unique_times(i));
        file_path_fig = fullfile(path_save, subfolder, file_name_fig);
        saveas(gcf, file_path_fig);
        
        close(gcf);  % Close the figure after saving
    end

    % Generate extreme plots for NormalizedArea > 2
    df_extreme = current_time_data(current_time_data.NormalizedArea > 2, :);  % Filter extreme values
    for i = 1:length(unique_times)
        if ~isempty(df_extreme)  % Only proceed if there is data for extreme values
            figure;
            hold on;
            legend_entries = {};  % Initialize legend entries
            color_index = 1;

            % Get unique combinations of parameters for extreme cases
            unique_temperature = unique(df_extreme.Temperature);  % Unique temperatures
            unique_zym = unique(df_extreme.Zymolyase);  % Unique Zymolyase values
            unique_conc = unique(df_extreme.Concentration);  % Unique concentrations
            unique_velocity = unique(df_extreme.Velocity);  % Unique velocities

            % Create a matrix for probabilities
            prob_matrix_extreme = zeros(length(unique_velocity), length(unique_area));

            % Populate the matrix with probabilities for each extreme combination
            for v = 1:length(unique_velocity)
                for a = 1:length(unique_area)
                    current_combination_data = df_extreme( ...
                        df_extreme.Velocity == unique_velocity(v) & ...
                        df_extreme.NormalizedArea == unique_area(a), :);
                    
                    total_area_for_velocity = sum(df_extreme.NormalizedArea(df_extreme.Velocity == unique_velocity(v)));
                    prob = sum(current_combination_data.NormalizedArea) / total_area_for_velocity;

                    prob_matrix_extreme(v, a) = prob;
                end
            end

            % Filter out columns with no values in the probability matrix
            non_zero_idx = any(prob_matrix_extreme > 0, 1);
            filtered_prob_matrix_extreme = prob_matrix_extreme(:, non_zero_idx);
            filtered_unique_area = unique_area(non_zero_idx);

            % Plot the filtered extreme probability matrix
            bar(filtered_prob_matrix_extreme', 'grouped');
            set(gca, 'XTickLabel', filtered_unique_area);  
            xlabel('Normalized Area (Units)');
            ylabel('Probability');
            legend(arrayfun(@(x) sprintf('Velocity: %.2f rpm', x), unique_velocity, 'UniformOutput', false), 'Location', 'best');
            title(['Extreme Particle Size Distribution for Time ', num2str(unique_times(i)), ' s (Normalized Area > 2)']);

            % Save the extreme plot
            file_name_extreme_png = sprintf('extreme_plot_time_%d.png', unique_times(i));
            file_path_extreme_png = fullfile(path_save, subfolder, file_name_extreme_png);
            saveas(gcf, file_path_extreme_png);

            file_name_extreme_fig = sprintf('extreme_plot_time_%d.fig', unique_times(i));
            file_path_extreme_fig = fullfile(path_save, subfolder, file_name_extreme_fig);
            saveas(gcf, file_path_extreme_fig);
            
            close(gcf);  % Close the figure after saving
        end
    end

    % Compute probabilities and standard deviations for combinations of parameters
    probability = table();  % Initialize an empty table to store results

    for i = 1:length(unique_times)
        current_time_data = clean_data(clean_data.Time == unique_times(i), :);
        unique_zym = unique(current_time_data.Zymolyase);
        unique_velocity = unique(current_time_data.Velocity);
        unique_temperature = unique(current_time_data.Temperature);
        unique_conc = unique(current_time_data.Concentration);

        for k = 1:length(unique_zym)
            for v = 1:length(unique_velocity)
                for t = 1:length(unique_temperature)
                    for c = 1:length(unique_conc)
                        current_combination_data = current_time_data( ...
                            current_time_data.Zymolyase == unique_zym(k) & ...
                            current_time_data.Velocity == unique_velocity(v) & ...
                            current_time_data.Temperature == unique_temperature(t) & ...
                            current_time_data.Concentration == unique_conc(c), :);
                        unique_areas = unique(current_combination_data.NormalizedArea);
                        total_area = sum(current_combination_data.NormalizedArea);

                        for j = 1:length(unique_areas)
                            new_row = table();
                            new_row.time = unique_times(i);
                            new_row.zymoliase = unique_zym(k);
                            new_row.velocity = unique_velocity(v);
                            new_row.temperature = unique_temperature(t);
                            new_row.concentration = unique_conc(c);
                            filtered_data = current_combination_data(current_combination_data.NormalizedArea == unique_areas(j), :);
                            sum_area = sum(filtered_data.NormalizedArea);

                            new_row.area = unique_areas(j);
                            new_row.probability = sum_area / total_area;  % Probability calculation
                            new_row.positive_sd = sqrt((sum_area / total_area) * (1 - sum_area / total_area) / sum_area);  % Standard deviation

                            probability = [probability; new_row];  % Append row to the table
                        end
                    end
                end
            end
        end
    end

    % Plot combined probability charts
    unique_zym = unique(probability.zymoliase);
    unique_velocity = unique(probability.velocity);
    subfolder = 'plots_combined';

    if ~exist(fullfile(path_save, subfolder), 'dir')
        mkdir(fullfile(path_save, subfolder));
    end

    for i = 1:length(unique_times)
        current_time_data = probability(probability.time == unique_times(i), :);

        % Initialize the probability matrix
        prob_matrix = zeros(length(unique_velocity), length(unique_zym));

        % Fill the matrix with probability values for each combination
        for v = 1:length(unique_velocity)
            for z = 1:length(unique_zym)
                current_combination_data = current_time_data( ...
                    current_time_data.velocity == unique_velocity(v) & ...
                    current_time_data.zymoliase == unique_zym(z), :);

                total_area_for_velocity = sum(current_time_data.area(current_time_data.velocity == unique_velocity(v)));
                if total_area_for_velocity > 0
                    prob = sum(current_combination_data.area) / total_area_for_velocity;
                else
                    prob = 0;  % Set probability to zero if no data is available
                end
                
                prob_matrix(v, z) = prob;
            end
        end

        % Plot the combined probability matrix
        figure;
        bar(prob_matrix', 'grouped');  % Grouped bar chart
        set(gca, 'XTickLabel', unique_zym);  % X-axis labels for Zymolyase
        xlabel('Zymolyase (mg/mL)');
        ylabel('Probability');
        legend(arrayfun(@(x) sprintf('Velocity: %.2f rpm', x), unique_velocity, 'UniformOutput', false), 'Location', 'best');
        title(['Time: ', num2str(unique_times(i)), ' s']);

        % Save the combined plot as .png and .fig
        file_name_combined_png = sprintf('combined_plot_time_%d.png', unique_times(i));
        file_path_combined_png = fullfile(path_save, subfolder, file_name_combined_png);
        saveas(gcf, file_path_combined_png);

        file_name_combined_fig = sprintf('combined_plot_time_%d.fig', unique_times(i));
        file_path_combined_fig = fullfile(path_save, subfolder, file_name_combined_fig);
        saveas(gcf, file_path_combined_fig);

        close(gcf);  % Close the figure after saving
    end
end