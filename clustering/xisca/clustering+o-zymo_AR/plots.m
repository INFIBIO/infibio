function plots(df, path_save)

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
        unique_conc = unique(current_time_data.Concentration);
        figure;
        hold on;
        
        for j = 1:length(unique_zym)
            for k = 1:length(unique_conc)
                current_data = current_time_data(current_time_data.Zymolyase == unique_zym(j) & current_time_data.Concentration == unique_conc(k), :);
                histogram(current_data.NormalizedArea, 'DisplayStyle', 'bar', 'EdgeColor', 'none');
            end
        end
        % Modify x-axis tick labels
        bin_edges = unique(current_time_data.NormalizedArea);
        tick_labels = cellfun(@(x) int2str(x), num2cell(bin_edges), 'UniformOutput', false); % Convert bin edges to string
        tick_labels(cellfun(@(x) str2double(x) == 7, tick_labels)) = {'>6'};        
        xticks(bin_edges);
        xticklabels(tick_labels);
        
        xlabel('Number of cells per cluster');
        ylabel('Particle size - normalized Area');
        title(['Particle size distribution for Time ', int2str(unique_times(i))]);
        hold off;
        
        % Create legend
        % Get unique combinations of Zymolyase and Concentration
        [unique_combinations, ~, idx] = unique(df(:, {'Zymolyase', 'Concentration'}), 'rows');
        
        % Initialize a cell array for legend entries
        legend_entries = cell(height(unique_combinations), 1);
        
        % Loop over each unique combination
        for i = 1:height(unique_combinations)
            zym_value = unique_combinations.Zymolyase(i);
            conc_value = unique_combinations.Concentration(i);
            legend_entries{i} = ['Zymolyase ' num2str(zym_value) ' mg/mL, Concentration ' num2str(conc_value)];
        end
        legend(legend_entries);

        file_name = sprintf('histogram_plot%d.png', unique_times(i));
        file_path = fullfile(path_save, subfolder, file_name);
        saveas(gcf, file_path);
        close(gcf);
    end
      
         
    % Filter out extreme values
    
    df_extreme = clean_data(clean_data.NormalizedArea>2,:);
    
    for i = 1:length(unique_times)
        current_time_data = df_extreme(df_extreme.Time == unique_times(i,:),:);
        unique_zym = unique(current_time_data.Zymolyase);
        unique_conc = unique(current_time_data.Concentration);
        
        figure;
        hold on;
   

        for j = 1:length(unique_zym)
            for k = 1:length(unique_conc)
                current_data = current_time_data(current_time_data.Zymolyase == unique_zym(j) & current_time_data.Concentration == unique_conc(k), :);
                histogram(current_data.NormalizedArea, 'DisplayStyle', 'bar', 'EdgeColor', 'none');
            end
        end
        
        bin_edges = unique(current_time_data.NormalizedArea);
        tick_labels = cellfun(@(x) int2str(x), num2cell(bin_edges), 'UniformOutput', false); % Convert bin edges to string
        tick_labels(cellfun(@(x) str2double(x) == 7, tick_labels)) = {'>6'};        
        xticks(bin_edges);
        xticklabels(tick_labels);
        
        xlabel('Number of cells per cluster');
        ylabel('Particle size - normalized Area');
        title(['Particle size distribution (>2) for Time ', int2str(unique_times(i))]);
        hold off;
        % Create legend
        % Get unique combinations of Zymolyase and Concentration
        [unique_combinations, ~, idx] = unique(df(:, {'Zymolyase', 'Concentration'}), 'rows');
        
        % Initialize a cell array for legend entries
        legend_entries = cell(height(unique_combinations), 1);
        
        % Loop over each unique combination
        for i = 1:height(unique_combinations)
            zym_value = unique_combinations.Zymolyase(i);
            conc_value = unique_combinations.Concentration(i);
            legend_entries{i} = ['Zymolyase ' num2str(zym_value) ' mg/mL, Concentration ' num2str(conc_value)];
        end
        legend(legend_entries);
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
    
    file_name ='violin_plot.png';
    file_path = fullfile(path_save, subfolder, file_name);
    saveas(gcf, file_path);

    close(gcf);

    % Calculate probability and standard deviation
% Assuming clean_data is your table containing the data and unique_times is defined

probability = table(); % Initialize an empty table to store results

for i = 1:length(unique_times)
    current_time_data = clean_data(clean_data.Time == unique_times(i), :);
    
    unique_zym = unique(current_time_data.Zymolyase);
    unique_conc = unique(current_time_data.Concentration);
    
    for k = 1:length(unique_zym)
        for m = 1:length(unique_conc)
            current_zym_conc_data = current_time_data(current_time_data.Zymolyase == unique_zym(k) & current_time_data.Concentration == unique_conc(m), :);
            
            unique_areas = unique(current_zym_conc_data.NormalizedArea);
            total_area = sum(current_zym_conc_data.NormalizedArea);
            
            for j = 1:length(unique_areas)
                new_row = table();
                new_row.time = unique_times(i);
                new_row.zymolyase = unique_zym(k);
                new_row.concentration = unique_conc(m);
                
                filtered_data = current_zym_conc_data(current_zym_conc_data.NormalizedArea == unique_areas(j), :);
                sum_area = sum(filtered_data.NormalizedArea);
                
                new_row.area = unique_areas(j);
                new_row.probability = sum_area / total_area; % Calculate probability
                new_row.positive_sd = sqrt((sum_area / total_area) * (1 - sum_area / total_area) / sum_area); % Calculate standard deviation
                
                probability = [probability; new_row]; % Append row to probability table
            end
        end
    end
end

% Display the probability table



% Get unique combinations of Zymolyase and Concentration
unique_combinations = unique(probability(:, {'zymolyase', 'concentration'}), 'rows');

for i = 1:height(unique_combinations)
    zym_value = unique_combinations.zymolyase(i);
    conc_value = unique_combinations.concentration(i);
    
    figure;
    hold on;
    legend_entries = {};
    
    % Filter data for current Zymolyase and Concentration
    current_zym_conc_data = probability(probability.zymolyase == zym_value & probability.concentration == conc_value, :);
    
    for j = 1:length(unique_times)
        % Filter data for the current time
        current_time_data = current_zym_conc_data(current_zym_conc_data.time == unique_times(j), :);
        
        % Plot with error bars
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
    title(['Probability of Each Number of Cells for ' num2str(zym_value) ' mg/mL Zymolyase, ' num2str(conc_value) ' Concentration']);
    
    % Save the plot to a file
    file_name = sprintf('plot_probabilities_zym_%d_conc_%d.png', zym_value, conc_value);
    file_name2 = sprintf('plot_probabilities_zym_%d_conc_%d.fig', zym_value, conc_value);
    file_path_png = fullfile(path_save, subfolder, file_name);
    file_path_fig = fullfile(path_save, subfolder, file_name2);
    saveas(gcf, file_path_png);
    saveas(gcf, file_path_fig);
    close(gcf);
end
end
