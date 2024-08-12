function color_images_with_identified_cells(processedFluorescence1, bwFluorescence11, processedFluorescence2, bwFluorescence22, folderPath)
% Fluorescence 1
% Convert the binary image to RGB
bwFluorescence11_rgb = cat(3, zeros(size(bwFluorescence11)), zeros(size(bwFluorescence11)), bwFluorescence11);

% Overlay identified cells with red color on the original image
fig_fluorescence1 = figure;
imshow(processedFluorescence1);
hold on;
title('Identified Cells in Fluorescence Image');
h = imshow(bwFluorescence11_rgb);
set(h, 'AlphaData', 0.6); % Adjust the transparency as needed

% Specify the file name and path
fig_filename = fullfile(folderPath, 'Identified_Cells_Fluorescence1.fig');
saveas(fig_fluorescence1, fig_filename);

filename = fullfile(folderPath, 'Identified_Cells_Fluorescence1.tif');
% Set the resolution (DPI)
resolution = 300; % Adjust as needed
% Save the figure as an image with higher resolution
print(fig_fluorescence1, filename, '-dtiff', ['-r', num2str(resolution)]);

% Fluorescence 2
% Convert the binary image to RGB
bwFluorescence22_rgb = cat(3, zeros(size(bwFluorescence22)), bwFluorescence22, zeros(size(bwFluorescence22)));

% Overlay identified cells with red color on the original image
fig_fluorescence2 = figure;
imshow(processedFluorescence2);
hold on;
title('Identified Cells in Fluorescence Image');
h = imshow(bwFluorescence22_rgb);
set(h, 'AlphaData', 0.6); % Adjust the transparency as needed

% Specify the file name and path for FIG file
fig_filename = fullfile(folderPath, 'Identified_Cells_Fluorescence2.fig');
saveas(fig_fluorescence2, fig_filename);

% Specify the file name and path for TIFF image
filename = fullfile(folderPath, 'Identified_Cells_Fluorescence2.tif');
% Set the resolution (DPI)
resolution = 300; % Adjust as needed
% Save the figure as an image with higher resolution
print(fig_fluorescence2, filename, '-dtiff', ['-r', num2str(resolution)]);

% Close the figure
close(fig_fluorescence2);

% To overlap images

processedFluorescence1_double = im2double(bwFluorescence11_rgb);
processedFluorescence2_double = im2double(bwFluorescence22_rgb);

% Set the transparency level for each image (adjust as needed)
alpha1 = 0.5; % Transparency level for image1
alpha2 = 0.5; % Transparency level for image2

% Display the first image
fig_fluorescence_overlap = figure;
imshow(processedFluorescence1_double);
hold on;

% Display the second image with transparency
h2 = imshow(processedFluorescence2_double);
set(h2, 'AlphaData', alpha2);

% Adjust the transparency of the first image
h1 = findobj(gca, 'Type', 'Image');
set(h1, 'AlphaData', alpha1);

% Add labels, titles, etc. as needed
title('Overlap of Two Fluorescence Images');
xlabel('X-axis');
ylabel('Y-axis');

% Specify the file name and path for FIG file
fig_filename = fullfile(folderPath, 'Identified_Cells_Fluorescence_overlapped.fig');
saveas(fig_fluorescence_overlap, fig_filename);

% Specify the file name and path for TIFF image
filename = fullfile(folderPath, 'Identified_Cells_Fluorescence_overlapped.tif');
% Set the resolution (DPI)
resolution = 300; % Adjust as needed
% Save the figure as an image with higher resolution
print(fig_fluorescence_overlap, filename, '-dtiff', ['-r', num2str(resolution)]);

% Close the figure
close(fig_fluorescence_overlap);

end