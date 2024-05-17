function saveCorrectedImageAndAnnotations(img, features, savepath)
    % Obtener el timestamp actual
    timestamp = datetime('now', 'Format', 'ddMMyyyy_HHmmssSSS'); % Formato: ddMMyyyy_HHmmssSSS

    
    % Reconstruir la máscara completa a partir de los PixelIdxList
    fullBW = false(size(img, 1), size(img, 2));
    for k = 1:length(features)
        fullBW(features(k).PixelIdxList) = true;
    end

    % Guardar la imagen completa y la máscara con el timestamp
    correctedImageFileName = fullfile(savepath, ['corrected_image_' timestamp '.png']);
    imwrite(img, correctedImageFileName);

    maskFileName = fullfile(savepath, ['corrected_mask_' timestamp '.png']);
    imwrite(fullBW, maskFileName);

    % Crear y guardar las anotaciones en formato YOLO
    [height, width, ~] = size(img);
    annotationFileName = fullfile(savepath, ['annotations_' timestamp '.txt']);
    fileID = fopen(annotationFileName, 'w');
    for k = 1:length(features)
        bbox = round(features(k).BoundingBox); % Asegurar que bbox son enteros
        centerX = (bbox(1) + bbox(3) / 2) / width;
        centerY = (bbox(2) + bbox(4) / 2) / height;
        bboxWidth = bbox(3) / width;
        bboxHeight = bbox(4) / height;
        fprintf(fileID, '0 %.6f %.6f %.6f %.6f\n', centerX, centerY, bboxWidth, bboxHeight);  % '0' es la clase, ajusta según sea necesario
    end
    fclose(fileID);
end
