%%

folderPath2 = 'C:\Users\xisca\Desktop\Trials_scripts_XF\trials_clustering+fluorescence_v2\IMAGES_v3\cropped_images\';

% Get all image files in the folder
imageFiles = getAllImageFiles(folderPath2);

% Display the list of all image files found
disp('All image files:');
disp(imageFiles);

% Initialize results table
results = table('Size', [length(imageFiles), 7], 'VariableTypes', {'string', 'string', 'double', 'double', 'double', 'double', 'double'}, ...
    'VariableNames', {'Folder', 'FileName', 'Contrast', 'MeanIntensity', 'StdIntensity', 'Entropy', 'MedianIntensity'});

% Process each image and calculate parameters
for i = 1:length(imageFiles)
    filePath = imageFiles{i};
    [folderPath, fileName, ext] = fileparts(filePath);
    
    % Display the current file being processed
    fprintf('Processing file %d/%d: %s\n', i, length(imageFiles), filePath);
    
    try
        % Read the image
        brightfieldImage = imread(filePath);
        
        % Convert to grayscale if the image is RGB
        if size(brightfieldImage, 3) == 3
            brightfieldImage = rgb2gray(brightfieldImage);
        end
        
        % Calculate image parameters
        params = calculateImageParameters(brightfieldImage);

        % Store results in the table
        results.Folder(i) = string(folderPath);
        results.FileName(i) = string([fileName, ext]);
        results.Contrast(i) = params.contrast;
        results.MeanIntensity(i) = params.mean;
        results.StdIntensity(i) = params.std;
        results.Entropy(i) = params.entropy;
        results.MedianIntensity(i) = params.median;
    catch ME
        warning('Failed to process file %s: %s', filePath, ME.message);
    end
end

% Display the results table
disp('Results:');
disp(results);

% Save the results to a CSV file (optional)
writetable(results, fullfile(folderPath2, 'image_analysis_results.csv'));

%%

% Load brightfield image
brightfieldImage = imread(fullfile(outdirectoryPath, 'A5.0_brighfield_0.jpg'));
% Load fluorescence images
fluorescenceImage1 = imread(fullfile(outdirectoryPath, 'A5.0_FDAblue_0.jpg')); %NB staining
fluorescenceImage2 = imread(fullfile(outdirectoryPath, 'A5.0_NBred_0.jpg')); %FDA staining
imshow([brightfieldImage,fluorescenceImage1,fluorescenceImage2]);

% Pre-processing steps
brightfieldImage = im2double(brightfieldImage);
fluorescenceImage1 = im2double(fluorescenceImage1);
fluorescenceImage2 = im2double(fluorescenceImage2);

% Step 2: Cell Identification in Brightfield Image
% Processing
processedBrightfield = imadjust(brightfieldImage);
bwBrightfield = imbinarize(processedBrightfield, 'adaptive', 'Sensitivity', 0.52, 'ForegroundPolarity', 'dark');

% Clear borders
bwBrightfield2 = imclearborder(bwBrightfield);
imshow([processedBrightfield,bwBrightfield, bwBrightfield2]);

% Filter small and big objects
minCellSize = 80;
maxCellSize = 1000;
bwBrightfield3 = bwareaopen(bwBrightfield2, minCellSize) & ~bwareaopen(bwBrightfield2, maxCellSize);
imshow([processedBrightfield,bwBrightfield2, bwBrightfield3]);

% Cell tracking
cellPropertiesBrightfield = regionprops(bwBrightfield3, {'Centroid', 'Area', 'Perimeter', 'Circularity', 'Eccentricity', 'Solidity', 'MinorAxisLength', 'MajorAxisLength'});
cellCentroidsBrightfield = cat(1, cellPropertiesBrightfield.Centroid);

% Visualize centroids on brightfield image
fig_brightfield = figure;
imshow(brightfieldImage);
hold on;
title('Cell Centroids in Brightfield Image');
for i = 1:numel(cellCentroidsBrightfield)
    try
        plot(cellCentroidsBrightfield(i, 1), cellCentroidsBrightfield(i, 2), 'ro', 'MarkerSize', 10, 'LineWidth', 1);
        hold on;
    catch
        disp(['Error: Index ', num2str(i), ' exceeds array bounds. Skipping...']);
    end
end

% Save the figure as an image
saveas(fig_brightfield, 'brightfield_with_centroids.tif');
saveas(fig_brightfield, 'brightfield_with_centroids.fig');
close(fig_brightfield); % Close the figure to avoid cluttering the workspace

% Step 3: Fluorescent Cell Detection for fluorescenceImage1
% Check Image Range
minValue = min(fluorescenceImage1(:));
maxValue = max(fluorescenceImage1(:));
disp(['Min pixel value: ', num2str(minValue)]);
disp(['Max pixel value: ', num2str(maxValue)]);

% Processing
processedFluorescence1 = imadjust(fluorescenceImage1);
% Thresholding
bwFluorescence1 = imbinarize(processedFluorescence1, 'adaptive', 'Sensitivity', 0.001, 'ForegroundPolarity', 'bright');
% Filter small and big objects
bwFluorescence11 = bwareaopen(bwFluorescence1, minCellSize) & ~bwareaopen(bwFluorescence1, maxCellSize);
imshow([processedFluorescence1, bwFluorescence1,bwFluorescence11]);

% Cell tracking
cellPropertiesFluorescence1 = regionprops(bwFluorescence11, {'Centroid', 'Area', 'Perimeter', 'Circularity', 'Eccentricity', 'Solidity', 'MinorAxisLength', 'MajorAxisLength'});
cellCentroidsFluorescence1 = cat(1, cellPropertiesFluorescence1.Centroid);

% Visualize centroids on fluorescence image 1
fig_fluorescence1=figure;
imshow(fluorescenceImage1);
hold on;
title('Cell Centroids in Fluorescence Image 1');
for i = 1:numel(cellCentroidsFluorescence1)
    try
        plot(cellCentroidsFluorescence1(i, 1), cellCentroidsFluorescence1(i, 2), 'bo', 'MarkerSize', 10, 'LineWidth', 1);
        hold on;
    catch
        disp(['Error: Index ', num2str(i), ' exceeds array bounds. Skipping...']);
    end
end

% Save fluorescence image 1 with centroids
saveas(fig_fluorescence1, 'fluorescence1_with_centroids.tif');
saveas(fig_fluorescence1, 'fluorescence1_with_centroids.fig');
close(fig_fluorescence1);

% Step 4: Fluorescent Cell Detection for fluorescenceImage2
% Processing
processedFluorescence2 = imadjust(fluorescenceImage2);
bwFluorescence2 = imbinarize(processedFluorescence2, 'adaptive', 'Sensitivity', 0.35, 'ForegroundPolarity', 'bright');
imshow([processedFluorescence2, bwFluorescence2]);

% Filter small and big objects
minCellSize = 50;
bwFluorescence22 = bwareaopen(bwFluorescence2, minCellSize); 
bwFluorescence22 = bwareaopen(bwFluorescence2, minCellSize) & ~bwareaopen(bwFluorescence2, maxCellSize);
imshow([processedFluorescence2, bwFluorescence2,bwFluorescence22]);

% Cell tracking
cellPropertiesFluorescence2 = regionprops(bwFluorescence22, {'Centroid', 'Area', 'Perimeter', 'Circularity', 'Eccentricity', 'Solidity', 'MinorAxisLength', 'MajorAxisLength'});
cellCentroidsFluorescence2 = cat(1, cellPropertiesFluorescence2.Centroid);

% Visualize centroids on fluorescence image 2
fig_fluorescence2=figure;
imshow(fluorescenceImage2);
hold on;
title('Cell Centroids in Fluorescence Image 2');
for i = 1:numel(cellPropertiesFluorescence2)
    try
        plot(cellPropertiesFluorescence2(i).Centroid(1), cellPropertiesFluorescence2(i).Centroid(2), 'go', 'MarkerSize', 10, 'LineWidth', 1);
        hold on;
    catch
        disp(['Error: Index ', num2str(i), ' exceeds array bounds. Skipping...']);
    end
end

% Save fluorescence image 2 with centroids
saveas(fig_fluorescence2, 'fluorescence2_with_centroids.tif');
saveas(fig_fluorescence2, 'fluorescence2_with_centroids.fig');
close(fig_fluorescence2);
