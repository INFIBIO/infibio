function plots_v3(df, path_save)

    if ~exist('path_save', 'var')
        path_save = '';
    end

    % df = mat_cleaned;
    clean_data = df(~isnan(df.Time), :);
    unique_times = unique(clean_data.Time);
    subfolder = 'plots_3';
    
    if ~exist(fullfile(path_save, subfolder), 'dir')
        mkdir(fullfile(path_save, subfolder));
    end
    
% Loop through each unique time point for regular plots
for i = 1:length(unique_times)
    current_time_data = df(df.Time == unique_times(i), :);  % Filter data for the current time
    unique_velocity = unique(current_time_data.Velocity);  % Unique velocities
    unique_temperature = unique(current_time_data.Temperature);  % Unique temperatures
    unique_zym = unique(current_time_data.Zymolyase);  % Unique zymolyase concentrations
    unique_conc = unique(current_time_data.Concentration);


    % Regular Plot: Probability Distribution for All Data
    figure;  % Create a new figure for each time point
    hold on;  % Hold on to plot multiple bars on the same plot
    
    % Color map for different conditions
    colors = lines(length(unique_zym) * length(unique_velocity) * length(unique_temperature)*length(unique_conc));
    
    legend_entries = {};  % Initialize legend entries
    color_index = 1;  % Initialize color index for color map

    % Loop through each unique combination of Velocity, Temperature, and Zymolyase
    for v = 1:length(unique_velocity)
        for t = 1:length(unique_temperature)
            for z = 1:length(unique_zym)
                for c = 1:lenth(unique_conc)
                % Filter data for the current combination
                current_combination_data = current_time_data( ...
                    current_time_data.Velocity == unique_velocity(v) & ...
                    current_time_data.Temperature == unique_temperature(t) & ...
                    current_time_data.Zymolyase == unique_zym(z) & current_time_data.Concentration == unique_conc(c), :);
                
                % Remove zero values from the data
                current_combination_data = current_combination_data(current_combination_data.NormalizedArea > 0, :);
                
                % Plot histogram with slight displacement and unique color
                if ~isempty(current_combination_data)
                    histogram(current_combination_data.NormalizedArea + 0.05 * (color_index - 1), 'BinWidth', 0.5, ...
                        'DisplayStyle', 'bar', 'EdgeColor', 'none', 'FaceColor', colors(color_index, :), 'FaceAlpha', 0.5);
                    
                    % Add legend entry for the current combination
                    legend_entries{end + 1} = sprintf('Velocity %d, Temp %d, Zym %0.2f, Conc %2e', ...
                        unique_velocity(v), unique_temperature(t), unique_zym(z), unique_conc(c));
                    
                    % Increment color index
                    color_index = color_index + 1;
                end
            end
        end
        end
    end
    
    % Customize x-axis tick labels to remove bins with 0 counts
    bin_edges = unique(current_time_data.NormalizedArea);
    bin_edges(bin_edges == 0) = [];  % Remove zeros from x-axis ticks
    xticks(bin_edges);
    tick_labels = cellfun(@(x) int2str(x), num2cell(bin_edges), 'UniformOutput', false);  % Convert bin edges to string
    tick_labels(cellfun(@(x) str2double(x) == 7, tick_labels)) = {'>6'};  % Replace 7 with '>6'
    xticklabels(tick_labels);
    
    % Set plot labels and title
    xlabel('Number of cells per cluster', 'FontSize', 12);
    ylabel('Probability - normalized Area', 'FontSize', 12);
    title(['Probability Distribution for Time ', num2str(unique_times(i))], 'FontSize', 14);
    
    % Add legend with all combinations
    legend(legend_entries, 'Location', 'best', 'FontSize', 10);
    
    hold off;  % Release hold on the current figure
    
    % Save each plot to a file
    file_name = sprintf('combined_plot_time_%d.png', unique_times(i));
    file_path = fullfile(path_save, subfolder, file_name);
    saveas(gcf, file_path);
    file_name2 = sprintf('combined_plot_time_%d.fig', unique_times(i));
    file_path2 = fullfile(path_save, subfolder, file_name2);
    saveas(gcf, file_path2);
    close(gcf);

    % Extreme Plot: Only for NormalizedArea > 2
    df_extreme = current_time_data(current_time_data.NormalizedArea > 2, :);  % Filter data for extreme values

    % Extreme Plot for each combination
    if ~isempty(df_extreme)
        figure;  % Create a new figure for each time point
        hold on;  % Hold on to plot multiple bars on the same plot
        
        legend_entries = {};  % Reset legend entries
        color_index = 1;  % Reset color index for color map
        
        % Loop through each unique combination of Velocity, Temperature, and Zymolyase
        for v = 1:length(unique_velocity)
            for t = 1:length(unique_temperature)
                for z = 1:length(unique_zym)
                    for c = 1:lenth(unique_conc)
                    % Filter data for the current combination
                    current_combination_data = df_extreme( ...
                        df_extreme.Velocity == unique_velocity(v) & ...
                        df_extreme.Temperature == unique_temperature(t) & ...
                        df_extreme.Zymolyase == unique_zym(z) & df_extreme.Concentration == unique_conc(c), :);
                    
                    % Plot histogram with slight displacement and unique color
                    if ~isempty(current_combination_data)
                        histogram(current_combination_data.NormalizedArea + 0.05 * (color_index - 1), 'BinWidth', 0.5, ...
                            'DisplayStyle', 'bar', 'EdgeColor', 'none', 'FaceColor', colors(color_index, :), 'FaceAlpha', 0.5);
                        
                        % Add legend entry for the current combination
                        legend_entries{end + 1} = sprintf('Velocity %d, Temp %d, Zym %0.2f, Conc %2e', ...
                            unique_velocity(v), unique_temperature(t), unique_zym(z), unique_conc(c));
                        
                        % Increment color index
                        color_index = color_index + 1;
                    end
                end
            end
        end
        
        % Customize x-axis tick labels to remove bins with 0 counts
        bin_edges = unique(df_extreme.NormalizedArea);
        bin_edges(bin_edges == 0) = [];  % Remove zeros from x-axis ticks
        xticks(bin_edges);
        tick_labels = cellfun(@(x) int2str(x), num2cell(bin_edges), 'UniformOutput', false);  % Convert bin edges to string
        tick_labels(cellfun(@(x) str2double(x) == 7, tick_labels)) = {'>6'};  % Replace 7 with '>6'
        xticklabels(tick_labels);
        
        % Set plot labels and title
        xlabel('Number of cells per cluster', 'FontSize', 12);
        ylabel('Particle size - normalized Area', 'FontSize', 12);
        title(['Particle size distribution (>2) for Time ', num2str(unique_times(i))], 'FontSize', 14);
        
        % Add legend with all combinations
        legend(legend_entries, 'Location', 'bestoutside', 'FontSize', 10);
        
        hold off;  % Release hold on the current figure
        
        % Save each plot to a file
        file_name = sprintf('extreme_combined_plot_time_%d.png', unique_times(i));
        file_path = fullfile(path_save, subfolder, file_name);
        saveas(gcf, file_path);
        file_name2 = sprintf('extreme_combined_plot_time_%d.fig', unique_times(i));
        file_path2 = fullfile(path_save, subfolder, file_name2);
        saveas(gcf, file_path2);
        close(gcf);
    end
    end
end


    % Calculate probability and standard deviation
    probability = table(); % Initialize empty table

    for i = 1:length(unique_times)
        current_time_data = clean_data(clean_data.Time == unique_times(i,:), :);
        unique_zym = unique(current_time_data.Zymolyase);
        unique_velocity = unique(current_time_data.Velocity);
        unique_temperature = unique(current_time_data.Temperature);
        unique_conc = unique(current_time_data.Concentration);
        
        for k = 1:length(unique_zym)
            for v = 1:length(unique_velocity)
                for t = 1:length(unique_temperature)
                    for c = 1:length(unique_conc(c))
                    current_combination_data = current_time_data(current_time_data.Zymolyase == unique_zym(k) & ...
                                                                current_time_data.Velocity == unique_velocity(v) & ...
                                                                current_time_data.Temperature == unique_temperature(t) & current_time_data.Concentration == unique_conc(c), :);
                    unique_areas = unique(current_combination_data.NormalizedArea);
                    total_area = sum(current_combination_data.NormalizedArea);
                    
                    for j = 1:length(unique_areas)
                        new_row = table();
                        new_row.time = unique_times(i);
                        new_row.zymolyase = unique_zym(k);
                        new_row.velocity = unique_velocity(v);
                        new_row.temperature = unique_temperature(t);
                        filtered_data = current_combination_data(current_combination_data.NormalizedArea == unique_areas(j), :);
                        sum_area = sum(filtered_data.NormalizedArea);
                        
                        new_row.area = unique_areas(j);
                        new_row.probability = sum_area / total_area; % Calculate probability
                        new_row.positive_sd = sqrt((sum_area / total_area) * (1 - sum_area / total_area) / sum_area); % Calculate standard deviation
                        
                        probability = [probability; new_row]; % Append row to probability table
                    end
                end
            end
        end
    end

    % Plot the combined probability
    for k = 1:length(unique_zym)
        for v = 1:length(unique_velocity)
            for t = 1:length(unique_temperature)
                figure;
                hold on;
                legend_entries = {}; 
                current_combination_data = probability(probability.zymolyase == unique_zym(k) & ...
                                                       probability.velocity == unique_velocity(v) & ...
                                                       probability.temperature == unique_temperature(t), :);
                for j = 1:length(unique_times)
                    current_time_data = current_combination_data(current_combination_data.time == unique_times(j), :);
                    errorbar(current_time_data.area, current_time_data.probability, current_time_data.positive_sd);
                    plot(current_time_data.area, current_time_data.probability, 'o-');
                    
                    % Store legend entry for current time
                    legend_entries{end+1} = ['Time ' int2str(unique_times(j))];
                end
                
                legend(legend_entries);
                
                % Modify x-axis tick labels
                bin_edges = unique(probability.area);
                tick_labels = cellfun(@(x) int2str(x), num2cell(bin_edges), 'UniformOutput', false); % Convert bin edges to string
                tick_labels(cellfun(@(x) str2double(x) == 7, tick_labels)) = {'>6'};
                xticks(bin_edges);
                xticklabels(tick_labels);
                
                xlabel('Number of Cells');
                ylabel('Probability');
                title(['Probability of Each Number of Cells for Time at Zymolyase ', num2str(unique_zym(k)), ...
                       ' mg/mL, Velocity ', num2str(unique_velocity(v)), ', Temperature ', num2str(unique_temperature(t))], 'FontSize', 8);
                
                % Save the plot to a file
                file_name = sprintf('plot_probabilities_combined_%d_%d_%d.png', unique_zym(k), unique_velocity(v), unique_temperature(t));
                file_name2 = sprintf('plot_probabilities_combined_%d_%d_%d.fig', unique_zym(k), unique_velocity(v), unique_temperature(t));
                file_path = fullfile(path_save, subfolder, file_name);
                file_path2 = fullfile(path_save, subfolder, file_name2);
                saveas(gcf, file_path);
                saveas(gcf, file_path2);
                close(gcf);
            end
        end
    end
end
