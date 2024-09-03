function plots_x(df, path_save)
% This script defines the function `plots_x` which generates a series of 
% probability plots based on the data provided in a table `df`. The function 
% calculates probabilities and standard deviations for various combinations of 
% zymolyase concentrations, cell areas, and temperatures over different time 
% points. It then creates and saves visualizations of these probabilities in 
% both individual and combined plots.
%
% INPUT:
% - df: A table containing the experimental data with columns including 
%   'Time', 'Zymolyase', 'Concentration', 'NormalizedArea', and 'Temperature'.
% - path_save: (Optional) A string specifying the directory where the plots 
%   will be saved. If not provided, plots will be saved in the current working 
%   directory.
%
% OUTPUT:
% - The function generates and saves a series of plots as .tif and .fig files 
%   within a subfolder named 'plots' in the specified path. The plots illustrate 
%   the probability distribution of cell numbers under different experimental 
%   conditions.
%
% FUNCTIONALITY:
% 1. The function begins by cleaning the input data, removing any rows with NaN 
%    values in the 'Time' column.
% 2. Unique values for times, zymolyase concentrations, cell areas, and 
%    temperatures are extracted to structure the data for plotting.
% 3. A new folder named 'plots' is created within the specified save path to 
%    store the output plots.
% 4. The script calculates the probability and positive standard deviation for 
%    each unique combination of time, zymolyase concentration, concentration, 
%    temperature, and cell area. This is done by iterating over the unique values 
%    and performing computations for the sum of normalized areas.
% 5. For each unique combination of zymolyase concentration, concentration, and 
%    temperature, the function generates individual plots that show how the 
%    probability of observing a certain number of cells changes over time. These 
%    plots are saved with filenames indicating their specific conditions.
% 6. Additionally, two helper functions are used to create combined plots:
%    - `plot_combined`: Creates a combined plot of probabilities across all 
%      experimental conditions and saves it.
%    - `plot_combined_cells`: Generates plots showing probabilities over time for 
%      each cell area across different conditions, saved in the 'plots' subfolder.
%
% PLOTTING DETAILS:
% - For each condition (zymolyase concentration, concentration, temperature):
%   - A new figure is created, with subplots organized based on the number of 
%     unique times.
%   - Probabilities are plotted on a semilogarithmic scale against the number of 
%     cells, with error bars representing standard deviation.
%   - Each plot is titled with the corresponding time point and labeled with 
%     appropriate axis labels.
% - Combined plots include various markers, colors, and line styles to distinguish 
%   between different conditions and time points.
%
% ADDITIONAL NOTES:
% - The `save_plot` function is used to save each figure in both .tif and .fig 
%   formats, enhancing the utility of the output for different purposes.
% - The function relies on helper functions to manage plotting tasks, improving 
%   code modularity and readability.
    
    % Set default save path if not provided
    if nargin < 2
        path_save = '';
    end

    % Clean data by removing rows with NaN in the 'Time' column
    clean_data = df(~isnan(df.Time), :);
    
    % Get unique values for various parameters
    unique_times = unique(clean_data.Time);
    unique_zym = unique(clean_data.Zymolyase);
    unique_conc = unique(clean_data.Concentration);
    unique_areas = unique(clean_data.NormalizedArea);
    unique_temps = unique(clean_data.Temperature);

    % Create a subfolder named 'plots' if it doesn't exist
    subfolder = 'plots';
    if ~exist(fullfile(path_save, subfolder), 'dir')
        mkdir(fullfile(path_save, subfolder));
    end

    % Initialize an empty table to store probabilities and standard deviations
    probability = table(); 

    % Loop through each unique time
    for i = 1:length(unique_times)
        % Filter data for the current time
        current_time_data = clean_data(clean_data.Time == unique_times(i), :);

        % Loop through each unique zymolyase, concentration, and temperature combination
        for k = 1:length(unique_zym)
            for c = 1:length(unique_conc)
                for t = 1:length(unique_temps)
                    % Filter data for the current zymolyase, concentration, and temperature
                    current_zym_data = current_time_data(current_time_data.Zymolyase == unique_zym(k) & ...
                                                         current_time_data.Concentration == unique_conc(c) & ...
                                                         current_time_data.Temperature == unique_temps(t), :);
                    % Calculate the total area
                    total_area = sum(current_zym_data.NormalizedArea);

                    % Loop through each unique area
                    for j = 1:length(unique_areas)
                        % Filter data for the current area
                        filtered_data = current_zym_data(current_zym_data.NormalizedArea == unique_areas(j), :);
                        sum_area = sum(filtered_data.NormalizedArea);

                        % Calculate and store the probability and positive standard deviation if total area is greater than zero
                        if total_area > 0
                            new_row = table();
                            new_row.time = unique_times(i);
                            new_row.zymolyase = unique_zym(k);
                            new_row.concentration = unique_conc(c);
                            new_row.temperature = unique_temps(t);
                            new_row.area = unique_areas(j);
                            new_row.probability = sum_area / total_area;
                            new_row.positive_sd = sqrt((sum_area / total_area) * (1 - sum_area / total_area) / sum_area);

                            % Append the new row to the probability table
                            probability = [probability; new_row]; 
                        end
                    end
                end
            end
        end
    end

    % Define color schemes for plots
    blue_colors = flipud([linspace(0.3, 0, length(unique_times))', linspace(0.5, 0, length(unique_times))', linspace(1, 0, length(unique_times))']);
    orange_colors = flipud([linspace(1, 1, length(unique_times))', linspace(0.5, 0.3, length(unique_times))', linspace(0, 0, length(unique_times))']);
    colors = lines(length(unique_zym) * length(unique_conc) * length(unique_temps)); 

    % Plot for each zymolyase, concentration, and temperature combination
    for i = 1:length(unique_zym)
        for c = 1:length(unique_conc)
            for t = 1:length(unique_temps)
                % Set up the figure with subplots
                figure('Position', [100, 100, 1200, 800]);
                num_subplots = length(unique_times);
                num_cols = ceil(sqrt(num_subplots));
                num_rows = ceil(num_subplots / num_cols);

                % Filter probability data for the current zymolyase, concentration, and temperature
                current_zym_data = probability(probability.zymolyase == unique_zym(i) & ...
                                               probability.concentration == unique_conc(c) & ...
                                               probability.temperature == unique_temps(t), :);
                
                % Loop through each unique time to create subplots
                for j = 1:length(unique_times)
                    subplot(num_rows, num_cols, j);
                    hold on;

                    % Filter data for the current time
                    current_time_data = current_zym_data(current_zym_data.time == unique_times(j), :);

                    % Plot if data is available for the current time
                    if ~isempty(current_time_data)
                        log_probability = current_time_data.probability;
                        log_positive_sd = current_time_data.positive_sd;

                        errorbar(current_time_data.area, log_probability, log_positive_sd, 'o'); % Plot with error bars
                        semilogy(current_time_data.area, log_probability, 'o-'); % Plot with a logarithmic scale

                        title(['Time ' int2str(unique_times(j))]);
                        xlabel('Number of Cells');
                        ylabel('Probability (Semilog)');
                    end
                    hold off;
                end

                % Set a combined title for the plots
                sgtitle(['Probability of Each Number of Cells for ' num2str(unique_zym(i)) ' mg/mL Zymolyase, Concentration ' num2str(unique_conc(c)) ', Temperature ' num2str(unique_temps(t))]);

                % Save the plot in the specified path
                save_plot(path_save, subfolder, sprintf('log_plot_probabilities_%d_%d_%d', unique_zym(i), unique_conc(c), unique_temps(t)));
            end
        end
    end

    % Create combined plots for all zymolyase concentrations, concentrations, and temperatures
    plot_combined(probability, unique_zym, unique_conc, unique_temps, unique_times, path_save, subfolder);
    plot_combined_cells(probability, unique_zym, unique_conc, unique_areas, unique_temps, path_save, subfolder);
end

function plot_combined(probability, unique_zym, unique_conc, unique_temps, unique_times, path_save, subfolder)
    % This function creates a combined plot of probabilities for all zymolyase,
    % concentrations, temperatures, and times, and saves it in the specified path.

    figure('Position', [100, 100, 1200, 800]);

    % Determine the number of combinations and generate color lines
    num_combinations = length(unique_zym) * length(unique_conc) * length(unique_temps);
    colors = lines(num_combinations);

    % Define available markers and line styles
    available_markers = {'o', '+', '*', 's', 'd', '^', 'v', '>', '<', 'p', 'h', 'x', '|', '_'};
    num_markers = length(available_markers);
    extra_colors_needed = length(unique_times) - num_combinations;
    
    % Add extra colors if needed
    if extra_colors_needed > 0
        extra_colors = hsv(extra_colors_needed);
        colors = [colors; extra_colors];
    end

    line_styles = {'-', '--', ':', '-.'};
    num_line_styles = length(line_styles);

    hold on;

    % Initialize legend entries and handles
    legend_entries = {};
    legend_index = 1;
    handles = [];

    % Loop through each zymolyase, concentration, and temperature combination
    for i = 1:length(unique_zym)
        for c = 1:length(unique_conc)
            for t = 1:length(unique_temps)
                % Filter probability data for the current combination
                current_zym_data = probability(probability.zymolyase == unique_zym(i) & ...
                                               probability.concentration == unique_conc(c) & ...
                                               probability.temperature == unique_temps(t), :);

                % Loop through each unique time to plot data
                for j = 1:length(unique_times)
                    current_time_data = current_zym_data(current_zym_data.time == unique_times(j), :);

                    % Plot if data is available for the current time
                    if ~isempty(current_time_data)
                        log_probability = current_time_data.probability;
                        log_positive_sd = current_time_data.positive_sd;

                        % Determine color, marker, and line style based on the current indices
                        color_index = (i - 1) * length(unique_conc) * length(unique_temps) + (c - 1) * length(unique_temps) + t;
                        current_color = colors(mod(color_index-1, size(colors, 1)) + 1, :);

                        time_marker_index = mod(j-1, num_markers) + 1;
                        time_marker = available_markers{time_marker_index};

                        line_style = line_styles{mod(j-1, num_line_styles) + 1};

                        marker_color = colors(mod(color_index + j - 1, size(colors, 1)) + 1, :);

                        % Plot data with error bars
                        h = plot(current_time_data.area, log_probability, 'LineStyle', line_style, ...
                            'Marker', time_marker, 'Color', current_color, ...
                            'MarkerFaceColor', marker_color);
                        errorbar(current_time_data.area, log_probability, log_positive_sd, 'LineStyle', 'none', ...
                            'Marker', time_marker, 'Color', current_color, ...
                            'MarkerFaceColor', marker_color);

                        % Store the plot handle and legend entry
                        handles = [handles; h];
                        legend_entries{legend_index} = ['Zymolyase ' num2str(unique_zym(i)) ' mg/mL, Concentration ' num2str(unique_conc(c)) ', Temperature ' num2str(unique_temps(t)) ', Time ' num2str(unique_times(j))];
                        legend_index = legend_index + 1;
                    end
                end
            end
        end
    end

    % Set plot labels and title
    xlabel('Number of Cells');
    ylabel('Probability (Semilog)');
    title('Probability of Each Number of Cells for Different Zymolyase Concentrations, Concentrations, Temperatures and Times');

    % Add legend and save the plot
    legend(handles, legend_entries, 'Location', 'southeastoutside');
    save_plot(path_save, subfolder, 'log_plot_probabilities_all_zymolyase');
end

function plot_combined_cells(probability, unique_zym, unique_conc, unique_areas, unique_temps, path_save, subfolder)
    % This function creates combined plots of probabilities across different areas,
    % zymolyase concentrations, concentrations, and temperatures, saving the results.

    % Define markers and colors
    markers_0 = {'o', 's', '^', 'd', 'v', '>', '<'};
    markers_0_1 = {'x', '*', '.', 's', 'd', '^', 'v'};
    colors = lines(length(unique_zym) * length(unique_conc) * length(unique_temps));

    num_areas = length(unique_areas);
    num_zym = length(unique_zym);
    num_conc = length(unique_conc);
    num_temps = length(unique_temps);

    % Set up the figure and tiled layout for subplots
    figure('Position', [100, 100, 1400, 800]);
    tcl = tiledlayout(ceil(num_areas / 2), 2, 'TileSpacing', 'compact', 'Padding', 'compact');

    % Initialize legend entries and handles
    legend_entries = {};
    legend_handles = []; 

    % Loop through each unique area
    for j = 1:num_areas
        nexttile(tcl);
        hold on;

        % Loop through each zymolyase, concentration, and temperature combination
        for k = 1:num_zym
            for c = 1:num_conc
                for t = 1:num_temps
                    % Filter probability data for the current combination and area
                    current_zym_data = probability(probability.zymolyase == unique_zym(k) & ...
                                                   probability.concentration == unique_conc(c) & ...
                                                   probability.temperature == unique_temps(t) & ...
                                                   probability.area == unique_areas(j), :);

                    % Plot if data is available for the current area
                    if ~isempty(current_zym_data)
                        log_probability = current_zym_data.probability;
                        log_positive_sd = current_zym_data.positive_sd;

                        color_index = (k - 1) * num_conc * num_temps + (c - 1) * num_temps + t;
                        current_color = colors(color_index, :);

                        % Select markers based on zymolyase value
                        if unique_zym(k) == 0
                            current_marker = markers_0{c};
                        else
                            current_marker = markers_0_1{c};
                        end

                        % Plot with error bars
                        h = errorbar(current_zym_data.time, log_probability, log_positive_sd, 'LineStyle', '-', ...
                            'Marker', current_marker, 'Color', current_color, ...
                            'MarkerFaceColor', current_color);

                        % Add to legend for the first subplot
                        if j == 1 
                            legend_handles(end+1) = h;
                            legend_entries{end+1} = sprintf('Zymolyase %d mg/mL, Concentration %d, Temperature %d', ...
                                                            unique_zym(k), unique_conc(c), unique_temps(t));
                        end
                    end
                end
            end
        end

        % Set subplot labels and title
        xlabel('Time');
        ylabel('Probability');
        title(sprintf('Area %d', unique_areas(j)));
        ylim([0, 1]);
    end

    % Create the legend and save the plot
    hL = legend(legend_handles, legend_entries);
    hL.FontSize = 6;
    hL.ItemTokenSize = [5, 5];
    hL.Position = [0.65, 0.01, 0.15, 0.1];

    saveas(gcf, fullfile(path_save, subfolder, 'combined_plot_probabilities_all_cells.png'));
    close(gcf);
end

function save_plot(path_save, subfolder, filename)
    % Save the current figure in TIFF and FIG formats to the specified path and subfolder
    file_path = fullfile(path_save, subfolder, [filename '.tif']);
    file_path2 = fullfile(path_save, subfolder, [filename '.fig']);
    saveas(gcf, file_path);
    saveas(gcf, file_path2);
    close(gcf);
end
