%Initialize the LAPLinker object
linker = LAPLinker;


% Specify the folder containing the raw TIF images.
myFolder = 'C:\Users\uib\Desktop\prueba_script_python\Exp_Zymolyase01-005_ConA03-2024110\E1\0\tiff'
% Check to make sure that folder actually exists. 
if ~isfolder(myFolder)
    errorMessage = sprintf('Error: The following folder does not exist:\n%s\nPlease specify a new folder.', myFolder);
    uiwait(warndlg(errorMessage));
    myFolder = uigetdir(); % Ask for a new one
    % 
    % 
    % .
    if myFolder == 0;
         % User clicked Cancel
         return;
    end
end

% Get a list of all files in the folder with the desired file name pattern.
filePattern = fullfile(myFolder, ['*.tif' ...
    '']); 
theFiles = dir(filePattern);


for frame = 1:3
% From here to ` [propsbw_cleaned.Enumeration] = enumerationColumn{:};` is
% copied from script_image_analysis_AR_V1.m
    baseFileName = theFiles(frame).name;
    fullFileName = fullfile(theFiles(frame).folder, baseFileName);
    [X,~] = imread(fullFileName)
    BW = imbinarize(im2gray(X), 'adaptive', 'Sensitivity', 0.750000, 'ForegroundPolarity', 'bright');
    BW = imcomplement(BW);
    BW = imfill(BW, 'holes');
    BW = imclearborder(BW);
    BW_out = bwpropfilt(BW,'Area',[2500 + eps(2500), Inf]);
    BW_borders = bwperim(BW_out);
    perimeter = regionprops(bwconncomp(BW_borders),{'PixelList'});
    propsbw = regionprops(bwconncomp(BW_out), {'Area', 'Centroid', 'FilledArea','ConvexArea', 'Perimeter', 'Circularity', 'Eccentricity'});
    propsbw_cleaned = struct('Area', [], 'Centroid', [], 'FilledArea', [], 'ConvexArea', [], 'Perimeter', [], 'Circularity', [], 'Eccentricity', []);
    BW_out_uint8 = im2uint8(BW_out);
    centroidPositions = zeros(numel(propsbw_cleaned), 2);
    
    for i = 1:numel(propsbw)
        if ~isempty(propsbw(i).Centroid)
            x = propsbw(i).Centroid(1);
            y = propsbw(i).Centroid(2);
            centroidPositions(i, :) = [x, y];
        end
    end
    
    
    
    [~, baseName, ~] = fileparts(fullFileName);
    nameParts = strsplit(baseName, '_');
    
    dilution = str2double(nameParts{end - 1});  % Assuming dilution is the second-to-last part
    time = str2double(nameParts{end});  % Assuming time is the last part
    
    
    
    enumerationColumn = cell(length(propsbw_cleaned), 1);
    for i = 1:length(propsbw)
        if propsbw(i).Area > 2500
            propsbw_cleaned(end+1) = propsbw(i);
        end
    end
    propsbw_cleaned(1) = [];
    
    for i = 1:length(propsbw_cleaned)
        propsbw_cleaned(i).Time = [];
        propsbw_cleaned(i).Enumeration = [];
        propsbw_cleaned(i).Border = [];
        enumerationColumn{i} = num2str(i);
    end
    
    
    for i = 1:length(propsbw_cleaned)
        propsbw_cleaned(i).Time = time;
    end
    
    enumerationColumn = enumerationColumn(~cellfun('isempty', enumerationColumn));
    [propsbw_cleaned.Enumeration] = enumerationColumn{:};
    
    for i = 1:length(propsbw_cleaned)
        
        propsbw_cleaned(i).Border = perimeter(i).PixelList;
    end
    %Link objects
    linker = assignToTrack(linker, frame, propsbw_cleaned);

end

figure;
hold on;

%Get the TrackArray for data analysis
trackData = linker.tracks;
numTracks = numel(trackData.Tracks);  % Get the number of tracks
cmap = hsv(numTracks);
handles = gobjects(numTracks, 1);
for frame = 1:3
    baseFileName = theFiles(frame).name;
    fullFileName = fullfile(theFiles(frame).folder, baseFileName);
    [X,~] = imread(fullFileName)
    BW = imbinarize(im2gray(X), 'adaptive', 'Sensitivity', 0.750000, 'ForegroundPolarity', 'bright');
    BW = imcomplement(BW);
    BW = imfill(BW, 'holes');
    BW = imclearborder(BW);
    imshow(BW, 'InitialMagnification', 'fit', 'Border', 'tight', 'XData', [1 size(BW, 2)], 'YData', [1 size(BW, 1)]);
    alpha(0.10);  % Set transparency to 50%  % Create a new figure for the plot
    hold on;
    for i = 1:numTracks
            numCentroids = numel(trackData.Tracks(i).Data.Centroid);
            for j = 2:numCentroids
                centroid = trackData.Tracks(i).Data.Centroid{j};  % Corrected index to start from 2
                % Plot the centroid with the track index as the color index
                handles(i) = plot(centroid(1), centroid(2), 'o', 'Color', cmap(i,:));
            end
        end
    end
for i = 1:numTracks
    centroid = trackData.Tracks(i).Data.Centroid{2};  % Assuming at least one centroid exists for each track
    text(centroid(1), centroid(2), sprintf('Track %d', i), 'Color', 'r', 'FontSize', 8, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
end

hold off;  % Release the hold on the plot

% Add labels or customize the plot as needed
xlabel('X-coordinate');  % Label for x-axis
ylabel('Y-coordinate');  % Label for y-axis
title('Centroids of Tracks');  % Title for the plot


