% Script for the first-level analysis of images from yeast digestion
% experiments. The images are first segmented, then features are extracted,
% and finally, the features are tracked. Features of each image are saved
% in individual files for subsequent use. The script assembles the "tracks"
% array, which is then used as input for the tracking program ("track.m"),
% adapted from Crocker and Grier. After rearranging the output, the
% "tracks" array is saved in the same folder where the feature files are
% saved.
%
% The "tracks" array has one feature per row, with columns organized as:
% (CentroidXposition, CentroidYposition, Area, ..., frame, naiveID,
% trackedID). Here, "..." represents additional parameters characterizing
% the features, if needed in the "tracks" array. The naiveID is the ID of
% the feature when it is first featured in that frame, while trackedID is
% the ID once tracked. For example, to track the object with trackID "M",
% select the rows in "tracks" where the last column is "M". The
% corresponding frames are listed in the third-to-last column, and the
% naiveID of that object for those frames will be in the penultimate
% column. An object with trackedID "M" will generally have several naiveIDs
% for different frames. From these rows, you can observe the time evolution
% of any characteristic saved in "tracks" for object "M". If other
% characteristics are needed, read them from "XXXX_features.mat" files
% corresponding to frames where object "M" exists. For example, if a row of
% "tracks" ends with (.....,T,Y,M), it means object "M" exists in frame
% "T", and it corresponds to the object with naiveID "Y". Read the
% "XXXX_features.mat" file for frame "T" to retrieve the features. The
% features for object with trackedID "M" correspond to "features(Y)". For
% instance, "features(Y).outs" gives contour length, and
% "features(Y).theta" gives the tangent angle. The classification function
% adds a DetectedClass variable to features.

% HISTORY:
%   April 5, 2024: MP. Created.
%   July 4, 2024: AR. Modified. August 14, 2024: AR. Modified. Added
%   segmentation.m function to replace segmentImage.m. September 2, 2024:
%   AR. Modified. Added analyzeCellTracks.m function to analyze shape
%   changes over time.

% TODO: 1) Write programs to extract a given set of parameters for an
% object with a specific trackID across all frames where trackedID exists.
% 2) Try watershed segmentation on brightfield images of a single feature
% to reveal the four cells in the tetrad.

%% Input and Output Information
imgpath = 'C:\Users\uib\Desktop\zymo_exp_subset\'; % Path to the folder containing images
datapath = [imgpath, 'data/']; % Path to the folder where feature files will be saved
imgextension = 'png'; % File extension for images (use single quotation marks)

%% Parameter Definition
% Segmentation Parameters
invert = 1; % Set to 0 for images taken at x20 magnification
paramSegment.int_threshold = 30;
paramSegment.mode_threshold = 10;
paramSegment.arearange = [10, inf];
paramSegment.morph_close_radius = 1;

% Featuring Parameters
paramFeature.minlen = 4;
paramFeature.maxlen = inf;
paramFeature.b_init = 1;

% Tracking Parameters
paramTracks.maxdisp = 10;
paramTracks.mem = 0;
paramTracks.good = 2;
paramTracks.dim = 2;
paramTracks.quiet = 1;
tracks = []; % Initialize an empty array for storing tracks

% Classification and Segmentation Paths
predict_clas_script = 'C:\Users\uib\Nextcloud2\classification_model\yolov5\classify\predict.py'; % Path to predict.py script for classification
weights_class = 'C:\Users\uib\Nextcloud2\classification_model\yolov5\runs\train\definitive\weights\best.pt'; % Path to weights for classification
python_path = 'C:\Users\uib\anaconda3\envs\yolov5-env\python.exe'; % Path to Python executable
yolo_path = 'C:\Users\uib\Nextcloud2\classification_model\yolov5'; % Path to YOLOv5 folder
predict_seg_script = 'C:\Users\uib\Nextcloud2\classification_model\yolov5\segment\predict.py'; % Path to predict.py script for segmentation
weights_seg = 'C:\Users\uib\Nextcloud2\classification_model\yolov5\runs\train-seg\best_seg\weights\best.pt'; % Path to weights for segmentation

%% Gather List of Files and Perform Analysis
if ~isdir(datapath)
    mkdir(datapath); % Create data folder if it does not exist
end
myfiles = dir([imgpath, '*.', imgextension]); % List all image files in the specified directory

for tt = 2:11
    if mod(tt - 1, 10) == 0
        disp(['Processing frame ', num2str(tt), ' out of ', num2str(length(myfiles))]);
    end

    % Get the image name and corresponding feature file path
    [~, imgname, ~] = fileparts(myfiles(tt).name);
    featureFile = fullfile(datapath, [imgname, '_features.mat']);

    % Check if the feature file already exists
    if isfile(featureFile)
        disp(['Feature file for frame ', num2str(tt), ' already exists. Skipping feature extraction.']);
        load(featureFile, 'features'); % Load existing features
    else
        % If feature file doesn't exist, process the image
        img = imread([imgpath, myfiles(tt).name]); % Read the image

        [BWimg, maskedImage] = segmentation_fullsize(img, python_path, yolo_path, predict_seg_script, weights_seg); % Perform segmentation

        features = feature_connected_components(BWimg, paramFeature); % Extract features

        % Invert image if needed
        if invert
            img = imcomplement(img);
        end
        features = fourier_descs(features, BWimg); % Compute Fourier descriptors

        % Convert cell arrays to numeric arrays if needed
        for i = 1:length(features)
            array_outkappa = features(i).outkappa(:);
            array_outtheta = features(i).outtheta(:);
            features(i).outkappa = squeeze({array_outkappa'});
            features(i).outtheta = squeeze({array_outtheta'});
        end

        imwrite(BWimg, fullfile(datapath, [imgname, '_BW.png'])); % Save the binary image
        save(featureFile, 'features'); % Save features to .mat file
    end

    % Process and convert feature data
    for i = 1:length(features)
        % Check and convert 'outtheta' if it's a cell array
        if iscell(features(i).outtheta)
            try
                features(i).outtheta = cell2mat(cellfun(@(x) x(:), features(i).outtheta, 'UniformOutput', false));
            catch ME
                warning('Error converting outtheta for feature %d: %s', i, ME.message);
            end
        end

        % Check and convert 'outkappa' if it's a cell array
        if iscell(features(i).outkappa)
            try
                features(i).outkappa = cell2mat(cellfun(@(x) x(:), features(i).outkappa, 'UniformOutput', false));
            catch ME
                warning('Error converting outkappa for feature %d: %s', i, ME.message);
            end
        end

        % Check and convert 'FourierDescriptors' if it's a cell array
        if iscell(features(i).FourierDescriptors)
            try
                features(i).FourierDescriptors = cell2mat(cellfun(@(x) x(:), features(i).FourierDescriptors, 'UniformOutput', false));
            catch ME
                warning('Error converting FourierDescriptors for feature %d: %s', i, ME.message);
            end
        end

        % Transpose arrays if needed (if rows are desired instead of
        % columns)
        features(i).outkappa = features(i).outkappa';
        features(i).outtheta = features(i).outtheta';
        features(i).FourierDescriptors = features(i).FourierDescriptors';
    end

    % Assemble the 'tracks' array using features data
    tracks = [tracks; [vertcat(features.Centroid), ... % Centroid positions
        vertcat(features.Area), ...
        vertcat(features.outkappa), ...
        vertcat(features.outtheta), ...
        vertcat(features.FourierDescriptors), ...
        (1:length(features))', ...
        tt * ones(length(features), 1)]];
end

disp('Done with feature extraction. Moving on to tracking.');
tracks = track(tracks, paramTracks.maxdisp, paramTracks); % Track objects across frames
tracks = tracks(:, [1:size(tracks,2)-3, size(tracks,2)-1, size(tracks,2)-2, size(tracks,2)]); % Reorder columns: (xpos, ypos, Area, ..., frame, naiveID, trackedID)
analyzeCellTracks(tracks, datapath); % Analyze cell tracks
save([datapath, 'tracks.mat'], 'tracks'); % Save the tracks array
disp('Done.')

