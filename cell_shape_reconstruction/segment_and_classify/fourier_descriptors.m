function fourier_descriptors(features, BWimg)
[features.FourierDescriptors] = deal('');
for k = 1:length(features)
    % Obtener las dimensiones de la caja delimitadora (bounding box)
    bbox = round(features(k).BoundingBox);
    
    % Aumentar el tamaño del bounding box en 10 píxeles en cada dirección
    bbox(1) = bbox(1) - 10; % Desplazar la posición x hacia la izquierda
    bbox(2) = bbox(2) - 10; % Desplazar la posición y hacia arriba
    bbox(3) = bbox(3) + 20; % Aumentar el ancho
    bbox(4) = bbox(4) + 20; % Aumentar la altura
    
    % Asegurarse de que bbox no exceda los límites de la imagen
    bbox(1) = max(bbox(1), 1);
    bbox(2) = max(bbox(2), 1);
    bbox(3) = min(bbox(3), size(BWimg, 2) - bbox(1) + 1);
    bbox(4) = min(bbox(4), size(BWimg, 1) - bbox(2) + 1);
    
    % Recortar la imagen usando la caja delimitadora ajustada
    cropped_img = imcrop(BWimg, bbox);
    
    % Centrar el objeto en la imagen
    object_centered = centerobject(cropped_img);
    
    % Obtener el contorno del objeto centrado
    contour = bwboundaries(object_centered);
    contour = contour{1}; % Si hay un solo objeto, solo hay un contorno
    
    % Convertir el contorno en una serie compleja (x + iy)
    x = contour(:, 2);
    y = contour(:, 1);
    z = x + 1i*y;
    
    % Aplicar la transformada de Fourier
    Z = fft(z);
    
    % Guardar los descriptores de Fourier en la estructura
    features(k).FourierDescriptors = Z;
end
end