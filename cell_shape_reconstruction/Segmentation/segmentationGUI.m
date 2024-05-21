function updatedFeatures = segmentationGUI(img, param, features, imgId)
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
    
    acceptButton = uibutton(correctionPanel, 'Text', 'Accept', 'Position', [300, 150, 150, 50], ...
                            'ButtonPushedFcn', @(btn, event) acceptSegmentation());

    backButton = uibutton(correctionPanel, 'Text', 'Go Back', 'Position', [550, 150, 150, 50], ...
                            'ButtonPushedFcn', @(btn, event) backSegmentation());

    % Mostrar la imagen original
    imshow(img, 'Parent', originalAxes);

    % Inicializar el índice de cuadro delimitador
    bboxIndex = 1;
    showBoundingBox();

    % Esperar a que se cierre la figura antes de continuar
    uiwait(fig);
    updatedFeatures = features;

    function showBoundingBox()
        if bboxIndex <= length(features)
            bbox = features(bboxIndex).BoundingBox;
            croppedImage = imcrop(img, bbox);
            [BW, maskedImage] = segmentImage_AR(img, param);
            BW = imcrop(BW, bbox);
            croppedImage = imadjust(croppedImage, stretchlim(croppedImage), []);
            imshow(croppedImage, 'Parent', originalAxes);
            imshow(BW, 'Parent', segmentedAxes);
        else
            uiresume(fig);
            close(fig);
        end
    end

    function redoSegmentation()
        bbox = features(bboxIndex).BoundingBox;
        croppedImage = imcrop(img, bbox);
        if isempty(croppedImage)
            disp('Error: Cropped image is empty.');
            return;
        end

        imageSegmenter(croppedImage);
        
        disp('Please refine the segmentation in the Image Segmenter App.');
        disp('After refining, save the mask as "BW" and close the app.');
        
        waitfor(msgbox('Press OK after saving the refined mask as variable "BW" in the workspace.'));
        
        while true
            pause(1);
            if evalin('base', 'exist(''BW'', ''var'')')
                break;
            end
        end
        
        BW = evalin('base', 'BW');
        
        if size(BW, 3) > 1
            BW = BW(:,:,1) > 128;
        end
        fullBW = false(size(img, 1), size(img, 2));
    
        y1 = round(bbox(2));
        y2 = y1 + size(BW, 1) - 1;
        x1 = round(bbox(1));
        x2 = x1 + size(BW, 2) - 1;
    
        if y2 > size(fullBW, 1)
            y2 = size(fullBW, 1);
        end
        if x2 > size(fullBW, 2)
            x2 = size(fullBW, 2);
        end
        
        fullBW(y1:y2, x1:x2) = BW(1:(y2-y1+1), 1:(x2-x1+1));
        imshow(fullBW(y1:y2, x1:x2) , 'Parent', segmentedAxes);
        features(bboxIndex).PixelIdxList = find(fullBW);
        features(bboxIndex).Segmentation = getSegmentation(fullBW); % Add segmentation data
        features(bboxIndex).Area = sum(fullBW(:)); % Calculate area
        bboxIndex = bboxIndex + 1;
        showBoundingBox();
    end

    function acceptSegmentation()
        bbox = round(features(bboxIndex).BoundingBox);
        croppedImage = imcrop(img, bbox);
        [height, width] = size(croppedImage);
        [BW, ~] = segmentImage_AR(img, param);
        BW = imcrop(BW, bbox);
        if size(BW, 1) ~= height || size(BW, 2) ~= width
            error('Dimensions of BW and croppedImage do not match');
        end
        
        fullBW = false(size(img, 1), size(img, 2));
        fullBW(bbox(2):(bbox(2)+height-1), bbox(1):(bbox(1)+width-1)) = BW;
        features(bboxIndex).PixelIdxList = find(fullBW);
        features(bboxIndex).Segmentation = getSegmentation(fullBW); % Add segmentation data
        features(bboxIndex).Area = sum(fullBW(:)); % Calculate area
        bboxIndex = bboxIndex + 1;
        showBoundingBox();
    end

    function backSegmentation()
        bboxIndex = bboxIndex - 1;
        showBoundingBox();
    end

    function segmentation = getSegmentation(mask)
        [rows, cols] = find(mask);
        segmentation = [cols, rows]'; % Format as [x1, y1, x2, y2, ..., xn, yn]
        segmentation = segmentation(:)';
    end
end

