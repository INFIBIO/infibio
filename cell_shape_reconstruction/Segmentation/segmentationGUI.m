function updatedFeatures = segmentationGUI(img, param, features)
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
        % Aquí puedes añadir código para rehacer la segmentación manualmente
        % Por ejemplo, usando roipoly para dibujar manualmente
        bbox = features(bboxIndex).BoundingBox;
        croppedImage = imcrop(img, bbox);
        %croppedImage = imadjust(croppedImage, stretchlim(croppedImage), []);
        if isempty(croppedImage)
            disp('Error: Cropped image is empty.');
            return;
        end

        imageSegmenter(croppedImage);
        
        % Instruir al usuario a guardar la máscara refinada
        disp('Please refine the segmentation in the Image Segmenter App.');
        disp('After refining, save the mask as "BW" and close the app.');
        
         % Esperar a que el usuario guarde la máscara refinada y cierre la aplicación
        waitfor(msgbox('Press OK after saving the refined mask as variable "BW" in the workspace.'));
        
        % Esperar hasta que la variable refinedMask esté en el workspace
        while true
            pause(1); % Esperar 1 segundo antes de comprobar nuevamente
            if evalin('base', 'exist(''BW'', ''var'')')
                break;
            end
        end
        % 
        % Cargar la máscara refinada desde el espacio de trabajo
        BW = evalin('base', 'BW');
        
        % Asegurarse de que la máscara refinada es binaria
        if size(BW, 3) > 1
            BW = BW(:,:,1) > 128; % Convertir a binario si es necesario
        end
        fullBW = false(size(img, 1), size(img, 2));
    
        % Calcular las coordenadas de asignación en fullBW
        y1 = round(bbox(2));
        y2 = y1 + size(BW, 1) - 1;
        x1 = round(bbox(1));
        x2 = x1 + size(BW, 2) - 1;
    
        % Asegurarse de que las dimensiones coinciden antes de la asignación
        if y2 > size(fullBW, 1)
            y2 = size(fullBW, 1);
        end
        if x2 > size(fullBW, 2)
            x2 = size(fullBW, 2);
        end
        
        fullBW(y1:y2, x1:x2) = BW(1:(y2-y1+1), 1:(x2-x1+1));
        imshow(fullBW(y1:y2, x1:x2) , 'Parent', segmentedAxes);
        features(bboxIndex).PixelIdxList = find(fullBW);
        % Continuar al siguiente cuadro delimitador
        bboxIndex = bboxIndex + 1;
        showBoundingBox();
    end
    function acceptSegmentation()
            % Guardar la segmentación actual en features
            bbox = round(features(bboxIndex).BoundingBox); % Asegurar que bbox son enteros
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
    
            % Continuar al siguiente cuadro delimitador
            bboxIndex = bboxIndex + 1;
            
            showBoundingBox();
        end
    function backSegmentation()
            % Continuar al anterior cuadro delimitador
            bboxIndex = bboxIndex - 1;
            showBoundingBox();
        end
    
end