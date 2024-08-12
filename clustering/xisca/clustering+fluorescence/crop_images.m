function crop_images(directoryPath, outdirectoryPath, reductionFactor)
% Get a list of all JPEG files in the specified directory
fileList = dir(fullfile(directoryPath, '*.jpg'));

% Loop through each JPEG file in the directory
for i = 1:length(fileList)
    % Read the image
    currentFilename = fullfile(directoryPath, fileList(i).name);
    image = imread(currentFilename);
    
    % Extract information from the filename
    filenameParts = split(fileList(i).name, '_');
    replicate = filenameParts{1};
    sampletype = filenameParts{2};
    timePoint = filenameParts{end}(1:end-4); % Remove '.jpg' extension
    
    % Perform cropping
    % Get the size of the original image
    originalSize = size(image);
    % Calculate the new size based on a 10% reduction
    newSize = floor(originalSize(1:2) * reductionFactor);
    % Calculate the amount to be cropped from each side
    cropAmount = floor((originalSize(1:2) - newSize) / 2);
    % Calculate the starting point for cropping
    startPoint = [cropAmount(1) + 1, cropAmount(2) + 1, 1];
    % Crop the image
    croppedImage = image(startPoint(1):(startPoint(1) + newSize(1) - 1), ...
                         startPoint(2):(startPoint(2) + newSize(2) - 1), :);
    
    % Save the cropped image with a new filename
    newFilename = sprintf('%s_%s_%s.jpg', replicate, sampletype, timePoint);
    saveFilename = fullfile(outdirectoryPath, newFilename);
    imwrite(croppedImage, saveFilename);
end