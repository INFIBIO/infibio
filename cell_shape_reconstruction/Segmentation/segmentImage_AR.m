function [BW, maskedImage] = segmentImage_AR(X, param)
    % Adjust data to span data range.
    X = imadjust(X);

    % Threshold image with manual threshold
    BW = im2gray(X) > param.int_threshold;

    % Clear borders
    BW = imclearborder(BW);

    % Close mask with default
    decomposition = 0;
    se = strel('disk', param.morph_close_radius, decomposition);
    BW = imclose(BW, se);

    % Fill holes
    BW = imfill(BW, 'holes');

    BW = bwpropfilt(BW, 'Area', param.arearange);

    features = regionprops(BW, "PixelIdxList", "BoundingBox");
    for ii = 1:length(features)
        if mode(X(features(ii).PixelIdxList)) < param.mode_threshold
            BW(features(ii).PixelIdxList) = 0;
        end
    end

    % Create masked image.
    maskedImage = X;
    maskedImage(~BW) = 0;
end