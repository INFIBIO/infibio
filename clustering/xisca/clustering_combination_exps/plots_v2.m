function plots_v2(df, path_save)

    if ~exist('path_save', 'var')
        path_save = '';
    end

    % df = mat_cleaned;
    clean_data = df(~isnan(df.Time), :);
    unique_times = unique(clean_data.Time);
    subfolder = 'plots_2';
    
    if ~exist(fullfile(path_save, subfolder), 'dir')
        mkdir(fullfile(path_save, subfolder));
    end
    
% Create combinations for parameters and their names
params_combinations = {'Zymolyase', 'Velocity', 'Temperature'};
params_names = {'Zymolyase', 'Velocity', 'Temperature'};

% Loop through each time point
for i = 1:length(unique_times)
    current_time_data = df(df.Time == unique_times(i), :);
    unique_zym = unique(current_time_data.Zymolyase);
    unique_velocity = unique(current_time_data.Velocity);
    unique_temperature = unique(current_time_data.Temperature);
    
    % Create combination plots for each parameter
    params_combinations = {unique_zym, unique_velocity, unique_temperature};
    params_names = {'Zymolyase', 'Velocity', 'Temperature'};
    
    for p = 1:length(params_combinations)
        unique_param = params_combinations{p};
        param_name = params_names{p};
        
        figure;  % Create a new figure for each plot
        hold on;
        
        % Loop through each unique parameter and plot the histograms
        for j = 1:length(unique_param)
            current_param_data = current_time_data(current_time_data.(param_name) == unique_param(j), :);
            
            % Remove zero values from the data
            current_param_data = current_param_data(current_param_data.NormalizedArea > 0, :);
            
            % Slight displacement by adding a small random noise to NormalizedArea
            displacement = 0.05 * j;  % Adjust this value to change displacement
            data_with_displacement = current_param_data.NormalizedArea + displacement;
            
            % Plot histogram with increased transparency and slight displacement
            histogram(data_with_displacement, 'BinWidth', 0.5, 'DisplayStyle', 'bar', ...
                'EdgeColor', 'none', 'FaceAlpha', 0.5);  % Increased transparency to 0.5
        end
        
        % Modify x-axis tick labels
        bin_edges = unique(current_param_data.NormalizedArea);
        tick_labels = cellfun(@(x) int2str(x), num2cell(bin_edges), 'UniformOutput', false); % Convert bin edges to string
        tick_labels(cellfun(@(x) str2double(x) == 7, tick_labels)) = {'>6'};        
        xticks(bin_edges);
        xticklabels(tick_labels);
        
        xlabel('Number of cells per cluster');
        ylabel('Particle size - normalized Area');
        title(['Time ', int2str(unique_times(i)), ' - ', param_name]);
        
        % Create legend
        legend_entries = cell(length(unique_param), 1);
        for j = 1:length(unique_param)
            legend_entries{j} = [param_name ' ' num2str(unique_param(j))];
        end
        legend(legend_entries, 'Location', 'best');
        
        hold off;
        
        % Save the individual plot to a file
        file_name = sprintf('histogram_plot_%s_%d.png', param_name, unique_times(i));
        file_path = fullfile(path_save, subfolder, file_name);
        saveas(gcf, file_path);
        file_name2 = sprintf('histogram_plot_%s_%d.fig', param_name, unique_times(i));
        file_path2 = fullfile(path_save, subfolder, file_name2);
        saveas(gcf, file_path2);
        close(gcf);
    end
end

% Filter out extreme values and create individual plots again
df_extreme = clean_data(clean_data.NormalizedArea > 2, :);

for i = 1:length(unique_times)
    current_time_data = df_extreme(df_extreme.Time == unique_times(i), :);
    unique_zym = unique(current_time_data.Zymolyase);
    
    figure;  % Create a new figure for each filtered plot
    hold on;

    for j = 1:length(unique_zym)
        current_zym_data = current_time_data(current_time_data.Zymolyase == unique_zym(j), :);
        
        % Remove zero values from the data
        current_zym_data = current_zym_data(current_zym_data.NormalizedArea > 0, :);
        
        % Slight displacement by adding a small random noise to NormalizedArea
        displacement = 0.05 * j;  % Adjust this value to change displacement
        data_with_displacement = current_zym_data.NormalizedArea + displacement;
        
        % Plot histogram with increased transparency and slight displacement
        histogram(data_with_displacement, 'BinWidth', 0.5, 'DisplayStyle', 'bar', ...
            'EdgeColor', 'none', 'FaceAlpha', 0.5);  % Increased transparency to 0.5
    end
    
    bin_edges = unique(current_time_data.NormalizedArea);
    tick_labels = cellfun(@(x) int2str(x), num2cell(bin_edges), 'UniformOutput', false); % Convert bin edges to string
    tick_labels(cellfun(@(x) str2double(x) == 7, tick_labels)) = {'>6'};        
    xticks(bin_edges);
    xticklabels(tick_labels);
    
    xlabel('Number of cells per cluster');
    ylabel('Particle size - normalized Area');
    title(['Particle size distribution (>2) for Time ', int2str(unique_times(i))]);
    
    % Create legend
    legend_entries = cell(length(unique_zym), 1);
    for j = 1:length(unique_zym)
        legend_entries{j} = ['Zymolyase ' num2str(unique_zym(j))];
    end
    legend(legend_entries, 'Location', 'best');
    
    hold off;
    
    % Save the individual plot to a file
    extreme_plot_file_name = sprintf('extreme_plot%d.png', unique_times(i));
    file_path = fullfile(path_save, subfolder, extreme_plot_file_name);
    saveas(gcf, file_path);
    extreme_plot_file_name2 = sprintf('extreme_plot%d.fig', unique_times(i));
    file_path2 = fullfile(path_save, subfolder, extreme_plot_file_name2);
    saveas(gcf, file_path2);
    close(gcf);
end
  
    % Create violin plot
    %figure;
    %distributionPlot(vertcat(clean_data.NormalizedArea), 'group', [clean_data.Time], 'histOpt', 2);
    %title('Distribution of Areas per Time Violin Plot');
    %xlabel('Time');
    %ylabel('Area');
    
    %file_name = 'violin_plot.png';
    %file_path = fullfile(path_save, subfolder, file_name);
    %saveas(gcf, file_path);
    %close(gcf);

    % Calculate probability and standard deviation
    probability = table(); % Initialize empty table

    for i = 1:length(unique_times)
        current_time_data = clean_data(clean_data.Time == unique_times(i,:), :);
        unique_zym = unique(current_time_data.Zymolyase);
        unique_velocity = unique(current_time_data.Velocity);
        unique_temperature = unique(current_time_data.Temperature);
        
        for k = 1:length(unique_zym)
            for v = 1:length(unique_velocity)
                for t = 1:length(unique_temperature)
                    current_combination_data = current_time_data(current_time_data.Zymolyase == unique_zym(k) & ...
                                                                current_time_data.Velocity == unique_velocity(v) & ...
                                                                current_time_data.Temperature == unique_temperature(t), :);
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
