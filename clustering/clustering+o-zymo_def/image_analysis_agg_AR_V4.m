function image_analysis_agg_AR_V4(route, myFolder)

[X,~] = imread(route);
%segmentImage Segment image using auto-generated code from Image Segmenter app
%  [BW,MASKEDIMAGE] = segmentImage(X) segments image X using auto-generated
%  code from the Image Segmenter app. The final segmentation is returned in
%  BW, and a masked image is returned in MASKEDIMAGE.

% Auto-generated by imageSegmenter app on 23-Nov-2023
%----------------------------------------------------
% Convertir la imagen a escala de grises
reductionFactor = 0.70;

% Get the size of the original image
originalSize = size(X);

% Calculate the new size based on the reduction factor
newSize = floor(originalSize(1:2) * reductionFactor);

% Calculate the amount to be cropped from each side
cropAmount = floor((originalSize(1:2) - newSize) / 2);

% Calculate the starting point for cropping
startPoint = [cropAmount(1) + 1, cropAmount(2) + 1, 1];

% Crop the image
croppedImage = X(startPoint(1):(startPoint(1) + newSize(1) - 1), ...
                 startPoint(2):(startPoint(2) + newSize(2) - 1), :);

X = croppedImage;
BW = imbinarize(im2gray(X), 'adaptive', 'Sensitivity', 0.30, 'ForegroundPolarity', 'dark');

% Invert mask
BW = imcomplement(BW);
se = strel('disk', 5); 

% Apply morphological closing operation
BW = imclose(BW, se); % Pass both the binary image and the structuring element


% Fill holes
BW = imfill(BW, 'holes');
% Clear borders
BW = imclearborder(BW);
% Create masked image.

BW_out = bwpropfilt(BW,'Area',[100 + eps(100), Inf]);
propsbw = regionprops(BW, {'Area', 'Centroid', 'Perimeter', 'Circularity', 'Eccentricity', 'Solidity','MinorAxisLength','MajorAxisLength', 'BoundingBox'});

propsbw_cleaned = struct('Area', [], 'Centroid', [], 'Perimeter', [], 'Circularity', [], 'Eccentricity', [],  'Solidity',[], 'MinorAxisLength',[], 'MajorAxisLength',[], 'BoundingBox',[]);

% Convert logical image to uint8
BW_out_uint8 = im2uint8(BW);
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





% Add the rows with Area > 300 to properties_cleaned
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
%propsbw_cleaned = classification(X, propsbw_cleaned, python_path, yolo_path, predict_script, weights)
% Create the new name for the MAT file by appending "_results.mat"
% Crear un vector de números de etiquetas para cada región
% numEtiquetas = 1:length(propsbw_cleaned);

% Use insertText to add labels to the image
% labeledImage = insertText(BW_out_uint8, centroidPositions, cellstr(num2str([numEtiquetas]')), ...
    % 'FontSize', 18, 'TextColor', 'y', 'BoxColor', 'black', 'BoxOpacity', 0.7);

% Use imwrite to save the labeled image with the new name
newImageName = strcat(baseName, '_labeled.png');  % Choose an appropriate image format
imwrite(BW_out_uint8, fullfile(myFolder, newImageName));
FileName = fullfile(myFolder, [baseName, '_results.mat']);
FileName_csv = fullfile(myFolder, [baseName, '_results.csv']);
writetable(struct2table(propsbw_cleaned), FileName_csv,'delimiter',',');
% Write the structure to a MAT file using save
save(FileName, 'propsbw_cleaned');

end



