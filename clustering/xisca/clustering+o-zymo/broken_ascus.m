function broken_ascus(data, path_save)

    % Default argument handling
    if nargin < 2
        path_save = '';
    end

    % Filter out rows where Time is NaN
    clean_data = data(~isnan(data.Time), :);
    subfolder = 'results';
    subfolder2 = 'plots';
    
    % Create subfolder if it doesn't exist
    if ~exist(fullfile(path_save, subfolder), 'dir')
        mkdir(fullfile(path_save, subfolder));
    end

        if ~exist(fullfile(path_save, subfolder2), 'dir')
        mkdir(fullfile(path_save, subfolder2));
    end

    % Display the first few rows of the input data for verification
    disp(head(data));

    % Initialize arrays to store results
    results_zymolyase = [];
    results_time = [];
    results_replica = [];
    results_well = [];
    results_haploid = [];
    results_diploid = [];
    results_ascus = [];

    % Loop through unique combinations of Time, Replica, and Well
    uniqueZymolyase = unique(clean_data.Zymolyase);
    uniqueTimes = unique(clean_data.Time);
    uniqueReplicas = unique(clean_data.Replica);
    uniqueWells = unique(clean_data.Well);
    for p = 1:length(uniqueZymolyase)
        for t = 1:length(uniqueTimes)
            for r = 1:length(uniqueReplicas)
                for s = 1:length(uniqueWells)

                % Filter data for the current Time, Replica, and Well
                currentZymolyase = uniqueZymolyase(p);
                currentTime = uniqueTimes(t);
                currentReplica = uniqueReplicas(r);
                currentWell = uniqueWells(s);

                dataCurrentSubset = clean_data(ismember(clean_data.Time, currentTime) & ...
                                               ismember(clean_data.Replica, currentReplica) & ...
                                               ismember(clean_data.Zymolyase, currentZymolyase) & ...
                                               ismember(clean_data.Well, currentWell), :);

                % Get unique labels within this subset
                uniqueLabels = unique(dataCurrentSubset.Enumeration);

                % Initialize counts
                haploid_count = 0;
                diploid_count = 0;
                ascus_count = 0;

                % Loop through each unique label
                for i = 1:length(uniqueLabels)
                    % Filter data for the current label
                    currentLabel = uniqueLabels(i);
                    dataCurrentLabel = dataCurrentSubset(ismember(dataCurrentSubset.Enumeration, currentLabel), :);

                    % Determine cell type based on criteria
                    if (dataCurrentLabel.MajorAxisLength - dataCurrentLabel.MinorAxisLength > 10)
                        diploid_count = diploid_count + 1;
                    elseif (dataCurrentLabel.Perimeter > 150)
                        ascus_count = ascus_count + 1;
                    else
                        haploid_count = haploid_count + 1;
                    end
                end

                % Store results
                results_zymolyase = [results_zymolyase; currentZymolyase];
                results_time = [results_time; currentTime];
                results_replica = [results_replica; currentReplica];
                results_well = [results_well; currentWell];
                results_haploid = [results_haploid; haploid_count];
                results_diploid = [results_diploid; diploid_count];
                results_ascus = [results_ascus; ascus_count];
                end
            end
        end
    end

    % Create table with aggregated results
    results = table(results_zymolyase, results_time, results_replica, results_well, ...
                    results_haploid, results_diploid, results_ascus, ...
                    'VariableNames', {'Zymolyase','Time', 'Replica', 'Well', 'Haploid', 'Diploid', 'Ascus'});

     % Remove rows where Haploid, Diploid, and Ascus are all zero
    results = results(~(results.Haploid == 0 & results.Diploid == 0 & results.Ascus == 0), :);

    % Save the results table to a CSV file in the subfolder
    outputFile = fullfile(path_save, subfolder, 'aggregatedCells_results.csv');
    writetable(results, outputFile);

    % Calculate average ascus per time and zymolyase
    avg_ascus = varfun(@mean, results, 'InputVariables', 'Ascus', ...
                       'GroupingVariables', {'Zymolyase', 'Time'});

    % Save the average ascus table to a CSV file in the subfolder
    outputFileAvg = fullfile(path_save, subfolder, 'average_ascus_results.csv');
    writetable(avg_ascus, outputFileAvg);

    % Calculate broken ascus percentages
    uniqueTimes = unique(avg_ascus.Time);
    broken_ascus_table = table();
    for t = 2:length(uniqueTimes)
        time_previous = uniqueTimes(t-1);
        time_current = uniqueTimes(t);

        data_previous = avg_ascus(avg_ascus.Time == time_previous, :);
        data_current = avg_ascus(avg_ascus.Time == time_current, :);

        % Initialize an array to hold the percentages
        percent_broken_ascus = NaN(height(data_previous), 1);

        % Calculate broken ascus percentage for each zymolyase condition
        for i = 1:height(data_previous)
            zymolyase = data_previous.Zymolyase(i);
            ascus_previous = data_previous.mean_Ascus(i);
            ascus_current = data_current.mean_Ascus(data_current.Zymolyase == zymolyase);

            if ~isempty(ascus_current) && ascus_previous > 0
                percent_broken_ascus(i) = ((ascus_previous - ascus_current) / ascus_previous) * 100;
            end
        end

        % Add to the broken_ascus_table
        broken_ascus_table = [broken_ascus_table; ...
                              table(repmat(time_current, height(data_previous), 1), ...
                                    data_previous.Zymolyase, ...
                                    percent_broken_ascus, ...
                                    'VariableNames', {'Time', 'Zymolyase', 'PercentBrokenAscus'})];
    end

    % Save the broken ascus table to a CSV file in the subfolder
    outputFileBroken = fullfile(path_save, subfolder, 'broken_ascus_results.csv');
    writetable(broken_ascus_table, outputFileBroken);

    % Plot percentage of broken ascus over time for each zymolyase condition
    figure;
    hold on;
    for z = 1:length(uniqueZymolyase)
        currentZymolyase = uniqueZymolyase(z);
        dataToPlot = broken_ascus_table(broken_ascus_table.Zymolyase == currentZymolyase, :);
        plot(dataToPlot.Time, dataToPlot.PercentBrokenAscus, '-o', 'DisplayName', ['Zymolyase ', num2str(currentZymolyase)]);
    end
    xlabel('Time');
    ylabel('Percentage of Broken Ascus');
    title('Percentage of Broken Ascus Over Time');
    legend('show');
    hold off;

    % Save the figure in both .png and .fig formats
    outputFigBrokenPNG = fullfile(path_save, subfolder2, 'broken_ascus_plot.png');
    outputFigBrokenFIG = fullfile(path_save, subfolder2, 'broken_ascus_plot.fig');
    saveas(gcf, outputFigBrokenPNG);
    saveas(gcf, outputFigBrokenFIG);

end
