function plots(df, bins, path_save)
    % bins = 100;
    % df = mat_combined;
    if ~exist('bins', 'var')
        bins = 100;
    end
    
    if ~exist('path_save', 'var')
        path_save = '';
    end
    
    mask = ~isnan([df.Time]);
    clean_data = df(mask);
    % Get unique times
    unique_times = unique(vertcat(clean_data.Time));
    % Define the name of the subfolder
    subfolder = 'plots';
    
    % Check if the subfolder exists, if not, create it
    if ~exist(fullfile(path_save, subfolder), 'dir')
        mkdir(fullfile(path_save, subfolder));
    end
    
    % Iterate over each Time and create a histogram for the corresponding area
    for i = 1:length(unique_times)
        mask = [df.Time] == unique_times(i);
        
        % Filter df for the current Time
        current_time_data = df(mask);
        figure;
        hold on;
        matrix = vertcat(current_time_data.NormalizedArea);
        % Create histogram for the area
        h = histogram(matrix);
        
        % Add labels and title
        xlabel('Area');
        ylabel('Frequency');
        title(['Area Distribution for Time ', num2str(unique_times(i))]);
        % Save the plot in the subfolder
        file_name = sprintf('histogram_plot%d.png', unique_times(i));
        file_path = fullfile(path_save, subfolder, file_name);
        saveas(gcf, file_path);
        
        % Close the current figure to prevent accumulation
        close(gcf);
    end
    
    % Filter out extreme values
    mask = [df.NormalizedArea] > 2;
    df_extreme = df(mask);
    
    for i = 1:length(unique_times)
        mask = [df_extreme.Time] == unique_times(i);
        
        % Filter df for the current Time
        current_time_data = df_extreme(mask);
        figure;
        hold on;
        matrix = vertcat(current_time_data.NormalizedArea);
        % Create histogram for the area
        h = histogram(matrix);
        
        % Add labels and title
        xlabel('Area');
        ylabel('Frequency');
        title(['Area Distribution for Time ', num2str(unique_times(i))]);
        % Save the plot in the subfolder
        file_name = sprintf('extreme_plot%d.png', unique_times(i));
        file_path = fullfile(path_save, subfolder, file_name);
        saveas(gcf, file_path);
        
        % Close the current figure to prevent accumulation
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
    
    % Close the current figure to prevent accumulation
    close(gcf);

    probability = struct(); % Initialize empty structure

    for i = 1:length(unique_times)
        mask = [df.Time] == unique_times(i);
        % Filter df for the current Time
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
    figure;
    hold on;
    legend_entries = {};  % Initialize legend entries
    % Iterate over each unique time
    for i = 1:length(unique_times)
        % Filter the DataFrame for the current time
        mask = [probability.time] == unique_times(i);
        % Filter df for the current Time
        current_time_data = probability(mask);
    
        % Plot the probability of each ID for the current time
        plot(vertcat(current_time_data.area), vertcat(current_time_data.probability), 'o-');
         % Calculate the positive and negative parts of the standard deviation
        ;
    
        % Plot the probability of each ID for the current time with error bars
        errorbar(vertcat(current_time_data.area), vertcat(current_time_data.probability), current_time_data.positive_sd, 'o-');
            % Store legend entry for current time
        legend_entries{end+1} = ['Time ' num2str(unique_times(i))];
    
        % Add labels and title
        xlabel('Number of Cells');
        ylabel('Probability');
        title('Probability of Each Number of Cells for Time');
    
    end
    
    % Show the legend with entries for each time
    legend(legend_entries);
    
    % Save the plot to a file
    file_name = 'plot_time.png';
    saveas(gcf, file_name);
    
    hold off;  % Release hold on the figure

end

