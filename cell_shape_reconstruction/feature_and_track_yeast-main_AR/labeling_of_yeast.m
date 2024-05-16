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

%% Input and output info
imgpath = 'C:\Users\uib\Desktop\diploid-spor diff\Network_training_IMAGES\';
datapath = [imgpath,'data/'];
imgextension = 'tif'; %make sure you use single quotation marks, e.g. 'tif', and not double, e.g. "tif". String concatenation is different

%% Parameter definition
%%Segmentation
invert = 1;
paramSegment.int_threshold = 4.325310e+04;
paramSegment.mode_threshold = 5e4;
paramSegment.arearange = [2000,inf];
paramSegment.morph_close_radius = 3;

%%Featuring
paramFeature.minlen = 4;
paramFeature.maxlen = inf;
paramFeature.b_init = 1;

%%Tracking
paramTracks.maxdisp = 10;
paramTracks.mem = 0;
paramTracks.good = 2;
paramTracks.dim = 2;
paramTracks.quiet = 1;
tracks = [];

%% Gather list of files and perform analysis
if ~isdir(datapath)
    mkdir(datapath)
end
myfiles = dir([imgpath,'*.',imgextension]);
imageFiles = cell(length(struct), 1);
labels = cell(length(struct), 1);
for tt = 1:length(myfiles)
    
    if mod(tt-1,10)==0
        disp(['Extracting features from frame ',num2str(tt),' out of ',num2str(length(myfiles))]);
    end

    %read new image
    img = imread([imgpath,myfiles(tt).name]);
    [~,imgname,~] = fileparts(myfiles(tt).name);

    %invert if needed
    if invert
        img = imcomplement(img);
    end

    [BWimg,maskedImage] = segmentImage(img,paramSegment); %segmentation
    
    features = feature_connected_components(BWimg,paramFeature); %featuring
    % Loop through each bounding box
    imshow(maskedImage);
    i = 1; % Inicializar i fuera del bucle
    while i <= length(features)
       
        % Get the bounding box
        bbox = features(i).BoundingBox;
        % Crop the image to the bounding box
        croppedImage = imcrop(img, bbox);
        croppedImage = im2uint8(croppedImage);
        croppedImage = imadjust(croppedImage, stretchlim(croppedImage), []);
        % Save the cropped image to a file
        fileName = fullfile(datapath, sprintf('croppedImage%d%d.jpg', tt, i));
        imwrite(croppedImage, fileName);
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
        elseif str2double(user_choice) == 2
            user_input_label = 'Sporulated';
        else
            user_input_label = 'Discard';
        end
    
        % Display the user input next to the bounding box
        text(bbox(1), bbox(2)-10, user_input_label, 'Color', 'r', 'FontSize', 12);
    
        % Add the user input to the struct
        features(i).UserInputLabel = user_input_label;
        % Store the user input label
        labels{end+1} = features(i).UserInputLabel;
        % Close the displayed bounding box
        close(gcf);
        
        % Increment i only if the user didn't choose 'r'
        i = i + 1;
    end
     % Convert cell arrays to categorical array for labels
  
  
end
% Convert cell arrays to categorical array for labels
labels = labels(2:end);

labels = categorical(labels);
imageFiles = imageFiles(2:end);
labels = categorical(labels);

% Create an imageDatastore for storing the image files and labels
imds = imageDatastore(imageFiles, 'Labels', labels);
% Create an imageDatastore for storing the images and labels
% Save the imageDatastore to a MAT file
save([datapath, 'imageDatastore.mat'], 'imds');
% % Define the YOLO network architecture
% layers = [
%     imageInputLayer([224 224 3])
%     convolution2dLayer(3, 16, 'Padding', 'same')
%     batchNormalizationLayer
%     reluLayer
%     maxPooling2dLayer(2, 'Stride', 2)
%     convolution2dLayer(3, 32, 'Padding', 'same')
%     batchNormalizationLayer
%     reluLayer
%     maxPooling2dLayer(2, 'Stride', 2)
%     convolution2dLayer(3, 64, 'Padding', 'same')
%     batchNormalizationLayer
%     reluLayer
%     fullyConnectedLayer(3)
%     softmaxLayer
%     classificationLayer];
% 
% % Set training options
% options = trainingOptions('adam', ...
%     'MiniBatchSize', 32, ...
%     'MaxEpochs', 10, ...
%     'InitialLearnRate', 1e-3, ...
%     'Verbose', true);
% 
% % Train the YOLO network
% net = trainNetwork(imds, layers, options);