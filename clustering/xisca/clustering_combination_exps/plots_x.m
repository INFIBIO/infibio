function plots_x(df, path_save)

    if nargin < 2
        path_save = '';
    end

    clean_data = df(~isnan(df.Time), :);
    unique_times = unique(clean_data.Time);
    subfolder = 'plots';
    
    if ~exist(fullfile(path_save, subfolder), 'dir')
        mkdir(fullfile(path_save, subfolder));
    end
    
    % Calculate probability and standard deviation
    probability = table(); % Initialize empty table

    unique_zym = unique(clean_data.Zymolyase); % Moved outside the loop as it is static

    for i = 1:length(unique_times)
        current_time_data = clean_data(clean_data.Time == unique_times(i), :);

        for k = 1:length(unique_zym)
            current_zym_data = current_time_data(current_time_data.Zymolyase == unique_zym(k), :);
            unique_areas = unique(current_zym_data.NormalizedArea);
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

            % Use actual data
            % Note: This example uses random data for illustration. Replace with actual data variables.
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

 % Define markers for different zymolyase concentrations
    markers = {'o', 's'}; % Circle for zymolyase 0, square for zymolyase 0.1
    % Generate gradient blue colors for zymolyase 0.1 samples
    blue_colors = flipud([linspace(0.3, 0, length(unique_times))', linspace(0.5, 0, length(unique_times))', linspace(1, 0, length(unique_times))']);
    % Generate gradient orange colors for zymolyase 0 samples
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
                    'Marker', markers{i}, 'Color', current_color, ...
                    'MarkerFaceColor', current_color);
                errorbar(current_time_data.area, log_probability, log_positive_sd, 'LineStyle', 'none', ...
                    'Marker', markers{i}, 'Color', current_color, ...
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
    title('Probability of Each Number of Cells for Different Zymolyase Concentrations and Times');
    legend(handles, legend_entries, 'Location', 'Best');

    % Save the plot to a file
    file_name = 'log_plot_probabilities_all_zymolyase.tif';
    file_name2 = 'log_plot_probabilities_all_zymolyase.fig';
    file_path = fullfile(path_save, subfolder, file_name);
    file_path2 = fullfile(path_save, subfolder, file_name2);
    saveas(gcf, file_path);
    saveas(gcf, file_path2);
    close(gcf);

% Define markers for different number of cells and zymolyase concentrations
    markers_0 = {'o', 's', '^', 'd', 'v', '>', '<'}; % Marker for zymolyase 0
    markers_0_1 = {'x', '*', '.', 's', 'd', '^', 'v'}; % Marker for zymolyase 0.1
    
    % Define colors for each combination of number of cells and zymolyase concentration
    num_colors = lines(length(unique_areas) * length(unique_zym));
    
    % Create a single figure for all zymolyase concentrations
    figure('Position', [100, 100, 1200, 800]); % Set figure size
    hold on;
    
    legend_entries = {}; % Initialize legend entries
    legend_index = 1;

    for k = 1:length(unique_zym)
        for j = 1:length(unique_areas)
            current_zym_data = probability(probability.zymolyase == unique_zym(k) & probability.area == unique_areas(j), :);

            if ~isempty(current_zym_data)
                % Use semilogy for the plot
                log_probability = current_zym_data.probability;
                log_positive_sd = current_zym_data.positive_sd;

                % Assign color and marker based on the combination of number of cells and zymolyase concentration
                current_color = num_colors((k - 1) * length(unique_areas) + j, :);
                if unique_zym(k) == 0
                    current_marker = markers_0{j}; % Use different markers for zymolyase 0 samples
                    zym_str = 'Zymolyase 0';
                else
                    current_marker = markers_0_1{j}; % Use different markers for zymolyase 0.1 samples
                    zym_str = 'Zymolyase 0.1';
                end

                % Plot using semilogarithmic scale for y-axis
                plot(current_zym_data.time, log_probability, 'LineStyle', '-', ...
                    'Marker', current_marker, 'Color', current_color, ...
                    'MarkerFaceColor', current_color);

                errorbar(current_zym_data.time, log_probability, log_positive_sd, 'LineStyle', 'none', ...
                    'Marker', current_marker, 'Color', current_color, ...
                    'MarkerFaceColor', current_color);

                % Construct legend entry
                legend_entries{legend_index} = [zym_str ', Number of Cells ' num2str(unique_areas(j))];
                legend_index = legend_index + 1;
            end
        end
    end

    xlabel('Time');
    ylabel('Probability (Semilog)');
    title('Probability of Each Number of Cells for Different Times');
    legend(legend_entries, 'Location', 'Best');

    % Save the plot to a file
    file_name = 'log_plot_probabilities_all_cells.tif';
    file_name2 = 'log_plot_probabilities_all_cells.fig';
    file_path = fullfile(path_save, subfolder, file_name);
    file_path2 = fullfile(path_save, subfolder, file_name2);
    saveas(gcf, file_path);
    saveas(gcf, file_path2);
    close(gcf);

        % Define markers for each unique number of cells
    markers = {'o', 's', '^', 'd', 'v', '>', '<'};
    legend_entries_markers = {'Number of cells 1', 'Number of cells 2', 'Number of cells 3', 'Number of cells 4', 'Number of cells 5', 'Number of cells 6', 'Number of cells 7'};
    
    % Define colors for each zymolyase condition
    colors = {[0, 0, 1], [1, 0.5, 0]}; % Blue for zymolyase 0, Orange for zymolyase 0.1
    legend_entries_colors = {'Zymolyase 0', 'Zymolyase 0.1'};
    
    % Create a single figure for all zymolyase concentrations
    figure('Position', [100, 100, 1200, 800]); % Set figure size
    hold on;

    % Initialize handles and labels for the legend
    handles = gobjects(0);
    labels = {};

    % Plot the data with different markers and colors
    for k = 1:length(unique_zym)
        for j = 1:length(unique_areas)
            current_zym_data = probability(probability.zymolyase == unique_zym(k) & probability.area == unique_areas(j), :);

            if ~isempty(current_zym_data)
                % Use semilogy for the plot
                log_probability = current_zym_data.probability;
                log_positive_sd = current_zym_data.positive_sd;

                % Assign marker and color based on zymolyase condition
                current_marker = markers{j};
                current_color = colors{k};

                % Plot using semilogarithmic scale for y-axis
                h = plot(current_zym_data.time, log_probability, 'LineStyle', '-', ...
                    'Marker', current_marker, 'Color', current_color, ...
                    'MarkerFaceColor', current_color, 'MarkerSize', 6);

                % Store handles and labels
                handles(end+1) = h;
                labels{end+1} = [legend_entries_markers{j} ', ' legend_entries_colors{k}];

                % Add lines between markers
                if length(current_zym_data.time) > 1
                    plot(current_zym_data.time, log_probability, 'Color', current_color);
                end
            end
        end
    end

    % Create a single combined legend
    legend(handles, labels, 'Location', 'best');

    % Add axis labels
    xlabel('Time');
    ylabel('Probability (Semilog)');

    hold off;

    % Save the plot to a file
    file_name = 'log_plot_probabilities_all_cells.tif';
    file_name2 = 'log_plot_probabilities_all_cells.fig';
    file_path = fullfile(path_save, subfolder, file_name);
    file_path2 = fullfile(path_save, subfolder, file_name2);
    saveas(gcf, file_path);
    saveas(gcf, file_path2);
    close(gcf);
end
