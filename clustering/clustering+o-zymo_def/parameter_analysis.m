
% This script processes experimental data from multiple subfolders in a
% parent directory. It combines .mat files from these subfolders, cleans
% the data, and generates plots of proportion vs. time for various
% conditions including Zymolyase concentration, velocity, and other
% parameters. The output is saved as plots in the specified parent folder.

% Assumptions: 
% 1. Subfolders are named in a specific format: 
% 'Concentration_Zymolyase_Velocity_Temperature'. 
% 2. Data is stored in .mat files within each subfolder. 
% 3. Time data might need mapping based on velocity (125 or other). 
% 4. Proportions and standard deviations are calculated based on 
% normalized areas.

% Input: 
% - The script assumes the existence of a parent folder that contains 
% multiple subfolders. 
% - Each subfolder should contain relevant data files (e.g., .mat files) 
% for analysis.

% Output: 
% - The script produces plots that visualize the proportion vs.
% time for various combinations of Zymolyase concentrations, velocities, 
% and cell concentrations.
% - The plots are saved as .png files in the specified parent directory.

% Data Structure: 
% - Concentration: Cell concentration in cells/mL (mapped
% from original values of dilution to new concentrations). 
% - Zymolyase: Zymolyase concentration in mg/mL. 
% - Velocity: Speed in rpm. 
% - Time: Time of observation, adjusted based on the velocity of the 
% experiment. 
% - NormalizedArea: A measure of area used for calculating proportions. 
% - Proportion: Calculated proportion based on the total area. 
% - Positive Standard Deviation (positive_sd): Computed using 
% binomial proportion formula.

% Processing Flow: 
% 1. Load data from subfolders and combine .mat files. 
% 2. Adjust time values based on velocity using predefined mapping tables. 
% 3. Calculate proportions for each unique area and condition (Zymolyase,
% Velocity, Concentration). 
% 4. Plot the results with different line styles
% for each Zymolyase level, and different colors for concentration and
% velocity. 
% 5. Save the resulting plots to the parent folder.

% Note: 
% - Ensure that the 'combineMatFiles' and 'clean_weird_shapes' helper
% functions are available in the working environment. 
% - Modify the 'Time'column reference if needed, depending on the 
% structure of the combined result.

% Usage: 
% - Update the 'parentFolder' variable to the path containing the
% experimental data before running the script. 
% HISTORY
% -------
% Created August 2024. AR
% Modified 11 November 2024. AR. Corrected the calculation of the error.



% Specify the parent folder that contains all subfolders
parentFolder = 'C:\Users\uib\Desktop\Yeast_Experiments\CLUSTERING_50-200RPM_20112024\exp_wholeplat';

% Get a list of all subfolders in the parent folder
subFolders = dir(parentFolder);
subFolders = subFolders([subFolders.isdir]); % Filter only folders
subFolders = subFolders(~ismember({subFolders.name}, {'.', '..'})); % Remove '.' and '..'
pathOne = fullfile(subFolders(1).folder, subFolders(1).name);

% Initialize an array to store combined results
mat_combined = [];

% Define the mapping of old concentrations to new concentrations
old_conc = [200, 500, 1000, 2000, 5000];
new_conc = [1.25e5, 5e4, 2.5e4, 1.25e4, 5e3];


% Loop through each subfolder
for i = 1:length(subFolders)
    % Get the name of the subfolder
    subFolderName = subFolders(i).name;
    
    % Split the subfolder name into parts using the underscore ('_')
    % character
    parts = split(subFolderName, '_');
    
    % Assign variables from the subfolder name
    Concentration = str2double(parts{1});
    Zymolyase = str2double(parts{2}) / 100;
    Velocity = str2double(parts{3});
    Temperature = str2double(parts{4});
    
    % Map the old concentrations to the new ones
    if ismember(Concentration, old_conc)
        Concentration = new_conc(old_conc == Concentration);
    end
    
    % Specify the full path to the subfolder
    folderPath = fullfile(parentFolder, subFolderName);
    
    % Call the combineMatFiles function for the current subfolder
    combinedResult = combineMatFiles(folderPath, Concentration, Zymolyase, Velocity, Temperature);
    
    % Check if combinedResult has data before processing
    if isempty(combinedResult)
        continue; % Skip to next iteration if no data
    end
    
    % % Define a time mapping table for Velocity 125
    % timeMapping_125 = [-1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14; 
    %                     -5, 0, 20, 40, 60, 80, 100, 120, 140, 180, 220, 260, 300, 340, 380, 420];
    % 
    % % Define a time mapping table for the rest of the velocities
    % timeMapping_other = [-1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14;
    %                     -5, 0, 30, 60, 90, 120, 180, 240, 300, 360, 420, 480, 540, 600, 660, 720];
    % 
    % % Choose the appropriate time mapping based on Velocity
    % if Velocity == 125
    %     timeMapping = timeMapping_125;
    % else
    %     timeMapping = timeMapping_other;
    % end
    
    % Access the time column in the table (assuming the column is named
    % 'Time')
    % time = combinedResult.Time;  % Replace 'Time' with the actual name of the time column if different
    
    % % Iterate over the mapping table and adjust the time values accordingly
    % for j = 1:size(timeMapping, 2)
    %     time(time == timeMapping(1,j)) = timeMapping(2,j);
    % end
    
    % Update the time column in the combined result with the new mapped
    % time values
    % combinedResult.Time = time;  % Replace 'Time' with the actual column name
    
    combinedResult.Time = combinedResult.Time*10; % Modify to adapt to your time
    % units
    % Add the combined data to the final array
    mat_combined = [mat_combined; combinedResult];
end

mat_cleaned = clean_weird_shapes(mat_combined);
mat_cleaned = mat_combined;

% Get unique values for various parameters
unique_times = unique(mat_cleaned.Time);
unique_zym = unique(mat_cleaned.Zymolyase);
unique_conc = unique(mat_cleaned.Concentration);
unique_areas = unique(mat_cleaned.NormalizedArea);
unique_temps = unique(mat_cleaned.Temperature);
unique_replica = unique(mat_cleaned.Replica);
unique_velocities = unique(mat_cleaned.Velocity);
% Initialize an empty table to store proportions, means, and standard
% deviations
proportion = table();

% Loop for each unique time
for i = 1:length(unique_times)
    % Filter data for the current time
    current_time_data = mat_cleaned(mat_cleaned.Time == unique_times(i), :);

    % Loop for each combination of zymolyase, concentration, and
    % temperature
    for r = 1:length(unique_replica)
        for k = 1:length(unique_zym)
            for z = 1:length(unique_conc)
                for t = 1:length(unique_velocities)
                    % Filter data by zymolyase, concentration, and
                    % temperature
                    current_zym_data = current_time_data(current_time_data.Zymolyase == unique_zym(k) & ...
                        current_time_data.Concentration == unique_conc(z) & ...
                        current_time_data.Velocity == unique_velocities(t) & ...
                        current_time_data.Replica == unique_replica(r), :);
                    
                    % Calculate total area per replica
                    total_area = sum(current_zym_data.NormalizedArea);

                    % Loop through each unique area
                    for j = 1:length(unique_areas)
                        % Filter data for the current area
                        filtered_data = current_zym_data(current_zym_data.NormalizedArea == unique_areas(j), :);
                        sum_area = sum(filtered_data.NormalizedArea);

                        % Calculate and store proportion and standard
                        % deviation if total area is greater than zero
                        if total_area > 0
                            new_row = table();
                            new_row.velocities = unique_velocities(t);
                            new_row.time = unique_times(i);
                            new_row.zymolyase = unique_zym(k);
                            new_row.concentration = unique_conc(z);                            
                            new_row.area = unique_areas(j);
                            new_row.replica = unique_replica(r);
                            new_row.proportion = sum_area / total_area;
                            new_row.positive_sd = sqrt((sum_area / total_area) * (1 - sum_area / total_area) / total_area);

                            % Add the new row to the proportion table
                            proportion = [proportion; new_row];
                        end
                    end
                end
            end
        end
    end
end

% Iterate over each unique area
for i = 1:length(unique_areas)
    % Create a new figure for each area
    figure('Position', [100, 100, 800, 600]);
    hold on;
    
    % Filter data for the current area
    current_area_data = proportion(proportion.area == unique_areas(i), :);
    
    % Initialize line styles for each level of zymolyase
    line_styles_zym = {'-', '--', ':', '-.'};  % Different line styles for each level of zymolyase
    total_styles = length(line_styles_zym);  % Count of line styles (one per zymolyase level)
    
    % Initialize colormaps for concentrations and velocities
    colors_concentration = lines(length(unique_conc));  % Different colors for each concentration
    colormap_vel = parula(length(unique_velocities));  % Gradient for velocity, different for each zymolyase level
    
    % Initialize a counter for legend entries
    legendEntries = {};
    
    % Loop through each unique concentration, zymolyase, and velocity
    % within the current area
    for z = 1:length(unique_zym)
        % Select the line style corresponding to the current zymolyase
        % level
        line_style = line_styles_zym{min(z, total_styles)};  % Limit index to the number of available styles

        for c = 1:length(unique_conc)
            % Get the color for the current concentration
            concentration_color = colors_concentration(c, :);  % Specific color for the concentration
            
            for v = 1:length(unique_velocities)
                % Filter data for the current combination of zymolyase,
                % velocity, and concentration
                current_data = current_area_data(current_area_data.zymolyase == unique_zym(z) & ...
                    current_area_data.velocities == unique_velocities(v) & ...
                    current_area_data.concentration == unique_conc(c), :);
        
                % Ensure there is data before continuing
                if isempty(current_data)
                    continue;
                end
        
                % Get the unique times
                unique_times = unique(current_data.time);
        
                % Initialize arrays for means and standard deviations
                mean_proportions = zeros(length(unique_times), 1);
                std_proportions = zeros(length(unique_times), 1);
        
                % For each unique time, calculate the mean and standard
                % deviation
                for t = 1:length(unique_times)
                    % Filter data for the current time
                    time_data = current_data(current_data.time == unique_times(t), :);
                    
                    % Calculate the mean and standard deviation for the
                    % proportion at this time
                    mean_proportions(t) = mean(time_data.proportion);
                    std_proportions(t) = std(time_data.proportion);
                end
        
                % Gradient color for the current velocity (changes for each
                % zymolyase level)
                velocity_color = colormap_vel(v, :);
        
                % Combine the concentration color with the velocity
                % gradient to create a blending effect
                combined_color = (concentration_color + velocity_color) / 2;
        
                % Plot with error bars (mean ± standard deviation) using
                % the combined line style and color
                errorbar(unique_times, mean_proportions, std_proportions, ...
                    'LineStyle', line_style, ...  % Line style based on zymolyase level
                    'Color', combined_color, ...  % Combined color of concentration and velocity
                    'LineWidth', 1.5, ...  % Line thickness
                    'CapSize', 1);  % Adjust the size of the error bars (thinner lines)
        
                % Add the legend entry for the current combination
                legendEntries{end+1} = sprintf('Zymo %.2e | Vel %d | Conc %.2e', unique_zym(z), unique_velocities(v), unique_conc(c));
            end
        end
    end
    
    % Configure the plot for the current area
    xlabel('Time (s)');
    ylabel('Proportion');
    title(sprintf('Proportion vs Time for Area %d', unique_areas(i)));
    
    % Adjust the size and position of the legend
    legendEntries = legend(legendEntries, 'Location', 'bestoutside', 'FontSize', 8);  % Make the legend smaller
    title(legendEntries, 'Zymolyase (mg/mL) | Velocity (rpm) | Concentration (cells/ml)');
    
    % Show the grid
    grid on;
    hold off;
    
    % Save the plot
    save_plot(parentFolder, sprintf('proportion_vs_time_size_%d', unique_areas(i)));
end




% Helper function to save plots
function save_plot(path_save, filename)
    if ~isempty(path_save)
        full_filename = fullfile(path_save, [filename '.png']);
        saveas(gcf, full_filename);
        fprintf('Plot saved as %s\n', full_filename);
    end
end
                