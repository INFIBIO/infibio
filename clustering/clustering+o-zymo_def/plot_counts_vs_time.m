function plot_counts_vs_time(csvTable, value, path)
  
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

    subfolder = 'plots';
    
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
  
    legendStrings = cell(length(uniqueZymolyase) * numSamplesZymolyase, 1);
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

            legendStrings{idx} = sprintf('Zymolyase %.1f, Sample %d', uniqueZymolyase(z), s);
            idx = idx + 1;
        end
    end
  
    xlabel('Time');
    ylabel('Count');
  
    legendStrings = legendStrings(~cellfun('isempty', legendStrings));
    hLegend = legend(legendStrings);
    hLegend.FontSize = 7.8;
    
    hLegend.Position = [0.85, 0.65, 0.1, 0.1]; % [left, bottom, width, height]
    
    title(sprintf('Count of single cells along the times (by Zymolyase and Samples)', value));
  
    hold off;

    filename = fullfile(path, subfolder, ['Count_single_cells_zymolyase_', num2str(value), '.tif']);
    filename2 = fullfile(path, subfolder, ['Count_single_cells_zymolyase_', num2str(value), '.fig']);

    saveas(fig1, filename);
    saveas(fig1, filename2);

    %% Plot for Velocity
    fig2 = figure;
    fig2.Position(3:4) = [1200, 800]; % Width, Height
  
    hold on;
  
    legendStrings = cell(numSamplesVelocity, 1);
    
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
        
        legendStrings{s} = sprintf('Velocity at Time %.1f', sampleTimes);
    end
  
    xlabel('Velocity');
    ylabel('Count');
  
    legendStrings = legendStrings(~cellfun('isempty', legendStrings));
    hLegend = legend(legendStrings);
    hLegend.FontSize = 7.8;
    
    hLegend.Position = [0.85, 0.65, 0.1, 0.1]; % [left, bottom, width, height]
    
    title(sprintf('Count of single cells along the velocities (by Time and Samples)', value));
  
    hold off;

    filename = fullfile(path, subfolder, ['Count_single_cells_velocity_', num2str(value), '.tif']);
    filename2 = fullfile(path, subfolder, ['Count_single_cells_velocity_', num2str(value), '.fig']);

    saveas(fig2, filename);
    saveas(fig2, filename2);

end
