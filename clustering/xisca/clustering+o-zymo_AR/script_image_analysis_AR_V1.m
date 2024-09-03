% This script processes a set of TIFF images located in a specified folder, 
% applying a custom image analysis function to each image. The script is designed 
% to iterate through each TIFF image, apply a specified function to analyze 
% the image data, and save the output. The output includes binarized images, 
% along with CSV and MATLAB (.m) files that contain features extracted from 
% the applied function.
%
% The analysis involves running a Python-based YOLO (You Only Look Once) 
% classification model on the images using specified paths for the Python 
% environment, the YOLO model script, and the model weights.
%
% INPUT REQUIREMENTS:
% - The folder specified by 'myFolder' must contain TIFF images in uint16 format.
% - You need to provide the paths to the Python executable, the YOLO classification 
%   script, and the trained model weights.
%
% OUTPUT:
% - The script outputs the processed (binarized) images.
% - Additionally, it generates CSV and .m files with extracted features based 
%   on the applied image analysis function.
% 
% NOTE: The functions 'image_analysis_x_AR'should be updated or changed 
% depending on the specific image analysis 
% requirements (e.g., for analyzing clusters or zymolyase images).
% HISTORY:
% 2023. AR. Created.
% 03 September, 2024. AR. Modified. Added python paths for classification.



% Specify the folder where the files are located.
myFolder = ['C:\Users\uib\Desktop\clustering\Exps_clustering_100rpm_200500_07222024_2\2000_0_100_30' ];
python_path = 'C:\Users\uib\anaconda3\envs\yolov5-env\python.exe';
yolo_path = 'C:\Users\uib\Nextcloud2\classification_model\yolov5';
predict_script = 'C:\Users\uib\Nextcloud2\classification_model\yolov5\classify\predict.py';
weights = 'C:\Users\uib\Nextcloud2\classification_model\yolov5\runs\train\definitive\weights\best.pt';

% Check if the specified folder exists. If not, prompt the user to select a new folder.
if ~isfolder(myFolder)
    errorMessage = sprintf('Error: The following folder does not exist:\n%s\nPlease specify a new folder.', myFolder);
    uiwait(warndlg(errorMessage));
    myFolder = uigetdir(); % Ask the user to select a new folder
    if myFolder == 0
         % User clicked Cancel
         return;
    end
end

% Initialize an empty table to store cumulative results
cumulativeTable = table();

% Get a list of all TIFF files in the specified folder
filePattern = fullfile(myFolder, '*.tif');
theFiles = dir(filePattern);

% Iterate over each file in the folder
for k = 1 : length(theFiles)
    baseFileName = theFiles(k).name;
    fullFileName = fullfile(theFiles(k).folder, baseFileName);
    fprintf(1, 'Now reading %s\n', fullFileName);
    
    % Apply the first analysis function
    image_analysis_agg_AR_V2(fullFileName, myFolder, python_path, yolo_path, predict_script, weights);

    % Save the processed image with a '_processed' suffix
    [~, name, ext] = fileparts(baseFileName);
    saveFileName = fullfile(myFolder, [name, '_processed', ext]);
    
    % Apply the second analysis function, potentially for further classification
    image_analysis_agg_AR_V3(fullFileName, myFolder, python_path, yolo_path, predict_script, weights);
    
    % Save the classified processed image with a '_processed_classified' suffix
    saveFileNameClass = fullfile(myFolder, [name, '_processed_classified', ext]);
end
