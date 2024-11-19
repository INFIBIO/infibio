%% To apply when the loop crashes because some images
% Define the directory paths
folderPath = 'C:\Users\xisca\Desktop\TIFF\cropped_images'; % modify<

% Load brightfield image
brightfieldImage = imread(fullfile(folderPath, 'A1.0_1000_-1.jpg')); % modify<

% Pre-processing steps
brightfieldImage = im2double(brightfieldImage);

% Step 2: Cell Identification in Brightfield Image
% Processing
processedBrightfield = imadjust(brightfieldImage);
bwBrightfield = imbinarize(processedBrightfield, 'adaptive', 'Sensitivity', 0.001, 'ForegroundPolarity', 'dark');
imshow([brightfieldImage, processedBrightfield,bwBrightfield]);

% Clear borders
bwBrightfield2 = imclearborder(bwBrightfield);
imshow([processedBrightfield,bwBrightfield, bwBrightfield2]);

BW = imcomplement(bwBrightfield);
imshow([processedBrightfield,bwBrightfield, BW]);

BW2 = imfill(BW, 'holes');
imshow([processedBrightfield,bwBrightfield, BW, BW2]);

% Filter small and big objects
minCellSize = 80; %80
maxCellSize = 6000; %1000
bwBrightfield3 = bwareaopen(bwBrightfield2, minCellSize) & ~bwareaopen(bwBrightfield2, maxCellSize);
imshow([BW, BW2, bwBrightfield3]);
