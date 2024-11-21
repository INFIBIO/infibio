function image_analysis_agg_AR_V5(route, myFolder)
% This function is meant to cropped the original image by a certain
% reduction Factor, binarize it, connect those cells nearer than a certain
% threshold and extract the properties of the different regions.
% INPUT:
% - route: route of the image to be analysed.
% - myFolder: folder containing all the images.
% OUTPUT: 
% - BWimage segmented with the closest cells joined.
% - csv and mat files with the region properties of each image in the
% folder.
% HISTORY:
% Created 2023. AR.
% Modified 7 November 2024 from V4 (XF). AR. Included the joining of the
% closest features detected to not underestimate the number of clusters.

[X, ~] = imread(route);

% Convert the image to grayscale
reductionFactor = 0.70;
originalSize = size(X);

% Calculate the new size based on the reduction factor
newSize = floor(originalSize(1:2) * reductionFactor);

% Calculate the amount to crop from each side
cropAmount = floor((originalSize(1:2) - newSize) / 2);
startPoint = [cropAmount(1) + 1, cropAmount(2) + 1, 1];

% Crop the image
croppedImage = X(startPoint(1):(startPoint(1) + newSize(1) - 1), ...
                 startPoint(2):(startPoint(2) + newSize(2) - 1), :);

X = croppedImage;
BW = imbinarize(im2gray(X), 'adaptive', 'Sensitivity', 0.20, 'ForegroundPolarity', 'dark');

% Invert the mask
BW = imcomplement(BW);
se = strel('disk', 5);

% Apply morphological closing operation
BW = imclose(BW, se);

% Fill holes
BW = imfill(BW, 'holes');

% Clear borders
BW = imclearborder(BW);

% Remove small areas (areas smaller than 100 pixels)
BW_out = bwpropfilt(BW, 'Area', [100 + eps(100), Inf]);

% Detect edges of the masks using bwboundaries
[B, L] = bwboundaries(BW_out, 'noholes');

% Calculate the distance between the edges of the masks
minimum_distance = 15;

% Iterate over each pair of regions
for i = 1:length(B)
    for j = i+1:length(B)
        % Get the borders of the two masks
        mask1 = L == i;
        mask2 = L == j;
        
        % Calculate the distance from the edges of mask1 to mask2
        dist_to_mask2 = bwdist(mask2);
        
        % Find the closest edge points between the two masks
        [rows1, cols1] = find(dist_to_mask2 == min(dist_to_mask2(mask1)) & mask1);
        
        % If points are found and the distance is less than the minimum distance
        if ~isempty(rows1) && min(dist_to_mask2(mask1)) < minimum_distance
            % Get the closest point in mask1
            point1 = [rows1(1), cols1(1)];
            
            % Find the corresponding closest point in mask2
            [rows2, cols2] = find(bwdist(mask1) == min(dist_to_mask2(mask1)) & mask2);
            point2 = [rows2(1), cols2(1)];
            
            % Generate a connecting line between the closest points
            num_points = max(abs(point2 - point1)) + 1;
            line_x = round(linspace(point1(1), point2(1), num_points));
            line_y = round(linspace(point1(2), point2(2), num_points));
            
            % Create a temporary image to draw the connecting line
            line_mask = false(size(BW_out));
            for k = 1:num_points
                line_mask(line_x(k), line_y(k)) = 1;
            end
            
            % Dilate the line to obtain a width of 10 pixels
            line_mask = imdilate(line_mask, strel('disk', 5));
            
            % Add the dilated line to the output
            BW_out = BW_out | line_mask;
        end
    end
end

propsbw = regionprops(BW_out, {'Area', 'Centroid', 'Perimeter', 'Circularity', 'Eccentricity', 'Solidity', 'MinorAxisLength', 'MajorAxisLength', 'BoundingBox'});

propsbw_cleaned = struct('Area', [], 'Centroid', [], 'Perimeter', [], 'Circularity', [], 'Eccentricity', [], 'Solidity', [], 'MinorAxisLength', [], 'MajorAxisLength', [], 'BoundingBox', []);

% Convert logical image to uint8
BW_out_uint8 = im2uint8(BW_out);

% Initialize an array to store centroid positions
centroidPositions = zeros(numel(propsbw), 2);

% Loop through each region and display area value
for i = 1:numel(propsbw)
    % Check if Centroid is empty
    if ~isempty(propsbw(i).Centroid)
        % Extract x and y components of the centroid
        x = propsbw(i).Centroid(1);
        y = propsbw(i).Centroid(2);
        
        % Store the centroid position in the array
        centroidPositions(i, :) = [x, y];
        
        % Add labels for other properties as needed
    end
end

% Extract the base name of the original image without the file extension
[~, baseName, ~] = fileparts(route);

% Split the baseName into parts using underscores
nameParts = strsplit(baseName, '_');

% Extract dilution and time information
dilution = str2double(nameParts{end - 1});  % Assuming dilution is the second-to-last part
time = str2double(nameParts{end});  % Assuming time is the last part

% Use imwrite to save the binary image with the new name
% Save the modified image with area values % Choose an appropriate image format
% Save the binary image with areas labeled

% Add rows with Area > 300 to propsbw_cleaned
for i = 1:length(propsbw)
    if propsbw(i).Area > 300
        propsbw_cleaned(end+1) = propsbw(i);
    end
end

propsbw_cleaned(1) = [];

enumerationColumn = cell(length(propsbw_cleaned), 1);

for i = 1:length(propsbw_cleaned)
    propsbw_cleaned(i).Concentration = [];
    propsbw_cleaned(i).Time = [];
    propsbw_cleaned(i).Enumeration = [];
    enumerationColumn{i} = num2str(i);
end

for i = 1:length(propsbw_cleaned)
    propsbw_cleaned(i).Concentration = dilution;
    propsbw_cleaned(i).Time = time;
end

% Remove empty cells from enumerationColumn
enumerationColumn = enumerationColumn(~cellfun('isempty', enumerationColumn));

% Assign enumerationColumn to propsbw_cleaned
[propsbw_cleaned.Enumeration] = enumerationColumn{:};

% Use imwrite to save the labeled image with the new name
newImageName = strcat(baseName, '_labeled.png');  % Choose an appropriate image format
imwrite(BW_out_uint8, fullfile(myFolder, newImageName));
FileName = fullfile(myFolder, [baseName, '_results.mat']);
FileName_csv = fullfile(myFolder, [baseName, '_results.csv']);
writetable(struct2table(propsbw_cleaned), FileName_csv, 'delimiter', ',');
% Write the structure to a MAT file using save
save(FileName, 'propsbw_cleaned');

end
