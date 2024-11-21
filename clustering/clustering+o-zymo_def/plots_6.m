function plots_6(df, path_save)

    if nargin < 2
        path_save = '';
    end

    clean_data = df(~isnan(df.Time), :);
    unique_times = unique(clean_data.Time);
    unique_zym = unique(clean_data.Zymolyase);
    subfolder = 'plots';
    
    if ~exist(fullfile(path_save, subfolder), 'dir')
        mkdir(fullfile(path_save, subfolder));
    end
    
    % Calculate probability and standard deviation
    probability = table(); % Initialize empty table

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
                log_probability = current_time_data.probability .* current_time_data.area; % Adjust probability for single cell
                log_positive_sd = current_time_data.positive_sd .* current_time_data.area; % Adjust standard deviation for single cell
                
                % Set color based on zymolyase concentration
                if unique_zym(i) == 0
                    current_color = orange_colors(j, :);
                elseif unique_zym(i) == 0.1
                    current_color = blue_colors(j, :);
                else
                    current_color = [0 0 0]; % Default to black for other concentrations
                end

                % Use mod to cycle through markers if necessary
                marker_index = mod(i-1, length(markers)) + 1;

                % Plot using semilogarithmic scale for y-axis
                h = plot(current_time_data.area, log_probability, 'LineStyle', '-', ...
                    'Marker', markers{marker_index}, 'Color', current_color, ...
                    'MarkerFaceColor', current_color);
                errorbar(current_time_data.area, log_probability, log_positive_sd, 'LineStyle', 'none', ...
                    'Marker', markers{marker_index}, 'Color', current_color, ...
                    'MarkerFaceColor', current_color);

                % Store handle and legend entry
                handles = [handles; h];
                legend_entries{legend_index} = ['Zymolyase ' num2str(unique_zym(i)) ' mg/mL, Time ' num2str(unique_times(j))];
                legend_index = legend_index + 1;
            end
        end
    end

    xlabel('Number of Cells in Cluster');
    ylabel('Probability for a Single Cell (Semilog)');
    title('Probability of a Single Cell Being in a Cluster for Different Zymolyase Concentrations and Times');
    legend(handles, legend_entries, 'Location', 'Best', 'NumColumns', 2, 'FontSize', 6);

    % Save the plot to a file
    file_name = 'log_plot_probabilities_single_cell_all_zymolyase.png';
    file_name2 = 'log_plot_probabilities_single_cell_all_zymolyase.fig';
    file_path = fullfile(path_save, subfolder, file_name);
    file_path2 = fullfile(path_save, subfolder, file_name2);
    saveas(gcf, file_path);
    saveas(gcf, file_path2);
    close(gcf);
end
