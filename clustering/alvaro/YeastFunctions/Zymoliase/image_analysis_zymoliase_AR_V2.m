%%%% This function extracts the binarized image from a TIF raw image. Cells binarized are enumerated in order to make easier the review of the images. The output is a .m file and a .csv files with
%%%% the parameters specified in region props ('Area', 'Centroid', 'FilledArea','ConvexArea', 'Perimeter', 'Circularity', 'Eccentricity', to date [2024.03.04])


function image_analysis_zymoliase_AR_V2(route, myFolder)

[X,~] = imread(route);

% Segmentar la imagen utilizando código generado automáticamente desde la aplicación Image Segmenter
BW = imbinarize(im2gray(X), 'adaptive', 'Sensitivity', 0.680000, 'ForegroundPolarity', 'bright');
BW = imcomplement(BW);
BW = imfill(BW, 'holes');
BW = imclearborder(BW);

% Filter those areas smaller than 2500 to avoid noise
BW_out = bwpropfilt(BW,'Area',[2500 + eps(2500), Inf]);

propsbw = regionprops(BW_out, {'Area', 'Centroid', 'FilledArea','ConvexArea', 'Perimeter', 'Circularity', 'Eccentricity'});
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



[~, baseName, ~] = fileparts(route);
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
    enumerationColumn{i} = num2str(i);
end


for i = 1:length(propsbw_cleaned)
    propsbw_cleaned(i).Time = time;
end

enumerationColumn = enumerationColumn(~cellfun('isempty', enumerationColumn));
[propsbw_cleaned.Enumeration] = enumerationColumn{:};

numEtiquetas = 1:length(propsbw_cleaned);

labeledImage = insertText(BW_out_uint8, centroidPositions, cellstr(num2str([numEtiquetas]')), ...
    'FontSize', 18, 'TextColor', 'y', 'BoxColor', 'black', 'BoxOpacity', 0.7);


newImageName = strcat(baseName, '_labeled.tif');
imwrite(labeledImage, fullfile(myFolder, newImageName));

FileName = fullfile(myFolder, [baseName, '_results.mat']);
FileName_csv = fullfile(myFolder, [baseName, '_results.csv']);
writetable(struct2table(propsbw_cleaned), FileName_csv,'Delimiter',',');
save(FileName, 'propsbw_cleaned');

end
