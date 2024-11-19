function plots_ar(df, path_save)

    if ~exist('path_save', 'var')
        path_save = '';
    end

    % df = mat_cleaned;
    clean_data = df(~isnan(df.Time), :);
    unique_times = unique(clean_data.Time);
    subfolder = 'plots';
    
    if ~exist(fullfile(path_save, subfolder), 'dir')
        mkdir(fullfile(path_save, subfolder));
    end
    
    % Histogram plots for area distribution
    for i = 1:length(unique_times)
        current_time_data = df(df.Time == unique_times(i,:),:);
        unique_zym = unique(current_time_data.Zymolyase);
        unique_velocity = unique(current_time_data.Velocity);
        unique_temperature = unique(current_time_data.Temperature);
        unique_concentration = unique(current_time_data.Concentration);
        
        % Create combination plots
        params_combinations = {unique_zym, unique_velocity, unique_temperature, unique_concentration};
        params_names = {'Zymolyase', 'Velocity', 'Temperature', 'Concentration'};
        
        for p = 1:length(params_combinations)
            unique_param = params_combinations{p};
            param_name = params_names{p};
            figure;
            hold on;
            
            for j = 1:length(unique_param)
                current_param_data = current_time_data(current_time_data.(param_name) == unique_param(j),:);
                histogram(current_param_data.NormalizedArea, 'DisplayStyle', 'bar', 'EdgeColor', 'none');
            end
            % Modify x-axis tick labels
            bin_edges = unique(current_time_data.NormalizedArea);
            tick_labels = cellfun(@(x) int2str(x), num2cell(bin_edges), 'UniformOutput', false); % Convert bin edges to string
            tick_labels(cellfun(@(x) str2double(x) == 7, tick_labels)) = {'>6'};        
            xticks(bin_edges);
            xticklabels(tick_labels);
            
            xlabel('Number of cells per cluster');
            ylabel('Particle size - normalized Area');
            title(['Particle size distribution for Time ', int2str(unique_times(i)), ' - ', param_name]);
            hold off;
            
            % Create legend
            legend_entries = cell(length(unique_param), 1);
            for j = 1:length(unique_param)
                legend_entries{j} = [param_name ' ' num2str(unique_param(j))];
            end
            legend(legend_entries);

            file_name = sprintf('histogram_plot_%s_%d.png', param_name, unique_times(i));
            file_path = fullfile(path_save, subfolder, file_name);
            saveas(gcf, file_path);
            close(gcf);
        end
    end
    
    % Filter out extreme values
    
    df_extreme = clean_data(clean_data.NormalizedArea > 2, :);
    
    for i = 1:length(unique_times)
        current_time_data = df_extreme(df_extreme.Time == unique_times(i,:), :);
        unique_zym = unique(current_time_data.Zymolyase);
        unique_conc = unique(current_time_data.Concentration);
        
        figure;
        hold on;

        % Inicializamos un contador para las leyendas
        legend_counter = 1;
        
        for j = 1:length(unique_zym)
            for c = 1:length(unique_conc)
                current_zym_data = current_time_data(current_time_data.Zymolyase == unique_zym(j) & current_time_data.Concentration == unique_conc(c), :);
                
                % Solo crear el histograma si hay datos correspondientes
                if ~isempty(current_zym_data)
                    histogram(current_zym_data.NormalizedArea, 'DisplayStyle', 'bar', 'EdgeColor', 'none');
                    
                    % Crear la entrada en la leyenda combinando Zymolyase y Concentration
                    legend_entries{legend_counter} = ['Zymolyase ' num2str(unique_zym(j)) ', Conc ' num2str(unique_conc(c))];
                    legend_counter = legend_counter + 1;
                end
            end
        end
        
        bin_edges = unique(current_time_data.NormalizedArea);
        tick_labels = cellfun(@(x) int2str(x), num2cell(bin_edges), 'UniformOutput', false); % Convert bin edges to string
        tick_labels(cellfun(@(x) str2double(x) == 7, tick_labels)) = {'>6'};        
        xticks(bin_edges);
        xticklabels(tick_labels);
        
        xlabel('Number of cells per cluster');
        ylabel('Particle size - normalized Area');
        title([sprintf('Particle size distribution (>2) for Time %d and cell density of %d', int2str(unique_times(i)), int2str(unique_conc(c)))]);
        hold off;
        % Create legend
       
        legend(legend_entries);
        file_name = sprintf('extreme_plot%d.png', unique_times(i));
        file_path = fullfile(path_save, subfolder, file_name);
        saveas(gcf, file_path);
        close(gcf);
    end
    
    % Create violin plot
    figure;
    distributionPlot(vertcat(clean_data.NormalizedArea), 'group', [clean_data.Time], 'histOpt', 2);
    title('Distribution of Areas per Time Violin Plot');
    xlabel('Time');
    ylabel('Area');
    
    file_name = 'violin_plot.png';
    file_path = fullfile(path_save, subfolder, file_name);
    saveas(gcf, file_path);
    close(gcf);

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
                    for c = 1:length(unique_conc)
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
                        new_row.concentration = unique_conc(c);
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
    end
    % Plot the combined probability
    for k = 1:length(unique_zym)
        for v = 1:length(unique_velocity)
            for t = 1:length(unique_temperature)
                for c = 1:length(unique_conc)
                figure;
                hold on;
                legend_entries = {}; 
                current_combination_data = probability(probability.zymolyase == unique_zym(k) & ...
                                                       probability.velocity == unique_velocity(v) & ...
                                                       probability.temperature == unique_temperature(t) & probability.concentration == unique_conc(c), :);
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
                       ' mg/mL, Velocity ', num2str(unique_velocity(v)), ', Temperature ', num2str(unique_temperature(t)), ', Concentration ', num2str(unique_conc(c))]);
                
                % Save the plot to a file
                file_name = sprintf('plot_probabilities_combined_%d_%d_%d_%d.png', unique_zym(k), unique_velocity(v), unique_temperature(t), unique_conc(c));
                file_name2 = sprintf('plot_probabilities_combined_%d_%d_%d_%d.fig', unique_zym(k), unique_velocity(v), unique_temperature(t), unique_conc(c));
                file_path = fullfile(path_save, subfolder, file_name);
                file_path2 = fullfile(path_save, subfolder, file_name2);
                saveas(gcf, file_path);
                saveas(gcf, file_path2);
                close(gcf);
            end
        end
    end
end
