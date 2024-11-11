% Adapted from do_features_extraction.m by MP. Script to label individual
% yeast cells. The different levels are:
% 1 - Haploid/Diploid
% 2 - Sporulated
% 3 - Discard
% r - Redo previous selection
% q - Exit selection
% The script will display a bounding box around each cell and ask the user
% to input the corresponding label. The user can also redo the previous
% selection or exit the selection process. The script will save the cropped
% images to a folder and the labels to a MAT file. The script will also
% save the cropped images and labels to an imageDatastore to use to train 
% a Convolutional Neural Network. The script will
% exit if the user chooses to exit the selection process.
% INPUT:
% - imgpath: path with the 640x640 images to be classified
% OUTPUT:
% - Folder with the classified png 640x640 images.
% - Folder with the txt files with the class and bounding boxes of the
% cells classified. One txt file by image.
% HISTORY:
% Created June 2024 from do_features_extraction.m by MP. AR.
% Modified July 2024. AR. Now it creates as single txt file for each image
% instead of a single txt file for each cell.
%% Input and output info
imgpath = 'C:\Users\uib\Nextcloud2\Yeast_experiments\Yeast_experiments\Zymoliase_analyse_trials\Exp_Zymolyase01-005_ConA03-2024110\E1\0\tiff\';
datapath = [imgpath,'data/'];
labelpath = [imgpath, 'labels/'];
imgextension = 'tif'; %make sure you use single quotation marks, e.g. 'tif', and not double, e.g. "tif". String concatenation is different
alreadyLabeledPath = fullfile('C:\Users\uib\Nextcloud2\Yeast_experiments\Yeast_experiments\Zymoliase_analyse_trials\Exp_Zymolyase01-005_ConA03-2024110\E1\0\tiff\', 'already_labeled');
%% Parameter definition
%%Segmentation
invert = 1;
paramSegment.int_threshold = 32767.5;
paramSegment.mode_threshold = 127;
paramSegment.arearange = [2000,inf];
paramSegment.morph_close_radius = 3;

%%Featuring
paramFeature.minlen = 4;
paramFeature.maxlen = inf;
paramFeature.b_init = 1;

%% Gather list of files and perform analysis
if ~isdir(datapath)
    mkdir(datapath)
end
if ~isdir(labelpath)
    mkdir(labelpath)
end
myfiles = dir([imgpath,'*.',imgextension]);
imageFiles = cell(length(struct), 1);
labels = cell(length(struct), 1);
images = cell(length(struct), 1);
% Get the last tt and i analyzed
[last_tt, last_i] = get_last_tt_i(labelpath);
if last_tt == 0
    last_tt = 1;
end

for tt = last_tt:length(myfiles)

    
    if mod(tt-1,10)==0
        disp(['Extracting features from frame ',num2str(tt),' out of ',num2str(length(myfiles))]);
    end

    %read new image
    img = imread([imgpath,myfiles(tt).name]);
    img_jpg = im2uint8(img); % Convert to uint8
    fileName = fullfile(datapath, sprintf('%d.png', tt)); % Save as png
    imwrite(img_jpg, fileName); % Save the image
    image = fullfile(myfiles(tt).folder,myfiles(tt).name);
    images{end+1} = image;
    [~,imgname,~] = fileparts(myfiles(tt).name);
    
    %invert if needed
    if invert
        img = imcomplement(img);
    end

    [BWimg,maskedImage] = segmentImage(img,paramSegment); %segmentation
    try
    features = feature_connected_components(BWimg,paramFeature); %featuring
    
    % Loop through each bounding box
    imshow(maskedImage);
    i = 1; 
    if tt == last_tt
        i = last_i + 1;
    end
    while i <= length(features)
       if length(features(i).pxlborder) < 2
            disp('Not enough points for interpolation, skipping this feature.');
            i = i + 1;
            continue;
        end
        % Get the bounding box
        bbox = features(i).BoundingBox;
        % Crop the image to the bounding box
        croppedImage = imcrop(img, bbox);
        croppedImage = im2uint8(croppedImage);
        croppedImage = imadjust(croppedImage, stretchlim(croppedImage), []);
        % Save the cropped image to a file
        fileName = fullfile(datapath, sprintf('croppedImage_%d_%d.png', tt, i));
        % imwrite(croppedImage, fileName);
        % Store the file name
        imageFiles{end+1} = fileName;
        % Display the bounding box
        rectangle('Position', bbox, 'EdgeColor', 'r');
    
        figure, imshow(croppedImage);
    
        % Display the options for user input
        disp('Options for user input:');
        disp('1 - Haploid/Diploid');
        disp('2 - Sporulated');
        disp('3 - Discard');
        disp('r - Redo previous selection');
        disp('q - Restart matlab');
        disp('s - Stop labeling');
        % Ask for user input
        user_choice = input('Enter your choice (1-3, r to redo, q to exit, or s to save and restart): ', 's');
    
        % Validate user input
        while ~strcmp(user_choice, 'q') && ~strcmp(user_choice, 'r') && ~strcmp(user_choice, 's') && (str2double(user_choice) < 1 || str2double(user_choice) > 3)
            disp('Invalid choice. Please enter a number between 1 and 3, r to redo, q to exit, or s to save and restart.');
            user_choice = input('Enter your choice (1-3, r to redo, q to exit, or s to save and restart): ', 's');
        end
    
        % Check if user chose to exit
        if strcmp(user_choice, 'q')
            !matlab &
            exit;
        elseif strcmp(user_choice, 's')
            % Convert cell arrays to categorical array for labels
            labels = labels(2:end);
    
            labels = categorical(labels);
            imageFiles = imageFiles(2:end-1);
            % Create an imageDatastore for storing the image files and labels
            imds = imageDatastore(imageFiles, 'Labels', labels);
            % Save the imageDatastore to a MAT file
            save([datapath,'imageDatastore.mat'], 'imds');
            return;   
        end
        if strcmp(user_choice, 'r') && i > 1
            % Redo previous selection
            close(gcf);
            i = i - 1;
            imageFiles(end) = [];
            disp(i);
            continue; % Repite la iteración actual del bucle
        else
            if strcmp(user_choice, 'r')
                disp('Cannot redo previous selection. Already at the first bounding box.');
            end
        end
    
        % Map user choice to corresponding label
        if str2double(user_choice) == 1
            user_input_label = 'Haploid/Diploid';
            class_id = 0; % Corresponding class ID for YOLO
        elseif str2double(user_choice) == 2
            user_input_label = 'Sporulated';
            class_id = 1; % Corresponding class ID for YOLO
        else
            user_input_label = 'Discard';
            class_id = 2; % Corresponding class ID for YOLO
        end
    
        % Display the user input next to the bounding box
        text(bbox(1), bbox(2)-10, user_input_label, 'Color', 'r', 'FontSize', 12);
    
        % Add the user input to the struct
        features(i).UserInputLabel = user_input_label;
        % Store the user input label
        labels{end+1} = features(i).UserInputLabel;
        % Normalize bounding box coordinates for YOLO format
        centerX = (bbox(1) + bbox(3) / 2) / size(img, 2);
        centerY = (bbox(2) + bbox(4) / 2) / size(img, 1);
        width = bbox(3) / size(img, 2);
        height = bbox(4) / size(img, 1);
        
        % Save the YOLO annotation to a file
        annotationFile = fullfile(labelpath, sprintf('croppedImage_%d_%d.txt', tt, i));
        disp(['Saving annotation to file: ', annotationFile]);
        fileID = fopen(annotationFile, 'w');
        if fileID == -1
            error('Error opening file: %s', annotationFile);
        end
        
        
        fprintf(fileID, '%d %.6f %.6f %.6f %.6f\n', class_id, centerX, centerY, width, height);
        fclose(fileID);

        % Close the displayed bounding box
        close(gcf);
        
        % Increment i only if the user didn't choose 'r'
        i = i + 1;
    end
    catch ME
        disp(['Error processing frame ', num2str(tt), ': ', ME.message]);
        continue; % Continue to next frame in case of error
    end
    % Join all annotation files for each image
    imwrite(img_jpg, fileName); % Save the image
    annotationFiles = dir(fullfile(labelpath, sprintf('croppedImage_%d_*.txt', tt)));
    combinedAnnotationFile = fullfile(labelpath, sprintf('%d.txt', tt));
    combinedFileID = fopen(combinedAnnotationFile, 'w');

    if combinedFileID == -1
        error('Error opening file: %s', combinedAnnotationFile);
    end
    for k = 1:length(annotationFiles)
        annotationFile = fullfile(labelpath, annotationFiles(k).name);
        fileID = fopen(annotationFile, 'r');
        if fileID == -1
            error('Error opening file: %s', annotationFile);
        end
        data = fread(fileID, '*char');
        fwrite(combinedFileID, data);
        fclose(fileID);
    end
    fclose(combinedFileID);

end
% Convert cell arrays to categorical array for labels
labels = labels(2:end);
labels = categorical(labels);
imageFiles = imageFiles(2:end);



% Ensure the alreadyLabeledPath directory exists
if ~exist(alreadyLabeledPath, 'dir')
    mkdir(alreadyLabeledPath);
end

for i = 2:length(images)
    fullImagePath = images{i}; % This is the full path of the image
    
    % Ensure fullImagePath is a character array or string
    if isstring(fullImagePath)
        fullImagePath = char(fullImagePath); % Convert to char
    elseif ~ischar(fullImagePath)
        error('Image path must be a character array or string.');
    end
    
    [~, imageName, ext] = fileparts(fullImagePath); % Extract file name and extension
    sourcePath = fullImagePath; % Source path is full path of the image
    destPath = fullfile(alreadyLabeledPath, [imageName, ext]); % Construct destination path

    % Move the file
    movefile(sourcePath, destPath);
end


% Create an imageDatastore for storing the image files and labels
imds = imageDatastore(imageFiles, 'Labels', labels);
% Create an imageDatastore for storing the images and labels
% Save the imageDatastore to a MAT file
save([datapath, 'imageDatastore.mat'], 'imds');


% Function to get the last tt and i analyzed
function [last_tt, last_i] = get_last_tt_i(labelpath)
    label_files = dir([labelpath, '*.txt']);
    last_tt = 0;
    last_i = 0;
    for k = 1:length(label_files)
        [~, name, ~] = fileparts(label_files(k).name);
        tokens = regexp(name, 'croppedImage(\d+)_(\d+)', 'tokens');
        if ~isempty(tokens)
            tt = str2double(tokens{1}{1});
            i = str2double(tokens{1}{2});
            if tt > last_tt
                last_tt = tt;
                last_i = i;
            elseif tt == last_tt && i > last_i
                last_i = i;
            end
        end
    end
end

