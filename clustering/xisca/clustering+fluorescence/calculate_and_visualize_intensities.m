function calculate_and_visualize_intensities(brightfieldImage, cellCentroidsFluorescence1, cellCentroidsFluorescence2, folderPath)
    cellIntensityValuesFluorescence1 = zeros(size(cellCentroidsFluorescence1, 1), 1);
for i = 1:size(cellCentroidsFluorescence1, 1)
    x = round(cellCentroidsFluorescence1(i, 1));
    y = round(cellCentroidsFluorescence1(i, 2));
    cellIntensityValuesFluorescence1(i) = brightfieldImage(y, x);
end

% Calculate cell intensities
cellIntensityValuesFluorescence2 = zeros(size(cellCentroidsFluorescence2, 1), 1);
for i = 1:size(cellCentroidsFluorescence2, 1)
    x = round(cellCentroidsFluorescence2(i, 1));
    y = round(cellCentroidsFluorescence2(i, 2));
    cellIntensityValuesFluorescence2(i) = brightfieldImage(y, x);
end

% Create a new figure without displaying it
fig_fluorescence1 = figure('Visible', 'off');

% Visualize centroids of individual cells and plot cell intensities
for i = 1:numel(cellCentroidsFluorescence1)
    try
        % Plot centroids
        plot(cellCentroidsFluorescence1(i, 1), cellCentroidsFluorescence1(i, 2), 'bo', 'MarkerSize', 5, 'LineWidth', 0.5);
        hold on;
        
        % Plot cell intensities
        text(cellCentroidsFluorescence1(i, 1) + 5, cellCentroidsFluorescence1(i, 2) + 5, num2str(cellIntensityValuesFluorescence1(i)), 'Color', 'blue', 'FontSize', 6, 'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom');
    catch
        disp(['Error: Index ', num2str(i), ' exceeds array bounds. Skipping...']);
    end
end
title('Intensity of cells of Fluorescence 1');

% Calculate the mean, maximum, and minimum cell intensities for fluorescence 1
meanIntensityFluorescence1 = mean(cellIntensityValuesFluorescence1);
maxIntensityFluorescence1 = max(cellIntensityValuesFluorescence1);
minIntensityFluorescence1 = min(cellIntensityValuesFluorescence1);
numCellsFluorescence1 = numel(cellCentroidsFluorescence1);

% Display statistics in the corner of the plot
text(0.02, 0.98, ['Mean Intensity: ', num2str(meanIntensityFluorescence1), ', Max Intensity: ', num2str(maxIntensityFluorescence1), ', Min Intensity: ', num2str(minIntensityFluorescence1), ', Number of Cells: ', num2str(numCellsFluorescence1)], 'Color', 'red', 'FontSize', 8, 'Units', 'normalized', 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top');

% Specify the file name and path
fig_filename = fullfile(folderPath, 'fluorescence1_with_centroids_and_intensity.fig');
saveas(fig_fluorescence1, fig_filename);

filename = fullfile(folderPath, 'fluorescence1_with_centroids_and_intensity.tif');
% Set the resolution (DPI)
resolution = 300; % Adjust as needed
% Save the figure as an image with higher resolution
print(fig_fluorescence1, filename, '-dtiff', ['-r', num2str(resolution)]);

% Close the figure to avoid cluttering the workspace
close(fig_fluorescence1);

% Create a new figure without displaying it
fig_fluorescence2 = figure('Visible', 'off');

% Visualize centroids of individual cells and plot cell intensities
for i = 1:numel(cellCentroidsFluorescence2)
    try
        % Plot centroids
        plot(cellCentroidsFluorescence2(i, 1), cellCentroidsFluorescence2(i, 2), 'go', 'MarkerSize', 5, 'LineWidth', 0.5);
        hold on;
        
        % Plot cell intensities
        text(cellCentroidsFluorescence2(i, 1) + 5, cellCentroidsFluorescence2(i, 2) + 5, num2str(cellIntensityValuesFluorescence2(i)), 'Color', 'green', 'FontSize', 6, 'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom');
    catch
        disp(['Error: Index ', num2str(i), ' exceeds array bounds. Skipping...']);
    end
end
title('Intensity of cells of Fluorescence 2');

% Calculate the mean, maximum, and minimum cell intensities for fluorescence 1
meanIntensityFluorescence2 = mean(cellIntensityValuesFluorescence2);
maxIntensityFluorescence2 = max(cellIntensityValuesFluorescence2);
minIntensityFluorescence2 = min(cellIntensityValuesFluorescence2);
numCellsFluorescence2 = numel(cellCentroidsFluorescence2);

% Display statistics in the corner of the plot
text(0.02, 0.98, ['Mean Intensity: ', num2str(meanIntensityFluorescence2), ', Max Intensity: ', num2str(maxIntensityFluorescence2), ', Min Intensity: ', num2str(minIntensityFluorescence2), ', Number of Cells: ', num2str(numCellsFluorescence2)], 'Color', 'red', 'FontSize', 8, 'Units', 'normalized', 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top');

% Specify the file name and path
fig_filename = fullfile(folderPath, 'fluorescence2_with_centroids_and_intensity.fig');
saveas(fig_fluorescence2, fig_filename);

filename = fullfile(folderPath, 'fluorescence2_with_centroids_and_intensity.tif');
% Set the resolution (DPI)
resolution = 300; % Adjust as needed
% Save the figure as an image with higher resolution
print(fig_fluorescence2, filename, '-dtiff', ['-r', num2str(resolution)]);

% Close the figure to avoid cluttering the workspace
close(fig_fluorescence2);
end
