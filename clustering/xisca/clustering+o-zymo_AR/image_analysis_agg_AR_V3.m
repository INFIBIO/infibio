function image_analysis_agg_AR_V3(route, myFolder, python_path, yolo_path, predict_script, weights)
% This function performs image processing and analysis on a given image.
% It segments the image, calculates properties of detected regions, and
% saves results in various formats.
%
% INPUTS:
% - route: Path to the image file.
% - myFolder: Directory where results will be saved.
% - python_path: Path to the Python executable.
% - yolo_path: Path to the YOLO model directory.
% - predict_script: Path to the Python script used for classification.
% - weights: Weights file for the YOLO model.

% Read the image from the specified route
[X, ~] = imread(route);

% Define reduction factors for cropping
reductionFactor = 0.70;
reductionFactor2 = 0.70;

% Get the size of the original image
originalSize = size(X);

% Calculate the new size after cropping based on the reduction factor
newSize = floor(originalSize(1:2) * reductionFactor);

% Calculate cropping amount from each side
cropAmount = floor((originalSize(1:2) - newSize) / 2);

% Calculate the starting point for cropping
startPoint = [cropAmount(1) + 1, cropAmount(2) + 1, 1];

% Crop the image to the new size
croppedImage = X(startPoint(1):(startPoint(1) + newSize(1) - 1), ...
                 startPoint(2):(startPoint(2) + newSize(2) - 1), :);

% Update X with the cropped image
X = croppedImage;

% Get the size of the cropped image
originalSize = size(X);

% Repeat cropping process with a second reduction factor
newSize = floor(originalSize(1:2) * reductionFactor2);
cropAmount = floor((originalSize(1:2) - newSize) / 2);
startPoint = [cropAmount(1) + 1, cropAmount(2) + 1, 1];
croppedImage = X(startPoint(1):(startPoint(1) + newSize(1) - 1), ...
                 startPoint(2):(startPoint(2) + newSize(2) - 1), :);

% Update X with the final cropped image
X = croppedImage;

% Convert the cropped image to grayscale and binarize it
BW = imbinarize(im2gray(X), 'adaptive', 'Sensitivity', 0.7, 'ForegroundPolarity', 'bright');

% Invert the binary image
BW = imcomplement(BW);

% Fill holes in the binary image
BW = imfill(BW, 'holes');

% Clear objects connected to the border
BW = imclearborder(BW);

% Filter binary image based on the area of objects
BW_out = bwpropfilt(BW, 'Area', [1000 + eps(1000), Inf]);

% Calculate properties of the filtered regions
propsbw = regionprops(BW_out, {'Area', 'Centroid', 'Perimeter', 'Circularity', 'Eccentricity', 'Solidity', 'MinorAxisLength', 'MajorAxisLength', 'BoundingBox'});

% Initialize a structure for cleaned properties
propsbw_cleaned = struct('Area', [], 'Centroid', [], 'Perimeter', [], 'Circularity', [], 'Eccentricity', [], 'Solidity', [], 'MinorAxisLength', [], 'MajorAxisLength', [], 'BoundingBox', []);

% Convert binary image to uint8 for labeling
BW_out_uint8 = im2uint8(BW_out);

% Initialize an array to store centroid positions
centroidPositions = zeros(numel(propsbw), 2);

% Loop through each detected region to store centroid positions
for i = 1:numel(propsbw)
    if ~isempty(propsbw(i).Centroid)
        x = propsbw(i).Centroid(1);
        y = propsbw(i).Centroid(2);
        centroidPositions(i, :) = [x, y];
    end
end

% Extract the base name of the original image file without extension
[~, baseName, ~] = fileparts(route);

% Split the base name into parts using underscores
nameParts = strsplit(baseName, '_');

% Extract dilution and time information from the base name
dilution = str2double(nameParts{end - 1}); % Second-to-last part
time = str2double(nameParts{end});         % Last part

% Filter the regions based on area and store in cleaned properties
for i = 1:length(propsbw)
    if propsbw(i).Area > 1000
        propsbw_cleaned(end+1) = propsbw(i);
    end
end

% Remove the initial empty entry
propsbw_cleaned(1) = [];

% Initialize an enumeration column
enumerationColumn = cell(length(propsbw_cleaned), 1);

% Assign enumeration and other properties to the cleaned properties
for i = 1:length(propsbw_cleaned)
    propsbw_cleaned(i).Concentration = dilution;
    propsbw_cleaned(i).Time = time;
    propsbw_cleaned(i).Enumeration = num2str(i);
end

% Convert cleaned properties to a table and write to CSV
enumerationColumn = cell(length(propsbw_cleaned), 1);
for i = 1:length(propsbw_cleaned)
    enumerationColumn{i} = num2str(i);
end
[propsbw_cleaned.Enumeration] = enumerationColumn{:};
propsbw_cleaned = classification(X, propsbw_cleaned, python_path, yolo_path, predict_script, weights);

% Create labeled image with text annotations
numEtiquetas = 1:length(propsbw_cleaned);
labeledImage = insertText(BW_out_uint8, centroidPositions, cellstr(num2str([numEtiquetas]')), ...
    'FontSize', 18, 'TextColor', 'y', 'BoxColor', 'black', 'BoxOpacity', 0.7);

% Save the labeled image and results
newImageName = strcat(baseName, '_labeled.tif');
imwrite(labeledImage, fullfile(myFolder, newImageName));
FileName = fullfile(myFolder, [baseName, '_results_classified.mat']);
FileName_csv = fullfile(myFolder, [baseName, '_results_classified.csv']);
writetable(struct2table(propsbw_cleaned), FileName_csv, 'delimiter', ',');
save(FileName, 'propsbw_cleaned');

end
