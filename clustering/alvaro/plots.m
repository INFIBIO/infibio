function plots(df, bins, path_save)
    if ~exist('bins', 'var')
        bins = 100;
    end
    
    if ~exist('path_save', 'var')
        path_save = '';
    end
    
    mask = ~isnan([df.Time]);
    clean_data = df(mask);
    unique_times = unique(vertcat(clean_data.Time));
    subfolder = 'plots';
    
    if ~exist(fullfile(path_save, subfolder), 'dir')
        mkdir(fullfile(path_save, subfolder));
    end
    
    % Histogram plots for area distribution
    for i = 1:length(unique_times)
        mask = [df.Time] == unique_times(i);
        current_time_data = df(mask);
        
        figure;
        hold on;
        matrix = vertcat(current_time_data.NormalizedArea);
        h = histogram(matrix);
            
            % Generate tick labels
        bin_edges = unique(matrix);
        tick_labels = cellfun(@(x) int2str(x), num2cell(bin_edges), 'UniformOutput', false); % Convert bin edges to string
        tick_labels(cellfun(@(x) str2double(x) == 7, tick_labels)) = {'>6'};        
        % Modify x-axis tick labels
        xticks(bin_edges);
        xticklabels(tick_labels);
        
        xlabel('Area');
        ylabel('Frequency');
        title(['Area Distribution for Time ', int2str(unique_times(i))]);
        
        file_name = sprintf('histogram_plot%d.png', unique_times(i));
        file_path = fullfile(path_save, subfolder, file_name);
        saveas(gcf, file_path);
        
        close(gcf);
    end
    
    % Filter out extreme values
    mask = [df.NormalizedArea] > 2;
    df_extreme = df(mask);
    
    for i = 1:length(unique_times)
        mask = [df_extreme.Time] == unique_times(i);
        current_time_data = df_extreme(mask);
        
        figure;
        hold on;
        matrix = vertcat(current_time_data.NormalizedArea);
        h = histogram(matrix);
        
        bin_edges = unique(matrix);
        tick_labels = cellfun(@(x) int2str(x), num2cell(bin_edges), 'UniformOutput', false); % Convert bin edges to string
        tick_labels(cellfun(@(x) str2double(x) == 7, tick_labels)) = {'>6'};       
        % Modify x-axis tick labels
        xticks(bin_edges);
        xticklabels(tick_labels);
        
        xlabel('Area');
        ylabel('Frequency');
        title(['Area Distribution for Time ', int2str(unique_times(i))]);
        
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
    probability = struct(); % Initialize empty structure

    for i = 1:length(unique_times)
        mask = [df.Time] == unique_times(i);
        current_time_data = df(mask);

        unique_areas = unique(vertcat(current_time_data.NormalizedArea));
        total_area = sum(vertcat(current_time_data.NormalizedArea));

        for j = 1:length(unique_areas)
            probability(end+1).time = unique_times(i);
            mask = [current_time_data.NormalizedArea] == unique_areas(j);
            filtered_data = current_time_data(mask);
            sum_area = sum(vertcat(filtered_data.NormalizedArea));
            
            probability(end).probability = sum_area / total_area;
            probability(end).area = unique_areas(j);
            probability(end).positive_sd = sqrt((sum_area / total_area)*(1-sum_area / total_area)/sum_area);
            probability(end).negative_sd = -sqrt((sum_area / total_area)*(1-sum_area / total_area)/sum_area);
        end
    end
    probability(:,1) = [];
    
    % Plot probability with error bars
    figure;
    hold on;
    legend_entries = {};  % Initialize legend entries
    
    for i = 1:length(unique_times)
        mask = [probability.time] == unique_times(i);
        current_time_data = probability(mask);
    
        plot(vertcat(current_time_data.area), vertcat(current_time_data.probability), 'o-');
        errorbar(vertcat(current_time_data.area), vertcat(current_time_data.probability), vertcat(current_time_data.positive_sd));
        matrix = unique(vertcat(current_time_data.area))
        % Modify x-axis tick labels
        bin_edges = unique(matrix);
        tick_labels = cellfun(@(x) int2str(x), num2cell(bin_edges), 'UniformOutput', false); % Convert bin edges to string
        tick_labels(cellfun(@(x) str2double(x) == 7, tick_labels)) = {'>6'};       
        % Modify x-axis tick labels
        xticks(bin_edges);
        xticklabels(tick_labels);
        % Store legend entry for current time
        legend_entries{end+1} = ['Time ' int2str(unique_times(i))];
    
        xlabel('Number of Cells');
        ylabel('Probability');
        title('Probability of Each Number of Cells for Time');
    end
    
    % Show the legend with entries for each time
    legend(legend_entries);
    
    % Save the plot to a file
    file_name = 'plot_time.png';
    file_path = fullfile(path_save, subfolder, file_name);
    saveas(gcf, file_path);
    
    hold off;  % Release hold on the figure
end
