% Definir la carpeta de origen
source_folder = 'C:\Users\uib\Downloads\cropped_img\Nueva carpeta';

% Obtener la lista de archivos PNG en la carpeta
image_files = dir(fullfile(source_folder, '*.png'));

% Recorrer cada archivo de imagen en la carpeta
for k = 1:length(image_files)
    % Leer la imagen
    file_path = fullfile(source_folder, image_files(k).name);
    img = imread(file_path);
    
    % Aplicar imadjust a la imagen
    adjusted_img = imadjust(img);
    
    % Guardar la imagen ajustada, reemplazando la original
    imwrite(adjusted_img, file_path);
end


% Obtener la lista de archivos PNG en la carpeta
image_files = dir(fullfile(source_folder, '*.png'));

% Recorrer cada archivo de imagen en la carpeta
for k = 1:length(image_files)
    % Leer la imagen
    file_path = fullfile(source_folder, image_files(k).name);
    img = imread(file_path);
    
    % Aplicar imadjust a la imagen
    adjusted_img = imadjust(img);
    
    % Guardar la imagen ajustada, reemplazando la original
    imwrite(adjusted_img, file_path);
end
