function plots_6(df, path_save)
% This script defines the function `plots_6`, which generates a series of plots 
% that visualize the probability of a single cell being in a cluster, based on 
% different zymolyase concentrations, temperatures, and times. The plots illustrate 
% how the probability varies with the number of cells in a cluster under different 
% experimental conditions.
%
% INPUT:
% - df: A table containing experimental data with columns including 'Time', 
%   'Zymolyase', 'NormalizedArea', and 'Temperature'.
% - path_save: (Optional) A string specifying the directory where the plots will 
%   be saved. If not provided, the plots will be saved in the current working 
%   directory.
%
% OUTPUT:
% - The function generates and saves a plot in both .png and .fig formats within 
%   a subfolder named 'plots' in the specified path. The plot illustrates the 
%   probability of a single cell being in a cluster under various experimental 
%   conditions.
%
% FUNCTIONALITY:
% 1. The function begins by filtering the input data to exclude rows with NaN values 
%    in the 'Time' or 'Temperature' columns.
% 2. Unique values for times, zymolyase concentrations, and temperatures are extracted 
%    to structure the data for plotting.
% 3. A new folder named 'plots' is created within the specified save path to store 
%    the output plot.
% 4. The script calculates the probability and positive standard deviation for each 
%    unique combination of time, zymolyase concentration, and temperature. This is done 
%    by iterating over the unique values and performing computations for the sum of 
%    normalized areas.
% 5. The function generates a single plot for all zymolyase concentrations, where:
%    - The x-axis represents the number of cells in a cluster.
%    - The y-axis represents the adjusted probability (scaled for a single cell) on a 
%      semilogarithmic scale.
%    - Different colors are used for different temperatures, with markers distinguishing 
%      between different zymolyase concentrations.
% 6. Error bars are included to represent the standard deviation of the probabilities.
%
% PLOTTING DETAILS:
% - For each combination of zymolyase concentration, temperature, and time:
%   - Data is plotted using a semilogarithmic scale for the y-axis to accommodate the 
%     wide range of probabilities.
%   - Colors represent different temperatures, and markers represent different zymolyase 
%     concentrations.
%   - Error bars are included to show the uncertainty in the probability estimates.
%
% ADDITIONAL NOTES:
% - The `saveas` function is used to save the plot in both .png and .fig formats, 
%   ensuring compatibility with various software tools and enhancing accessibility.
% - The plot includes a legend to help identify different experimental conditions.



    if nargin < 2
        path_save = '';
    end

    % Filter data to exclude rows with NaN values in 'Time' or 'Temperature'
    clean_data = df(~isnan(df.Time) & ~isnan(df.Temperature), :);
    unique_times = unique(clean_data.Time);
    unique_zym = unique(clean_data.Zymolyase);
    unique_temps = unique(clean_data.Temperature);
    
    % Create a subfolder named 'plots' for saving the output plot
    subfolder = 'plots';
    if ~exist(fullfile(path_save, subfolder), 'dir')
        mkdir(fullfile(path_save, subfolder));
    end
    
    % Initialize an empty table to store calculated probabilities and standard deviations
    probability = table();

    % Iterate over each unique time point and temperature to calculate probabilities
    for i = 1:length(unique_times)
        for t = 1:length(unique_temps)
            current_time_temp_data = clean_data(clean_data.Time == unique_times(i) & clean_data.Temperature == unique_temps(t), :);

            for k = 1:length(unique_zym)
                current_zym_data = current_time_temp_data(current_time_temp_data.Zymolyase == unique_zym(k), :);
                unique_areas = unique(current_zym_data.NormalizedArea);
                total_area = sum(current_zym_data.NormalizedArea);
                
                for j = 1:length(unique_areas)
                    new_row = table();
                    new_row.time = unique_times(i);
                    new_row.temperature = unique_temps(t);
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
    end

    % Define markers and colors for plotting
    markers = {'o', 's'}; % Circle for zymolyase 0, square for zymolyase 0.1
    colormap_temp = jet(length(unique_temps)); % Color map based on temperature
    
    % Create a single figure for all zymolyase concentrations
    figure('Position', [100, 100, 1200, 800]); % Set figure size
    hold on;
    
    legend_entries = {};
    legend_index = 1;
    handles = [];

    % Plot data for each combination of zymolyase concentration and temperature
    for i = 1:length(unique_zym)
        for t = 1:length(unique_temps)
            current_zym_temp_data = probability(probability.zymolyase == unique_zym(i) & probability.temperature == unique_temps(t), :);

            for j = 1:length(unique_times)
                current_time_data = current_zym_temp_data(current_zym_temp_data.time == unique_times(j), :);

                if ~isempty(current_time_data)
                    % Adjust probability and standard deviation for a single cell
                    log_probability = current_time_data.probability .* current_time_data.area;
                    log_positive_sd = current_time_data.positive_sd .* current_time_data.area;
                    
                    % Select color based on temperature
                    current_color = colormap_temp(t, :);

                    % Plot using a semilogarithmic scale for the y-axis
                    h = plot(current_time_data.area, log_probability, 'LineStyle', '-', ...
                        'Marker', markers{i}, 'Color', current_color, ...
                        'MarkerFaceColor', current_color);
                    errorbar(current_time_data.area, log_probability, log_positive_sd, 'LineStyle', 'none', ...
                        'Marker', markers{i}, 'Color', current_color, ...
                        'MarkerFaceColor', current_color);

                    % Save handle and legend entry
                    handles = [handles; h];
                    legend_entries{legend_index} = ['Zymolyase ' num2str(unique_zym(i)) ' mg/mL, Temp ' num2str(unique_temps(t)) '°C, Time ' num2str(unique_times(j))];
                    legend_index = legend_index + 1;
                end
            end
        end
    end

    xlabel('Number of Cells in Cluster');
    ylabel('Probability for a Single Cell (Semilog)');
    title('Probability of a Single Cell Being in a Cluster for Different Zymolyase Concentrations, Times, and Temperatures');
    legend(handles, legend_entries, 'Location', 'Best');

    % Save the plot in .png and .fig formats
    file_name = 'log_plot_probabilities_single_cell_all_zymolyase_temps.png';
    file_name2 = 'log_plot_probabilities_single_cell_all_zymolyase_temps.fig';
    file_path = fullfile(path_save, subfolder, file_name);
    file_path2 = fullfile(path_save, subfolder, file_name2);
    saveas(gcf, file_path);
    saveas(gcf, file_path2);
    close(gcf);
end
