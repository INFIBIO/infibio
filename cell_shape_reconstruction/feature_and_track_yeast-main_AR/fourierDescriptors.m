% Cargar la imagen
img = imread('C:\Users\uib\Desktop\zymo_exp_subset\E1.0_0093.png');

% Configuración de parámetros para la extracción de características
paramFeature.minlen = 4;
paramFeature.maxlen = inf;
paramFeature.b_init = 1;

% Configuración para la clasificación y segmentación con YOLO
predict_clas_script = 'C:\Users\uib\Nextcloud2\classification_model\yolov5\classify\predict.py';
weights_class = 'C:\Users\uib\Nextcloud2\classification_model\yolov5\runs\train\definitive\weights\best.pt';
python_path = 'C:\Users\uib\anaconda3\envs\yolov5-env\python.exe';
yolo_path = 'C:\Users\uib\Nextcloud2\classification_model\yolov5';
predict_seg_script = 'C:\Users\uib\Nextcloud2\classification_model\yolov5\segment\predict.py';
weights_seg = 'C:\Users\uib\Nextcloud2\classification_model\yolov5\runs\train-seg\best_seg\weights\best.pt';

% Segmentación de la imagen
[BWimg, maskedImage] = segmentation_fullsize(img, python_path, yolo_path, predict_seg_script, weights_seg);

% Extracción de características de los componentes conectados
features = feature_connected_components(BWimg, paramFeature);

% Inicializar las estructuras para almacenar descriptores de Fourier y wavelets
fd = struct('FD', []);
wavelet_features = struct('Wavelets', []);

% Crear una nueva figura para la representación gráfica
figure;
hold on;

for k = 1:length(features)
    % Obtener las dimensiones de la caja delimitadora (bounding box)
    bbox = round(features(k).BoundingBox);
    
    % % Aumentar el tamaño del bounding box en 10 píxeles en cada dirección
    % bbox(1) = bbox(1) - ; % Desplazar la posición x hacia la izquierda
    % bbox(2) = bbox(2) - 2; % Desplazar la posición y hacia arriba
    % bbox(3) = bbox(3) + 4; % Aumentar el ancho
    % bbox(4) = bbox(4) + 4; % Aumentar la altura
    
    % Asegurarse de que bbox no exceda los límites de la imagen
    bbox(1) = max(bbox(1), 1);
    bbox(2) = max(bbox(2), 1);
    bbox(3) = min(bbox(3), size(BWimg, 2) - bbox(1) + 1);
    bbox(4) = min(bbox(4), size(BWimg, 1) - bbox(2) + 1);
    % Recortar la imagen usando la caja delimitadora ajustada
        cropped_img = imcrop(BWimg, bbox);
        
        % Etiquetar los objetos en la imagen binaria recortada
        labeled_img = bwlabel(cropped_img);
        
        % Medir las áreas de los objetos etiquetados
        stats = regionprops(labeled_img, 'Area');
        all_areas = [stats.Area];
        
        % Encontrar el objeto más grande
        [~, largest_idx] = max(all_areas);
        
        % Mantener solo el objeto más grande y eliminar los demás
        object_largest = ismember(labeled_img, largest_idx);
        
        % Centrar el objeto más grande en la imagen
        object_centered = centerobject(object_largest);  % Ahora solo hay un objeto, se puede centrar
    
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
    fd(k).FD = Z;
    
    % Número de coeficientes de Fourier para la reconstrucción
    num_coeff = 5; % Puedes ajustar este número según sea necesario
    
    % Reconstruir la señal usando los primeros num_coeff y los correspondientes simétricos
    Z_reconstructed = zeros(size(Z));
    Z_reconstructed(1:num_coeff) = Z(1:num_coeff);
    Z_reconstructed(end-num_coeff+2:end) = Z(end-num_coeff+2:end);
    z_reconstructed = ifft(Z_reconstructed);
    
    % Graficar el contorno original y el reconstruido
    subplot(1, length(features), k);
    plot(real(z), imag(z), 'b-', 'LineWidth', 1.5); hold on;
    plot(real(z_reconstructed), imag(z_reconstructed), 'r--', 'LineWidth', 1.5);
    legend('Original', 'Reconstruido');
    title(['Objeto ', num2str(k)]);
    axis equal;
    
    % Convertir el contorno en una señal unidimensional para wavelets
    signal = [x; y];
    
    % Aplicar la transformada wavelet continua (CWT)
    [wt, f] = cwt(signal, 'amor'); % Puedes elegir el tipo de wavelet que prefieras
    
    % Guardar las características de la wavelet en la estructura
    wavelet_features(k).Wavelets = wt;
end

hold off;

% Asumimos que ya tienes los descriptores de Fourier y las características de wavelet en las estructuras fd y wavelet_features

% Definir el número máximo de coeficientes de Fourier que se usarán
max_num_coeff = 5; % Puedes ajustar este valor según sea necesario

% Número de objetos
num_objects = length(fd);

% Inicializar matrices para almacenar los espectros de potencia y wavelet
power_spectra = [];
wavelet_spectra = [];

for k = 1:num_objects
    % Obtener el espectro de potencia (magnitud al cuadrado de los coeficientes de Fourier)
    power_spectrum = abs(fd(k).FD(1:max_num_coeff)).^2;
    
    % Si el espectro de potencia tiene menos coeficientes, realizar zero-padding
    if length(power_spectrum) < max_num_coeff
        power_spectrum = [power_spectrum; zeros(max_num_coeff - length(power_spectrum), 1)];
    end
    
    % Guardar el espectro de potencia en la matriz
    power_spectra = [power_spectra; power_spectrum(:)'];
    
    % Extraer características de la wavelet
    wavelet_spectrum = abs(wavelet_features(k).Wavelets).^2;
    
    % Asegurarse de que el wavelet_spectrum tenga una longitud consistente
    wavelet_spectrum = mean(wavelet_spectrum, 2); % Promedio a través de las escalas/frecuencias
    wavelet_spectrum = wavelet_spectrum(1:max_num_coeff); % Truncar o recortar a max_num_coeff
    
    % Si la longitud es menor que max_num_coeff, realizar zero-padding
    if length(wavelet_spectrum) < max_num_coeff
        wavelet_spectrum = [wavelet_spectrum; zeros(max_num_coeff - length(wavelet_spectrum), 1)];
    end
    
    % Guardar el espectro de wavelet en la matriz
    wavelet_spectra = [wavelet_spectra; wavelet_spectrum(:)'];
end

% Aplicar PCA a los espectros de potencia de Fourier y a las características de wavelet
[coeff_fd, score_fd, latent_fd, tsquared_fd, explained_fd] = pca(power_spectra);
[coeff_wavelet, score_wavelet, latent_wavelet, tsquared_wavelet, explained_wavelet] = pca(wavelet_spectra);

% Graficar la variación explicada por cada componente principal para Fourier
figure;
plot(cumsum(explained_fd), '-o', 'LineWidth', 2);
xlabel('Número de Componentes Principales');
ylabel('Varianza Explicada Acumulada (%)');
title('Varianza Explicada por Componentes Principales (Fourier)');
grid on;

% Graficar la variación explicada por cada componente principal para Wavelets
figure;
plot(cumsum(explained_wavelet), '-o', 'LineWidth', 2);
xlabel('Número de Componentes Principales');
ylabel('Varianza Explicada Acumulada (%)');
title('Varianza Explicada por Componentes Principales (Wavelets)');
grid on;

% Opcional: Visualización de los primeros dos componentes principales para Fourier
figure;
scatter(score_fd(:,1), score_fd(:,2));
xlabel('Primer Componente Principal (Fourier)');
ylabel('Segundo Componente Principal (Fourier)');
title('Proyección en los Primeros dos Componentes Principales (Fourier)');
grid on;

% Opcional: Visualización de los primeros dos componentes principales para Wavelets
figure;
scatter(score_wavelet(:,1), score_wavelet(:,2));
xlabel('Primer Componente Principal (Wavelets)');
ylabel('Segundo Componente Principal (Wavelets)');
title('Proyección en los Primeros dos Componentes Principales (Wavelets)');
grid on;
