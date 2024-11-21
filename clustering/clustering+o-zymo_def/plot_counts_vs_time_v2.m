function plot_counts_vs_time_v2(csvTable, value, path)
    % Extract unique Zymolyase, Velocity, and Time values
    uniqueZymolyase = unique(csvTable.Zymolyase);
    uniqueVelocity = unique(csvTable.Velocity);
    uniqueTime = unique(csvTable.Time);
    
    % Define the number of wells representing the same sample for Zymolyase plot
    wellsPerSampleZymolyase = 3;
    
    % Define the number of wells representing the same sample for Velocity plot
    wellsPerSampleVelocity = 6;
    
    % Calculate the number of samples
    numSamplesZymolyase = length(unique(csvTable.Well)) / wellsPerSampleZymolyase;
    numSamplesVelocity = length(uniqueTime);  % Counting unique times for velocity plot

    subfolder = 'plots_counts';
    
    if ~exist(fullfile(path, subfolder), 'dir')
        mkdir(fullfile(path, subfolder));
    end
  
    % Define markers and colormap for multiple plots
    markers = {'o', 's', 'd', '^', 'v', '>', '<', 'p', 'h', '+', '*', '.', 'x', 's', 'd', '^'};
    cmap = lines(numSamplesVelocity);  % Colormap based on number of unique time samples

    %% Plot for Zymolyase
    fig1 = figure;
    fig1.Position(3:4) = [1200, 800]; % Width, Height
    
    hold on;
  
    legendStrings = cell(ceil(length(uniqueZymolyase) * numSamplesZymolyase), 1);
    idx = 1;
    
    for z = 1:length(uniqueZymolyase)
        for s = 1:numSamplesZymolyase
            sampleWells = (s-1)*wellsPerSampleZymolyase + (1:wellsPerSampleZymolyase);
            
            indices = csvTable.Zymolyase == uniqueZymolyase(z) & ismember(csvTable.Well, sampleWells);
            zymoSampleData = csvTable(indices, :);
            
            if isempty(zymoSampleData)
                continue;
            end

            [uniqueTimes, ~, timeIdx] = unique(zymoSampleData.Time);
            meanCounts = accumarray(timeIdx, zymoSampleData.count, [], @mean);
            stdCounts = accumarray(timeIdx, zymoSampleData.count, [], @std);

            errorbar(uniqueTimes, meanCounts, stdCounts, markers{mod(s-1, length(markers))+1}, ...
                     'LineStyle', '-', 'Color', cmap(mod(s-1, numSamplesVelocity)+1,:), 'MarkerFaceColor', cmap(mod(s-1, numSamplesVelocity)+1,:));

            legendStrings{idx} = sprintf('Zymolyase %.2f, Sample %d', uniqueZymolyase(z), s);
            idx = idx + 1;
        end
    end
  
    xlabel('Time (s)');
    ylabel('Count');
  
    legendStrings = legendStrings(~cellfun('isempty', legendStrings));
    hLegend = legend(legendStrings, 'Location', 'northeast', 'NumColumns', 2);
    hLegend.FontSize = 7.8;
    
    title(sprintf('Count of clusters of %d cells along the times (by Zymolyase and Samples)', value));
  
    hold off;

    filename = fullfile(path, subfolder, ['Count_single_cells_zymolyase_', num2str(value), '.png']);
    saveas(fig1, filename);
    filename2 = fullfile(path, subfolder, ['Count_single_cells_zymolyase_', num2str(value), '.fig']);
    saveas(fig1, filename2);
    close(fig1);

    %% Plot for Velocity
    fig2 = figure;
    fig2.Position(3:4) = [1200, 800]; % Width, Height
    
    hold on;
    
    legendStrings = cell(numSamplesVelocity, 1);
    idx = 1;

    for s = 1:numSamplesVelocity
        sampleTimes = uniqueTime(s);
        
        indices = ismember(csvTable.Time, sampleTimes);
        velocitySampleData = csvTable(indices, :);
        
        if isempty(velocitySampleData)
            continue;
        end

        [uniqueVelocities, ~, velIdx] = unique(velocitySampleData.Velocity);
        meanCounts = accumarray(velIdx, velocitySampleData.count, [], @mean);
        stdCounts = accumarray(velIdx, velocitySampleData.count, [], @std);

        errorbar(uniqueVelocities, meanCounts, stdCounts, markers{mod(s-1, length(markers))+1}, ...
                 'LineStyle', '-', 'Color', cmap(mod(s-1, numSamplesVelocity)+1,:), 'MarkerFaceColor', cmap(mod(s-1, numSamplesVelocity)+1,:));

        legendStrings{idx} = sprintf('Velocity at Time %.1f', sampleTimes);
        idx = idx + 1;
    end
    
    xlabel('Velocity (rpm)');
    ylabel('Count');
    
    legendStrings = legendStrings(~cellfun('isempty', legendStrings));
    hLegend = legend(legendStrings, 'Location', 'northeast', 'NumColumns', 2);
    hLegend.FontSize = 7.8;
    
    title(sprintf('Count of clusters of %d cells along the velocities (by Time and Samples)', value));
  
    hold off;

    filename = fullfile(path, subfolder, ['Count_single_cells_velocity_', num2str(value), '.png']);
    saveas(fig2, filename);
    filename2 = fullfile(path, subfolder, ['Count_single_cells_velocity_', num2str(value), '.fig']);
    saveas(fig2, filename2);
    close(fig2);

    %% New Aggregated Plot for Zymolyase and Velocity by Time
   %% New Aggregated Plot for Zymolyase and Velocity by Time
    fig3 = figure;
    fig3.Position(3:4) = [1200, 800]; % Width, Height
    
    hold on;
    
    % Generate a colormap and markers for unique combinations of Zymolyase and Velocity
    legendStrings = cell(length(uniqueZymolyase) * length(uniqueVelocity), 1);
    idx = 1;
    
    % Define a separate set of markers specifically for this plot to avoid reuse
    distinctMarkers = {'o', 's', 'd', '^', 'v', '>', '<', 'p', 'h', '+', '*', '.', 'x', 's', 'd', '^'};
    numMarkers = length(distinctMarkers);  % Get the number of available markers
    
    for z = 1:length(uniqueZymolyase)
        for v = 1:length(uniqueVelocity)
            indices = csvTable.Zymolyase == uniqueZymolyase(z) & csvTable.Velocity == uniqueVelocity(v);
            aggregatedData = csvTable(indices, :);
            
            if isempty(aggregatedData)
                continue;
            end
    
            [uniqueTimes, ~, timeIdx] = unique(aggregatedData.Time);
            meanCounts = accumarray(timeIdx, aggregatedData.count, [], @mean);
            stdCounts = accumarray(timeIdx, aggregatedData.count, [], @std);
    
            % Select marker and color for the current combination of Zymolyase and Velocity
            markerIdx = mod((z-1) * length(uniqueVelocity) + (v-1), numMarkers) + 1;  % Ensure index is within bounds
            colorIdx = mod((z-1) * length(uniqueVelocity) + (v-1), numSamplesVelocity) + 1;  % Color index cycling
    
            errorbar(uniqueTimes, meanCounts, stdCounts, distinctMarkers{markerIdx}, ...
                     'LineStyle', '-', 'Color', cmap(colorIdx, :), 'MarkerFaceColor', cmap(colorIdx, :));
    
            % Create legend string for this combination
            legendStrings{idx} = sprintf('Zymolyase %.2f, Velocity %.1f', uniqueZymolyase(z), uniqueVelocity(v));
            idx = idx + 1;
        end
    end
    
    xlabel('Time (s)');
    ylabel('Count');
    
    % Filter out empty legend strings
    legendStrings = legendStrings(~cellfun('isempty', legendStrings));
    hLegend = legend(legendStrings, 'Location', 'northeast', 'NumColumns', 2);
    hLegend.FontSize = 7.8;
    
    title(sprintf('Mean count of clusters of %d cells by Zymolyase and Velocity at each Time', value));
    
    hold off;
    
    filename = fullfile(path, subfolder, ['Count_single_cells_by_time_and_zymolyase_velocity_', num2str(value), '.png']);
    saveas(fig3, filename);
    filename2 = fullfile(path, subfolder, ['Count_single_cells_by_time_and_zymolyase_velocity_', num2str(value), '.fig']);
    saveas(fig3, filename2);
    close(fig3);
end
