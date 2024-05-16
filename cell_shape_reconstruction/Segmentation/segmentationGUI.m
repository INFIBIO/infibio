function segmentationGUI(img, param, features)
    % Crear la figura principal
    fig = uifigure('Name', 'Segmentation Review Tool', 'Position', [100, 100, 800, 600]);

    % Crear un panel para mostrar la imagen original
    originalPanel = uipanel(fig, 'Title', 'Original Image', 'Position', [25, 300, 350, 275]);
    originalAxes = uiaxes(originalPanel, 'Position', [25, 25, 300, 200]);

    % Crear un panel para mostrar la imagen segmentada
    segmentedPanel = uipanel(fig, 'Title', 'Segmented Image', 'Position', [400, 300, 350, 275]);
    segmentedAxes = uiaxes(segmentedPanel, 'Position', [25, 25, 300, 200]);

    % Crear un panel para herramientas de corrección
    correctionPanel = uipanel(fig, 'Title', 'Correction Tools', 'Position', [25, 25, 725, 250]);

    % Botones de corrección
    redoButton = uibutton(correctionPanel, 'Text', 'Redo Segmentation', 'Position', [50, 150, 150, 50], ...
                          'ButtonPushedFcn', @(btn, event) redoSegmentation());
    saveButton = uibutton(correctionPanel, 'Text', 'Save Segmentation', 'Position', [250, 150, 150, 50], ...
                          'ButtonPushedFcn', @(btn, event) saveSegmentation());
    acceptButton = uibutton(correctionPanel, 'Text', 'Accept', 'Position', [450, 150, 150, 50], ...
                            'ButtonPushedFcn', @(btn, event) acceptSegmentation());

    % Mostrar la imagen original
    imshow(img, 'Parent', originalAxes);

    % Inicializar el índice de cuadro delimitador
    bboxIndex = 1;
    showBoundingBox();

    % Esperar a que se cierre la figura antes de continuar
    uiwait(fig);

    function showBoundingBox()
        if bboxIndex <= length(features)
            bbox = features(bboxIndex).BoundingBox;
            croppedImage = imcrop(img, bbox);
            [BW, maskedImage] = segmentImage(croppedImage, param);
            croppedImage = imadjust(croppedImage, stretchlim(croppedImage), []);
            imshow(croppedImage, 'Parent', originalAxes);
            imshow(maskedImage, 'Parent', segmentedAxes);
        else
            uiresume(fig);
            close(fig);
        end
    end

    function redoSegmentation()
        % Aquí puedes añadir código para rehacer la segmentación manualmente
        % Por ejemplo, usando roipoly para dibujar manualmente
        bbox = features(bboxIndex).BoundingBox;
        croppedImage = imcrop(img, bbox);
        BW = roipoly(croppedImage);
        maskedImage = croppedImage;
        maskedImage(~BW) = 0;
        imshow(croppedImage, 'Parent', originalAxes);
        imshow(maskedImage, 'Parent', segmentedAxes);
    end

    function saveSegmentation()
        % Guardar la segmentación corregida
        % Puedes guardar BW o maskedImage según sea necesario
        [file, path] = uiputfile('*.mat', 'Save Segmentation As');
        if ischar(file)
            save(fullfile(path, file), 'BW', 'maskedImage');
        end
    end

    function acceptSegmentation()
        % Continuar al siguiente cuadro delimitador
        bboxIndex = bboxIndex + 1;
        showBoundingBox();
    end
end
