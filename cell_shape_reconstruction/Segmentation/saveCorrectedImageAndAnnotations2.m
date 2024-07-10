function saveCorrectedImageAndAnnotations2(img, features, imgpath, imgId, annotationsFile)
    % Convert features to COCO annotation format
    annotations = struct('id', {}, 'image_id', {}, 'category_id', {}, 'bbox', {}, 'area', {}, 'segmentation', {}, 'iscrowd', {});
    annotationId = 1;
    for i = 1:length(features)
        bbox = features(i).BoundingBox;
        area = features(i).Area;
        segmentation = features(i).Segmentation;

        annotation = struct();
        annotation.id = annotationId;
        annotation.image_id = imgId;
        annotation.category_id = 1; % Change as needed
        annotation.bbox = [bbox(1), bbox(2), bbox(3), bbox(4)];
        annotation.area = area;
        annotation.segmentation = {segmentation};
        annotation.iscrowd = 0;

        annotations(end+1) = annotation;
        annotationId = annotationId + 1;
    end

    % Load existing annotations if file exists
    if isfile(annotationsFile)
        existingAnnotations = jsondecode(fileread(annotationsFile));
        annotations = [existingAnnotations; annotations];
    end

    % Save annotations to JSON file
    jsonStr = jsonencode(annotations);

    fid = fopen(annotationsFile, 'w');
    if fid == -1
        error('Cannot create JSON file');
    end
    fwrite(fid, jsonStr, 'char');
    fclose(fid);

    % Save the corrected image
    imwrite(img, fullfile(imgpath, ['corrected_', num2str(imgId), '.png']));
end
