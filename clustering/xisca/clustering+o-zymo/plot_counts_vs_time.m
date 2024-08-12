function plot_counts_vs_time(csvTable, value, path)
  
    % Extract unique Zymolyase and Concentration values.
    uniqueZymolyase = unique(csvTable.Zymolyase);
    uniqueConcentration = unique(csvTable.Concentration);
    
    % Define the number of wells representing the same sample
    wellsPerSample = 3;
    
    % Calculate the number of samples
    numSamples = length(unique(csvTable.Well)) / wellsPerSample;

    subfolder = 'plots';
    
    if ~exist(fullfile(path, subfolder), 'dir')
        mkdir(fullfile(path, subfolder));
    end
  
    % Define markers for different Zymolyase and Concentration conditions
    markers = {'o', 's', 'd', '^', 'v', '>', '<', 'p', 'h'};  % Various markers
  
    % Define a colormap for multiple plots (use a larger colormap for more samples)
    cmap = lines(length(uniqueZymolyase) * length(uniqueConcentration) * numSamples);  % Adjust colormap as needed

    % Initialize figure for plotting
    fig = figure;
  
    % Set the width and height of the plot
    fig.Position(3:4) = [1200, 800]; % Width, Height (increase width to make space for legend)
  
    hold on;
  
    % Loop through each unique Zymolyase, Concentration, and Sample, and plot counts vs. Time
    legendStrings = cell(length(uniqueZymolyase) * length(uniqueConcentration) * numSamples, 1);
    idx = 1;
    
    for z = 1:length(uniqueZymolyase)
        for c = 1:length(uniqueConcentration)
            
                %sampleWells = (s-1)*wellsPerSample + (1:wellsPerSample);
                
                % Find indices corresponding to current Zymolyase, Concentration, and sample wells
                indices = csvTable.Zymolyase == uniqueZymolyase(z) & ...
                          csvTable.Concentration == uniqueConcentration(c); 
                % & ismember(csvTable.Well, sampleWells);
                zymoConcSampleData = csvTable(indices, :);
                
                if isempty(zymoConcSampleData)
                    continue;
                end

                % Group data by Time
                [uniqueTimes, ~, timeIdx] = unique(zymoConcSampleData.Time);
                meanCounts = accumarray(timeIdx, zymoConcSampleData.count, [], @mean);
                stdCounts = accumarray(timeIdx, zymoConcSampleData.count, [], @std);

                % Plot the data for this Zymolyase-Concentration-Sample-Time combination with error bars
                errorbar(uniqueTimes, meanCounts, stdCounts, markers{mod(c-1, length(markers))+1}, 'LineStyle', '-', 'Color', cmap(idx,:), 'MarkerFaceColor', cmap(idx,:));

                % Store legend entry
                legendStrings{idx} = sprintf('Zymolyase %.1f, Conc %.1f', uniqueZymolyase(z), uniqueConcentration(c));
                idx = idx + 1;
            end
        end

  
    % Customize the plot (labels, title, etc.)
    xlabel('Time');
    ylabel('Count');
  
    % Remove empty cells from legend strings
    legendStrings = legendStrings(~cellfun('isempty', legendStrings));
    hLegend = legend(legendStrings);
  
    % Set font size for the legend
    hLegend.FontSize = 7.8;
    
    % Set the legend outside the plot area to the east (right side)
    hLegend.Position = [0.85, 0.66, 0.1, 0.1]; % [left, bottom, width, height]
    
    title(sprintf('Count of single cells along the times (by Zymolyase, Concentration, and Samples)', value));
  
    hold off;

    % Create the filename string
    filename = fullfile(path, subfolder, ['Count_single_cells_', num2str(value), '.tif']);
    filename2 = fullfile(path, subfolder, ['Count_single_cells_', num2str(value), '.fig']);

    % Save the current figure as a TIFF file
    saveas(fig, filename);
    saveas(fig, filename2);

end
