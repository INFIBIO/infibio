function [percentageFluorescent1, percentageFluorescent2, percentageFluorescent12, matchedCellsFluorescence12, numIndividualCellsFluorescence12, numChainedCellsFluorescence12] = ...
    data_analysis(matchedCellsFluorescence1, matchedCellsFluorescence2, matchedCellsFluorescence12, ...
    bwBrightfield, cellPropertiesFluorescence1, cellCentroidsFluorescence1, brightfieldImage, folderPath)

    % Define tolerance for centroid matching
    centroidTolerance = 10; % Adjust as needed based on your images

    minorAxisLengths = [];
    majorAxisLengths = [];

    for i = 1:size(matchedCellsFluorescence12, 1)
        centroid = matchedCellsFluorescence12(i, 1:2);

        % Compare with fluorescence image 1
        for j = 1:size(cellCentroidsFluorescence1, 1)
            centroidFluorescence1 = cellCentroidsFluorescence1(j, :);
            if norm(centroid - centroidFluorescence1) <= centroidTolerance
                minorAxisLengths(end+1) = cellPropertiesFluorescence1(j).MinorAxisLength;
                majorAxisLengths(end+1) = cellPropertiesFluorescence1(j).MajorAxisLength;
                break;
            end
        end
    end

    % Concatenate Minor and Major axis lengths with matchedCellsFluorescence12
    matchedCellsFluorescence12 = [matchedCellsFluorescence12, minorAxisLengths', majorAxisLengths'];

    % Calculate percentages
    totalBrightfieldCells = numel(bwBrightfield);
    totalMatchedCellsFluorescence1 = numel(matchedCellsFluorescence1);
    totalMatchedCellsFluorescence2 = numel(matchedCellsFluorescence2);
    totalMatchedCellsFluorescence12 = numel(matchedCellsFluorescence12);

    percentageFluorescent1 = (totalMatchedCellsFluorescence1 / totalBrightfieldCells) * 100;
    percentageFluorescent2 = (totalMatchedCellsFluorescence2 / totalBrightfieldCells) * 100;
    percentageFluorescent12 = (totalMatchedCellsFluorescence12 / totalBrightfieldCells) * 100;

    % Save data to CSV
    csvwrite(fullfile(folderPath, 'matched_cells_fluorescence1_data.csv'), matchedCellsFluorescence1);
    csvwrite(fullfile(folderPath, 'matched_cells_fluorescence2_data.csv'), matchedCellsFluorescence2);
    csvwrite(fullfile(folderPath, 'matched_cells_fluorescence12_data.csv'), matchedCellsFluorescence12);

    % Calculate aspect ratios for matched cells in Fluorescence 1 and 2
    aspectRatiosFluorescence12 = majorAxisLengths ./ minorAxisLengths;

    % Define a threshold for aspect ratio to differentiate between individual cells and chained cells
    aspectRatioThreshold = 2; % Adjust as needed

    % Check if matched cells are individual or chained based on aspect ratio
    individualCellsFluorescence12 = aspectRatiosFluorescence12 <= aspectRatioThreshold;

    % Count the number of individual cells and chained cells
    numIndividualCellsFluorescence12 = sum(individualCellsFluorescence12);
    numChainedCellsFluorescence12 = numel(individualCellsFluorescence12) - numIndividualCellsFluorescence12;

    % Display the results
    disp(['Fluorescence 1 and 2: Individual Cells = ', num2str(numIndividualCellsFluorescence12), ', Chained Cells = ', num2str(numChainedCellsFluorescence12)]);

    % Store the displayed results in variables
    resultLabels = {'Fluorescence 1 and 2: Individual Cells', 'Fluorescence 1 and 2: Chained Cells'};
    resultValues = [numIndividualCellsFluorescence12, numChainedCellsFluorescence12];

    % Save the displayed results to a CSV file
    resultsTable = table(resultLabels', resultValues', 'VariableNames', {'Label', 'Value'});
    writetable(resultsTable, fullfile(folderPath, 'matched_cells_analysis_results.csv'));

    % Visualize matched cells for validation
        fig_matchedcells=figure;
        imshow(brightfieldImage);
        hold on;
        title('Matched Cells in Brightfield Image with Fluorescence Channel 1 and 2');
        for i = 1:size(matchedCellsFluorescence12, 1)
            centroid = matchedCellsFluorescence12(i, :);
            plot(centroid(1), centroid(2), 'm*');
        end
        saveas(fig_matchedcells, fullfile(folderPath, 'matched_cells_fluorescence1_2.tif'));
        saveas(fig_matchedcells, fullfile(folderPath, 'matched_cells_fluorescence1_2.fig'));
        close(fig_matchedcells);

            % Plot the centroids of chained cells in the brightfield image
    fig_matchedcells = figure;
    imshow(brightfieldImage);
    hold on;

    % Plot centroids of individual cells
    individualCellCentroidsFluorescence12 = matchedCellsFluorescence12(individualCellsFluorescence12, :);
    plot(individualCellCentroidsFluorescence12(:, 1), individualCellCentroidsFluorescence12(:, 2), 'y*');

    % Plot centroids of chained cells
    chainedCellCentroidsFluorescence12 = matchedCellsFluorescence12(~individualCellsFluorescence12, :);
    plot(chainedCellCentroidsFluorescence12(:, 1), chainedCellCentroidsFluorescence12(:, 2), 'mo');

    title('Matched Cells in Brightfield Image with Fluorescence Channel 1 and 2');
    legend('Individual Cells', 'Chained/Clustered Cells', 'Location', 'southeast');
    saveas(fig_matchedcells, fullfile(folderPath, 'matched_cells_fluorescence1_2_indi-chain-cluster.tif'));
    saveas(fig_matchedcells, fullfile(folderPath, 'matched_cells_fluorescence1_2_indi-chain-cluster.fig'));
    close(fig_matchedcells);
end