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
        unique_zym = unique(current_time_data.Zymoliase);
        figure;
        hold on;
        
        for j = 1:length(unique_zym)
            current_zym_data = current_time_data(current_time_data.Zymoliase == unique_zym(j),:);
            histogram(current_zym_data.NormalizedArea, 'DisplayStyle', 'bar', 'EdgeColor', 'none');
        end
        % Modify x-axis tick labels
        bin_edges = unique(current_time_data.NormalizedArea);
        tick_labels = cellfun(@(x) int2str(x), num2cell(bin_edges), 'UniformOutput', false); % Convert bin edges to string
        tick_labels(cellfun(@(x) str2double(x) == 7, tick_labels)) = {'>6'};        
        xticks(bin_edges);
        xticklabels(tick_labels);
        
        xlabel('Index');
        ylabel('Normalized Area');
        title(['Normalized Area for Time ', int2str(unique_times(i))]);
        hold off;
        
        % Create legend
        legend_entries = cell(length(unique_zym), 1);
        for j = 1:length(unique_zym)
            legend_entries{j} = ['Zymoliase ' num2str(unique_zym(j))];
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
        unique_zym = unique(current_time_data.Zymoliase);
        
        figure;
        hold on;
   

        for j = 1:length(unique_zym)
            current_zym_data = current_time_data(current_time_data.Zymoliase == unique_zym(j),:);
            histogram(current_zym_data.NormalizedArea, 'DisplayStyle', 'bar', 'EdgeColor', 'none');
        end
        
        bin_edges = unique(current_time_data.NormalizedArea);
        tick_labels = cellfun(@(x) int2str(x), num2cell(bin_edges), 'UniformOutput', false); % Convert bin edges to string
        tick_labels(cellfun(@(x) str2double(x) == 7, tick_labels)) = {'>6'};        
        xticks(bin_edges);
        xticklabels(tick_labels);
        
        xlabel('Index');
        ylabel('Normalized Area');
        title(['Normalized Area > 2 for Time ', int2str(unique_times(i))]);
        hold off;
        % Create legend
        legend_entries = cell(length(unique_zym), 1);
        for j = 1:length(unique_zym)
            legend_entries{j} = ['Zymoliase ' num2str(unique_zym(j))];
        end
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
    probability = table(); % Initialize empty structure

    for i = 1:length(unique_times)
        current_time_data = clean_data(clean_data.Time == unique_times(i,:),:);
        unique_zym = unique(current_time_data.Zymoliase);
        
        for k = 1:length(unique_zym)
            current_zym_data = current_time_data(current_time_data.Zymoliase == unique_zym(k),:);
            unique_areas = unique(current_zym_data.NormalizedArea);
            total_area = sum(current_zym_data.NormalizedArea);
    
            for j = 1:length(unique_areas)
                new_row = table();
                new_row.time = unique_times(i);
                new_row.zymoliase = unique_zym(k);
                filtered_data = current_zym_data(current_zym_data.NormalizedArea==unique_areas(j),:);
                sum_area = sum(filtered_data.NormalizedArea);
          
                new_row.area = unique_areas(j);
                new_row.positive_sd = sqrt((sum_area / total_area)*(1-sum_area / total_area)/sum_area);
                
                probability = [probability; new_row];
            end
        end
    end
    for i = 1:length(unique_zym)
        figure;
        hold on;
        legend_entries = {}; 
        current_zym_data = probability(probability.zymoliase == unique_zym(i),:);
        for j = 1:length(unique_times)
            current_time_data = current_zym_data(current_zym_data.time == unique_times(j),:);
            plot(current_time_data.area, current_time_data.probability, 'o-');
            errorbar(current_time_data.area, current_time_data.probability, current_time_data.positive_sd);
            matrix = unique(probability.area);
            % Store legend entry for current time
            legend_entries{end+1} = ['Time ' int2str(unique_times(j))];
        end
        
        legend(legend_entries);
        bin_edges = unique(matrix);
        tick_labels = cellfun(@(x) int2str(x), num2cell(bin_edges), 'UniformOutput', false); % Convert bin edges to string
        tick_labels(cellfun(@(x) str2double(x) == 7, tick_labels)) = {'>6'};       
        % Modify x-axis tick labels
        xticks(bin_edges);
        xticklabels(tick_labels);
       
        
    
        xlabel('Number of Cells');
        ylabel('Probability');
        title(['Probability of Each Number of Cells for Time at ' num2str(unique_zym(i)) ' mg/mL zymoliase']);
          % Save the plot to a file
        file_name = 'plot_probabilities%d.png';
        file_path = fullfile(path_save, subfolder, file_name);
        saveas(gcf, file_path);
        close(gcf)
    
    end
  
end
