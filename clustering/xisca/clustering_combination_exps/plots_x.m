function plots_x(df, path_save)

    if nargin < 2
        path_save = '';
    end

    % Filter out rows with NaN in the Time column
    clean_data = df(~isnan(df.Time), :);
    unique_times = unique(clean_data.Time);
    unique_zym = unique(clean_data.Zymolyase);  % Unique Zymolyase values
    unique_areas = unique(clean_data.NormalizedArea);  % Unique Areas
    
    subfolder = 'plots';
    
    % Create directory for plots if it does not exist
    if ~exist(fullfile(path_save, subfolder), 'dir')
        mkdir(fullfile(path_save, subfolder));
    end
    
    % Calculate probability and standard deviation
    probability = table(); % Initialize empty table

    for i = 1:length(unique_times)
        current_time_data = clean_data(clean_data.Time == unique_times(i), :);

        for k = 1:length(unique_zym)
            current_zym_data = current_time_data(current_time_data.Zymolyase == unique_zym(k), :);
            total_area = sum(current_zym_data.NormalizedArea);
            
            for j = 1:length(unique_areas)
                new_row = table();
                new_row.time = unique_times(i);
                new_row.zymolyase = unique_zym(k);
                filtered_data = current_zym_data(current_zym_data.NormalizedArea == unique_areas(j), :);
                sum_area = sum(filtered_data.NormalizedArea);
                
                new_row.area = unique_areas(j);
                new_row.probability = sum_area / total_area; % Calculate probability
                new_row.positive_sd = sqrt((sum_area / total_area) * (1 - sum_area / total_area) / sum_area); % Calculate standard deviation
                
                probability = [probability; new_row]; % Append row to probability table
            end
        end
    end

    % Plot 1: Individual Plots for Each Zymolyase and Time Combination
    for i = 1:length(unique_zym)
        figure('Position', [100, 100, 1200, 800]); % Set figure size
        num_subplots = length(unique_times);
        num_cols = ceil(sqrt(num_subplots));
        num_rows = ceil(num_subplots / num_cols);

        current_zym_data = probability(probability.zymolyase == unique_zym(i), :);
        for j = 1:length(unique_times)
            subplot(num_rows, num_cols, j);
            hold on;

            current_time_data = current_zym_data(current_zym_data.time == unique_times(j), :);

            if ~isempty(current_time_data)
                % Use semilogy for the plot
                log_probability = current_time_data.probability;
                log_positive_sd = current_time_data.positive_sd;

                % Plot using semilogarithmic scale for y-axis
                errorbar(current_time_data.area, log_probability, log_positive_sd, 'o');
                semilogy(current_time_data.area, log_probability, 'o-');

                title(['Time ' int2str(unique_times(j))]);
                xlabel('Number of Cells');
                ylabel('Probability (Semilog)');
            end
            hold off;
        end
        
        % Adjust layout and add a main title
        sgtitle(['Probability of Each Number of Cells for ' num2str(unique_zym(i)) ' mg/mL Zymolyase']);
        
        % Save the plot to a file
        file_name = sprintf('log_plot_probabilities_%d.tif', unique_zym(i));
        file_name2 = sprintf('log_plot_probabilities_%d.fig', unique_zym(i));
        file_path = fullfile(path_save, subfolder, file_name);
        file_path2 = fullfile(path_save, subfolder, file_name2);
        saveas(gcf, file_path);
        saveas(gcf, file_path2);
        close(gcf);
    end

    % Plot 2: Combined Plot for Each Zymolyase with All Times Overlapped
    for i = 1:length(unique_zym)
        figure('Position', [100, 100, 1200, 800]); % Set figure size
        hold on;

        current_zym_data = probability(probability.zymolyase == unique_zym(i), :);
        legend_entries = cell(length(unique_times), 1);

        for j = 1:length(unique_times)
            current_time_data = current_zym_data(current_zym_data.time == unique_times(j), :);

            if ~isempty(current_time_data)
                % Use semilogy for the plot
                log_probability = current_time_data.probability;
                log_positive_sd = current_time_data.positive_sd;

                % Plot using semilogarithmic scale for y-axis
                errorbar(current_time_data.area, log_probability, log_positive_sd, 'o-');

                legend_entries{j} = ['Time ' num2str(unique_times(j))];
            end
        end

        % Ensure all entries in legend_entries are strings and remove empty entries
        legend_entries = legend_entries(~cellfun('isempty', legend_entries)); % Remove empty cells
        legend_entries = cellfun(@(x) string(x), legend_entries, 'UniformOutput', false); % Convert all to strings

        xlabel('Number of Cells');
        ylabel('Probability (Semilog)');
        title(['Probability of Each Number of Cells for ' num2str(unique_zym(i)) ' mg/mL Zymolyase']);
        legend(legend_entries, 'Location', 'Best');

        % Save the plot to a file
        file_name = sprintf('log_plot_probabilities_overlapped_%d.tif', unique_zym(i));
        file_name2 = sprintf('log_plot_probabilities_overlapped_%d.fig', unique_zym(i));
        file_path = fullfile(path_save, subfolder, file_name);
        file_path2 = fullfile(path_save, subfolder, file_name2);
        saveas(gcf, file_path);
        saveas(gcf, file_path2);
        close(gcf);
    end

    % Plot 3: Combined Plot for All Zymolyase Concentrations and Times
    % Define markers for different zymolyase concentrations
    markers = {'o', 's'}; % Circle for zymolyase 0, square for zymolyase 0.1
    blue_colors = flipud([linspace(0.3, 0, length(unique_times))', linspace(0.5, 0, length(unique_times))', linspace(1, 0, length(unique_times))']);
    orange_colors = flipud([linspace(1, 1, length(unique_times))', linspace(0.5, 0.3, length(unique_times))', linspace(0, 0, length(unique_times))']);
    
    % Create a single figure for all zymolyase concentrations
    figure('Position', [100, 100, 1200, 800]); % Set figure size
    hold on;
    
    legend_entries = {};
    legend_index = 1;

    % Store handles for the legend
    handles = [];

    for i = 1:length(unique_zym)
        current_zym_data = probability(probability.zymolyase == unique_zym(i), :);

        for j = 1:length(unique_times)
            current_time_data = current_zym_data(current_zym_data.time == unique_times(j), :);

            if ~isempty(current_time_data)
                % Use semilogy for the plot
                log_probability = current_time_data.probability;
                log_positive_sd = current_time_data.positive_sd;
                
                % Set color based on zymolyase concentration
                if unique_zym(i) == 0
                    current_color = orange_colors(j, :);
                elseif unique_zym(i) == 0.1
                    current_color = blue_colors(j, :);
                else
                    current_color = [0 0 0]; % Default to black for other concentrations
                end

                % Plot using semilogarithmic scale for y-axis
                h = plot(current_time_data.area, log_probability, 'LineStyle', '-', ...
                    'Marker', markers{min(i, length(markers))}, 'Color', current_color, ...
                    'MarkerFaceColor', current_color);
                errorbar(current_time_data.area, log_probability, log_positive_sd, 'LineStyle', 'none', ...
                    'Marker', markers{min(i, length(markers))}, 'Color', current_color, ...
                    'MarkerFaceColor', current_color);

                % Store handle and legend entry
                handles = [handles; h];
                legend_entries{legend_index} = ['Zymolyase ' num2str(unique_zym(i)) ' mg/mL, Time ' num2str(unique_times(j))];
                legend_index = legend_index + 1;
            end
        end
    end

    xlabel('Number of Cells');
    ylabel('Probability (Semilog)');
    title('Probability of Each Number of Cells for Different Zymolyase Concentrations');
    
    % Add legend and save the plot
    legend(handles, legend_entries, 'Location', 'Best', 'NumColumns', 2, 'FontSize', 6);

    % Save the plot to a file
    file_name = sprintf('log_plot_probabilities_all_concentrations_overlapped.tif');
    file_name2 = sprintf('log_plot_probabilities_all_concentrations_overlapped.fig');
    file_path = fullfile(path_save, subfolder, file_name);
    file_path2 = fullfile(path_save, subfolder, file_name2);
    saveas(gcf, file_path);
    saveas(gcf, file_path2);
    close(gcf);
end
