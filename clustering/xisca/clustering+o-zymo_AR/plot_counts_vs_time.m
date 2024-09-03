function plot_counts_vs_time(csvTable, value, path)
% This function plots the count of single cells versus time, grouped by
% Zymolyase concentration, Concentration, and Temperature. It also handles
% multiple samples per condition and saves the plot to specified paths.
%
% INPUTS:
% - csvTable: A table containing data with columns: Zymolyase, Concentration,
%   Temperature, Time, Well, and count.
% - value: A numeric value used in the plot title and filename.
% - path: Directory path where the plot will be saved.

    % Extract unique Zymolyase, Concentration, and Temperature values from the table.
    uniqueZymolyase = unique(csvTable.Zymolyase);
    uniqueConcentration = unique(csvTable.Concentration);
    uniqueTemperature = unique(csvTable.Temperature);
    
    % Define the number of wells that represent the same sample.
    wellsPerSample = 3;
    
    % Calculate the number of unique samples based on the number of wells
    numSamples = length(unique(csvTable.Well)) / wellsPerSample;

    % Define the subfolder for saving plots
    subfolder = 'plots';
    
    % Create the subfolder if it doesn't exist
    if ~exist(fullfile(path, subfolder), 'dir')
        mkdir(fullfile(path, subfolder));
    end
  
    % Define a set of markers to differentiate between plots
    markers = {'o', 's', 'd', '^', 'v', '>', '<', 'p', 'h'}; % Various markers
  
    % Define a colormap for differentiating multiple plots
    cmap = lines(length(uniqueZymolyase) * length(uniqueConcentration) * length(uniqueTemperature) * numSamples);

    % Initialize a figure for plotting
    fig = figure;
  
    % Set the width and height of the figure window
    fig.Position(3:4) = [1200, 800]; % Width, Height
  
    hold on;
  
    % Initialize cell array to hold legend entries
    legendStrings = cell(length(uniqueZymolyase) * length(uniqueConcentration) * length(uniqueTemperature) * numSamples, 1);
    idx = 1;
    
    % Loop through each combination of Zymolyase, Concentration, and Temperature
    for z = 1:length(uniqueZymolyase)
        for c = 1:length(uniqueConcentration)
            for t = 1:length(uniqueTemperature)
                
                % Find indices in the table that match the current combination of Zymolyase, Concentration, and Temperature
                indices = csvTable.Zymolyase == uniqueZymolyase(z) & ...
                          csvTable.Concentration == uniqueConcentration(c) & ...
                          csvTable.Temperature == uniqueTemperature(t);
                
                % Extract the data for the current combination
                zymoConcTempSampleData = csvTable(indices, :);
                
                % Skip if no data is found for the current combination
                if isempty(zymoConcTempSampleData)
                    continue;
                end

                % Group data by Time and compute mean and standard deviation for counts
                [uniqueTimes, ~, timeIdx] = unique(zymoConcTempSampleData.Time);
                meanCounts = accumarray(timeIdx, zymoConcTempSampleData.count, [], @mean);
                stdCounts = accumarray(timeIdx, zymoConcTempSampleData.count, [], @std);

                % Plot the data with error bars for this combination
                errorbar(uniqueTimes, meanCounts, stdCounts, markers{mod(t-1, length(markers))+1}, 'LineStyle', '-', 'Color', cmap(idx,:), 'MarkerFaceColor', cmap(idx,:));

                % Store the legend entry for this plot
                legendStrings{idx} = sprintf('Zymolyase %.1f, Conc %.1f, Temp %.1f', uniqueZymolyase(z), uniqueConcentration(c), uniqueTemperature(t));
                idx = idx + 1;
            end
        end
    end
  
    % Customize the plot
    xlabel('Time');
    ylabel('Count');
  
    % Remove empty cells from legend strings and create legend
    legendStrings = legendStrings(~cellfun('isempty', legendStrings));
    hLegend = legend(legendStrings);
  
    % Set font size and position for the legend
    hLegend.FontSize = 7.8;
    hLegend.Position = [0.85, 0.66, 0.1, 0.1]; % [left, bottom, width, height]
    
    % Set the title of the plot
    title(sprintf('Count of single cells along the times (by Zymolyase, Concentration, Temperature, and Samples)', value));
  
    hold off;

    % Create the filename for saving the plot
    filename = fullfile(path, subfolder, ['Count_single_cells_', num2str(value), '.tif']);
    filename2 = fullfile(path, subfolder, ['Count_single_cells_', num2str(value), '.fig']);

    % Save the current figure as TIFF and FIG files
    saveas(fig, filename);
    saveas(fig, filename2);

end
