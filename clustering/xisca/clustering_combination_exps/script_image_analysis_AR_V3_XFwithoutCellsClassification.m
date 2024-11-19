% This script iterate over each tif image in a folder, applies the function
% specified in line 34 and save the output.
% INPUT: myFolder must specify a folder with tif images in uint16
% OUTPUT: the output will be the binarized image and a csv and m files with
% the features obtained from the function applied.

% Specify the folder where the files are.
myFolder = 'C:\Users\xisca\Desktop\TIFF';
%python_path = 'C:\Users\uib\anaconda3\envs\yolov5-env\python.exe';
%yolo_path = 'C:\Users\uib\Nextcloud2\classification_model\yolov5';
%predict_script = 'C:\Users\uib\Nextcloud2\classification_model\yolov5\classify\predict.py';
%weights = 'C:\Users\uib\Nextcloud2\classification_model\yolov5\runs\train\definitive\weights\best.pt';
% Check to make sure that folder actually exists. 
if ~isfolder(myFolder)
    errorMessage = sprintf('Error: The following folder does not exist:\n%s\nPlease specify a new folder.', myFolder);
    uiwait(warndlg(errorMessage));
    myFolder = uigetdir(); % Ask for a new one
    % 
    % 
    % .
    if myFolder == 0
         % User clicked Cancel
         return;
    end
end
% Initialize an empty table to store the cumulative results
cumulativeTable = table();
% Get a list of all files in the folder with the desired file name pattern.
filePattern = fullfile(myFolder, ['*.tif' ...
    '']); 
theFiles = dir(filePattern);
for k = 1 : length(theFiles)
    baseFileName = theFiles(k).name;
    fullFileName = fullfile(theFiles(k).folder, baseFileName);
    fprintf(1, 'Now reading %s\n', fullFileName);
    
    image_analysis_agg_AR_V3_XFwithoutCellsClassification(fullFileName, myFolder);  
    % CHANGE THE FUNCTION DEPENDING IF YOU'RE ANALYSING CLUSTERS OR ZYMOLIASE IMAGES
   
    % Save the processed image with a new name (you can customize the name)
    [~, name, ext] = fileparts(baseFileName);
    saveFileName = fullfile(myFolder, [name, '_processed', ext]);
end