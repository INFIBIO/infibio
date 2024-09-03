function [features] = fourier_descs(features, BWimg)
    % This function calculates Fourier descriptors for each feature.
    % INPUTS:
    %   features: A structure array where each element contains 'BoundingBox' field.
    %   BWimg: A binary image where features are located.
    % OUTPUT:
    %   features: The input structure array with an additional 'FourierDescriptors' field.

    % Initialize Fourier Descriptors as empty strings
    [features.FourierDescriptors] = deal('');  
    
    for k = 1:length(features)
        % Get the dimensions of the bounding box
        bbox = round(features(k).BoundingBox);
        
        % Expand the bounding box by 2 pixels in each direction
        bbox(1) = bbox(1) - 2; % Move x position to the left
        bbox(2) = bbox(2) - 2; % Move y position upwards
        bbox(3) = bbox(3) + 4; % Increase width
        bbox(4) = bbox(4) + 4; % Increase height
        
        % Ensure the bounding box does not exceed image boundaries
        bbox(1) = max(bbox(1), 1);
        bbox(2) = max(bbox(2), 1);
        bbox(3) = min(bbox(3), size(BWimg, 2) - bbox(1) + 1);
        bbox(4) = min(bbox(4), size(BWimg, 1) - bbox(2) + 1);
        
        % Crop the image using the adjusted bounding box
        cropped_img = imcrop(BWimg, bbox);
        
        % Label objects in the cropped binary image
        labeled_img = bwlabel(cropped_img);
        
        % Measure the areas of the labeled objects
        stats = regionprops(labeled_img, 'Area');
        all_areas = [stats.Area];
        
        % Find the index of the largest object
        [~, largest_idx] = max(all_areas);
        
        % Keep only the largest object and remove the others
        object_largest = ismember(labeled_img, largest_idx);
        
        % Center the largest object in the image
        object_centered = centerobject(object_largest);  % Centering the object
        
        % Get the contour of the centered object
        contour = bwboundaries(object_centered);
        contour = contour{1}; % Only one contour should be present
        
        % Convert the contour into a complex series (x + iy)
        x = contour(:, 2);
        y = contour(:, 1);
        z = x + 1i * y;
        
        % Apply the Fourier Transform
        Z = fft(z);
        
        % Keep only the first 150 Fourier coefficients
        num_coeffs = 150;
        if length(Z) >= num_coeffs
            Z = Z(1:num_coeffs);  % Take the first 150 coefficients
        else
            Z = [Z; zeros(num_coeffs - length(Z), 1)]; % Pad with zeros if fewer than 150 coefficients
        end
        
        % Store the Fourier Descriptors in the structure
        features(k).FourierDescriptors = Z;
    end
end
