function saveCorrectedImageAndAnnotations2(img, features, imgpath, imgId, annotationsFile)
    % Initialize the structure
    if exist(annotationsFile, 'file')
        % Load existing annotations
        jsonStr = fileread(annotationsFile);
        data = jsondecode(jsonStr);
    else
        % Initialize new annotation structure
        data = struct();
        data.info = struct('year', '2024', 'version', '1', 'description', 'Exported from roboflow.com', ...
            'contributor', '', 'url', 'https://public.roboflow.com/object-detection/undefined', ...
            'date_created', '2024-05-21T12:29:20+00:00');
        data.licenses = struct('id', 1, 'url', 'https://creativecommons.org/licenses/by/4.0/', 'name', 'CC BY 4.0');
        data.categories = struct('id', {0, 1}, 'name', {'mask', 'mask'}, 'supercategory', {'none', 'mask'});
        data.images = [];
        data.annotations = [];
    end

    % Add the current image info to the images array
    imgInfo = struct();
    imgInfo.id = imgId;
    imgInfo.license = 1;
    imgInfo.file_name = ['image', num2str(imgId), '.tif'];
    imgInfo.width = size(img, 2);
    imgInfo.height = size(img, 1);
    imgInfo.date_captured = '2024-05-21T12:29:20+00:00';
    data.images(end+1) = imgInfo;

    % Add annotations
    for i = 1:length(features)
        bbox = features(i).BoundingBox;
        area = numel(features(i).PixelIdxList); % Calculate area as number of pixels

        % Normalize bounding box coordinates
        centerX = (bbox(1) + bbox(3) / 2) / size(img, 2);
        centerY = (bbox(2) + bbox(4) / 2) / size(img, 1);
        width = bbox(3) / size(img, 2);
        height = bbox(4) / size(img, 1);

        % Calculate segmentation points (convert PixelIdxList to x, y coordinates)
        [rows, cols] = ind2sub(size(img), features(i).PixelIdxList);
        segmentation = [cols, rows]'; % transpose to get [x, y] format
        segmentation = segmentation(:)'; % flatten to a single array

        annotation = struct();
        annotation.id = length(data.annotations) + 1;
        annotation.image_id = imgId;
        annotation.category_id = 1; % Change as needed
        annotation.bbox = [centerX, centerY, width, height];
        annotation.area = area;
        annotation.segmentation = {segmentation};
        annotation.iscrowd = 0;

        data.annotations(end+1) = annotation;
    end

    % Save annotations to JSON file
    jsonStr = jsonencode(data);

    fid = fopen(annotationsFile, 'w');
    if fid == -1
        error('Cannot create JSON file');
    end
    fwrite(fid, jsonStr, 'char');
    fclose(fid);

    % Save the corrected image
    imwrite(img, fullfile(imgpath, ['corrected_', num2str(imgId), '.png']));
end
