function [cellCentroidsBrightfield, cellCentroidsFluorescence1, cellCentroidsFluorescence2, ... 
    cellPropertiesBrightfield, cellPropertiesFluorescence1, cellPropertiesFluorescence2, ...
    processedFluorescence1, bwFluorescence11, processedFluorescence2, bwFluorescence22] = ...
    track_and_identify_cells_v2(brightfieldImage, fluorescenceImage1, fluorescenceImage2, folderPath)
    
    % Convert images to double
    brightfieldImage = im2double(brightfieldImage);
    fluorescenceImage1 = im2double(fluorescenceImage1);
    fluorescenceImage2 = im2double(fluorescenceImage2);

    % Assess image quality and get suggested parameters
    suggestedParamsBrightfield = assess_image_quality(brightfieldImage);
    suggestedParamsFluorescence1 = assess_image_quality(fluorescenceImage1);
    suggestedParamsFluorescence2 = assess_image_quality(fluorescenceImage2);

        % Binarization using suggested parameters
        bwBrightfield = imbinarize(brightfieldImage, suggestedParamsBrightfield.Method, ...
        'Sensitivity', suggestedParamsBrightfield.Sensitivity, 'ForegroundPolarity', 'dark');
        bwBrightfield2 = imclearborder(bwBrightfield);

        minCellSize = 80;
        maxCellSize = 1000;
        bwBrightfield3 = bwareaopen(bwBrightfield2, minCellSize) & ~bwareaopen(bwBrightfield2, maxCellSize);

        cellPropertiesBrightfield = regionprops(bwBrightfield3, {'Centroid', 'Area', 'Perimeter', 'Circularity', 'Eccentricity', 'Solidity', 'MinorAxisLength', 'MajorAxisLength'});
        cellCentroidsBrightfield = cat(1, cellPropertiesBrightfield.Centroid);

        fig_brightfield = figure;
        imshow(brightfieldImage);
        hold on;
        title('Cell Centroids in Brightfield Image');
        for i = 1:numel(cellCentroidsBrightfield)
            try
                plot(cellCentroidsBrightfield(i, 1), cellCentroidsBrightfield(i, 2), 'ro', 'MarkerSize', 10, 'LineWidth', 1);
                hold on;
            catch
                disp(['Error: Index ', num2str(i), ' exceeds array bounds. Skipping...']);
            end
        end
        saveas(fig_brightfield, fullfile(folderPath, 'brightfield_with_centroids.tif'));
        saveas(fig_brightfield, fullfile(folderPath, 'brightfield_with_centroids.fig'));
        close(fig_brightfield);

        % Binarization using suggested parameters
        minValue = min(fluorescenceImage1(:));
        maxValue = max(fluorescenceImage1(:));
        disp(['Min pixel value: ', num2str(minValue)]);
        disp(['Max pixel value: ', num2str(maxValue)]);

        processedFluorescence1 = imadjust(fluorescenceImage1);
        bwFluorescence1 = imbinarize(fluorescenceImage1, suggestedParamsFluorescence1.Method, ...
        'Sensitivity', suggestedParamsFluorescence1.Sensitivity, 'ForegroundPolarity', 'bright');
        bwFluorescence11 = bwareaopen(bwFluorescence1, minCellSize) & ~bwareaopen(bwFluorescence1, maxCellSize);

        cellPropertiesFluorescence1 = regionprops(bwFluorescence11, {'Centroid', 'Area', 'Perimeter', 'Circularity', 'Eccentricity', 'Solidity', 'MinorAxisLength', 'MajorAxisLength'});
        cellCentroidsFluorescence1 = cat(1, cellPropertiesFluorescence1.Centroid);

        fig_fluorescence1=figure;
        imshow(fluorescenceImage1);
        hold on;
        title('Cell Centroids in Fluorescence Image 1');
        for i = 1:numel(cellCentroidsFluorescence1)
            try
                plot(cellCentroidsFluorescence1(i, 1), cellCentroidsFluorescence1(i, 2), 'go', 'MarkerSize', 10, 'LineWidth', 1);
                hold on;
            catch
                disp(['Error: Index ', num2str(i), ' exceeds array bounds. Skipping...']);
            end
        end
        saveas(fig_fluorescence1, fullfile(folderPath, 'fluorescence1_with_centroids.tif'));
        saveas(fig_fluorescence1, fullfile(folderPath, 'fluorescence1_with_centroids.fig'));
        close(fig_fluorescence1);

        % Binarization using suggested parameters
        processedFluorescence2 = imadjust(fluorescenceImage2);
        bwFluorescence2 = imbinarize(fluorescenceImage2, suggestedParamsFluorescence2.Method, ...
        'Sensitivity', suggestedParamsFluorescence2.Sensitivity, 'ForegroundPolarity', 'bright');
        minCellSize = 50;
        bwFluorescence22 = bwareaopen(bwFluorescence2, minCellSize) & ~bwareaopen(bwFluorescence2, maxCellSize);

        cellPropertiesFluorescence2 = regionprops(bwFluorescence22, {'Centroid', 'Area', 'Perimeter', 'Circularity', 'Eccentricity', 'Solidity', 'MinorAxisLength', 'MajorAxisLength'});
        cellCentroidsFluorescence2 = cat(1, cellPropertiesFluorescence2.Centroid);

        fig_fluorescence2=figure;
        imshow(fluorescenceImage2);
        hold on;
        title('Cell Centroids in Fluorescence Image 2');
        for i = 1:numel(cellCentroidsFluorescence2)
            try
                plot(cellCentroidsFluorescence2(i, 1), cellCentroidsFluorescence2(i, 2), 'bo', 'MarkerSize', 10, 'LineWidth', 1);
                hold on;
            catch
                disp(['Error: Index ', num2str(i), ' exceeds array bounds. Skipping...']);
            end
        end
        saveas(fig_fluorescence2, fullfile(folderPath, 'fluorescence2_with_centroids.tif'));
        saveas(fig_fluorescence2, fullfile(folderPath, 'fluorescence2_with_centroids.fig'));
        close(fig_fluorescence2);
   end
