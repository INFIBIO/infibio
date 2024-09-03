function [BWimg_full, maskedImage_full] = segmentation_fullsize(img, python_path, yolo_path, predict_seg_script, weights_seg)

% function to apply the segmentation model of yolov5 to segment yeast
% accurately.
% INPUT:
% img: raw image. A 1216x1920 png image.
% python_path: path to python.exe in yolov5 conda environment.
% yolo_path: path/to/yolov5 cloned from github repository.
% weights: path to best.pt.
%
% OUTPUT:
% BWimg_full: mask as binary image for the full image.
% maskedImage_full: raw image with the mask applied.
%
% HISTORY:
% 14 August, 2024. AR. Created. Modified from classification.m script (AR,
% July)
% 22 August, 2024. Updated to handle image cropping and reconstruction (ChatGPT).

% Convert image to double and normalize
img = imadjust(img);

% Dimensions of the input image
[height, width, ~] = size(img);

% Initialize the final binary mask and masked image
BWimg_full = false(height, width);
maskedImage_full = zeros(height, width, 'uint8');

% Determine the number of crops
crop_size = 640;
overlap = 500; % No overlap in this example
x_steps = ceil((width - overlap) / crop_size);
y_steps = ceil((height - overlap) / crop_size);

% Iterate over the image to create crops
for i = 1:y_steps
    for j = 1:x_steps
        
        % Define crop boundaries
        x_start = (j-1) * crop_size + 1;
        y_start = (i-1) * crop_size + 1;
        
        x_end = min(x_start + crop_size - 1, width);
        y_end = min(y_start + crop_size - 1, height);
        
        % Extract the crop
        img_crop = img(y_start:y_end, x_start:x_end, :);
        
        % Save the crop to a temporary file
        temp_img_path = fullfile(tempdir, sprintf('temp_image_%d_%d.png', i, j));
        imwrite(img_crop, temp_img_path);
        
        % Adjust Python path for current crop
        pyenv('Version', python_path);
        img_path = strrep(temp_img_path, '/', '//');
        
        % Construct the Python command
        python_cmd = sprintf('%s %s --weights %s --img %d --source %s --save-txt --hide-labels --hide-conf', ...
                             python_path, predict_seg_script, weights_seg, crop_size, img_path);
        
        % Execute the Python command
        status = system(python_cmd);
        
        % Find the latest exp folder in the runs/detect directory
        detect_dir = fullfile(yolo_path, 'runs', 'predict-seg');
        exp_dirs = dir(fullfile(detect_dir, 'exp*'));
        [~, idx] = max([exp_dirs.datenum]);
        latest_exp_dir = fullfile(detect_dir, exp_dirs(idx).name);
        
        % Load the detected classes from the .txt file
        detected_seg_file = fullfile(latest_exp_dir, 'labels', sprintf('temp_image_%d_%d.txt', i, j));
        fileID = fopen(detected_seg_file, 'r');
        data = textscan(fileID, '%s', 'Delimiter', '\n');
        fclose(fileID);
        
        % Initialize the binary mask for the crop
        BWimg_crop = false(crop_size, crop_size);

        % Process each line of the data
        for k = 1:numel(data{1})
            % Extract the coordinates from the current line
            coords_str = strsplit(data{1}{k});
            coords = str2double(coords_str);

            % Check if conversion to double was successful
            if any(isnan(coords))
                warning('Some coordinates could not be converted to numbers on line %d', k);
                continue;
            end

            % Ignore the first number (class)
            coords = coords(2:end);

            % Convert normalized coordinates to pixels
            x_coords = coords(1:2:end) * crop_size; % x-coordinates
            y_coords = coords(2:2:end) * crop_size; % y-coordinates

            % Create a polygon from the coordinates
            mask = poly2mask(x_coords, y_coords, crop_size, crop_size);

            % Combine the mask with the binary image
            BWimg_crop = BWimg_crop | mask;
        end
        
        % Apply the mask to the crop across all color channels
        maskedImage_crop = img_crop; % Start with the original crop
        maskedImage(~BWimg_crop) = 0;
        
        % Insert the crop mask and masked image back into the full-size outputs
        BWimg_full(y_start:y_end, x_start:x_end) = BWimg_crop(1:(y_end-y_start+1), 1:(x_end-x_start+1));
        maskedImage_full(y_start:y_end, x_start:x_end, :) = maskedImage_crop(1:(y_end-y_start+1), 1:(x_end-x_start+1), :);
        
        % Clean up temporary files and directories
        rmdir(latest_exp_dir, 's');
        delete(temp_img_path);
    end
end

% Post-process: Close small gaps between masks in BWimg_full
se = strel('disk', 5); % Structuring element with radius of 5 pixels
BWimg_full = imclose(BWimg_full, se); % Close gaps smaller than 5 pixels

% Apply the final mask to the image
maskedImage_full = img;
maskedImage_full(~BWimg_full) = 0;

end
