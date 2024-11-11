function [BWimg, maskedImage] = segmentation(img, python_path, yolo_path, predict_seg_script, weights_seg)

% function to apply the classification model of yolov5 to distinguish
% between haploid/diploid, sporulated, else. 
% INPUT:
% img: raw image.
% props: properties of the image from regionprops function with at least
% the BoundingBox variable as struct.
% python_path: path to python.exe in yolov5 conda environment.
% yolo_path: path/to/yolov5 cloned from github repository.
% weights: path to best.pt.
%
% OUTPUT:
% features: same properties struct with the DetecteClass variable:
% 1 = haploid/diploid; 2 = sporulated; 3 = else.
%
% HISTORY:
% 18 June, 2024. AR. Created.
% 04 July, 2024. AR. Modified. Added python_path, yolo_path,
% predict_script, weights as arguments to the function.
%Classification

img = imadjust(img);
temp_img_path = fullfile(tempdir, 'temp_image.png');
imwrite(img, temp_img_path);

pyenv('Version', python_path);
img_size = 640;
img_path = strrep(temp_img_path, '/', '//');
% Construct the Python command
python_cmd = sprintf('%s %s --weights %s --img %d --source %s --save-txt --hide-labels --hide-conf ', python_path, predict_seg_script, weights_seg, img_size,  img_path);

% Execute the Python command
status = system(python_cmd);
% Find the latest exp folder in the runs/detect directory
detect_dir = fullfile(yolo_path,'\runs\predict-seg');
exp_dirs = dir(fullfile(detect_dir, 'exp*'));
[~, idx] = max([exp_dirs.datenum]);
latest_exp_dir = fullfile(detect_dir, exp_dirs(idx).name);
% Load the detected classes from the .mat file
detected_seg_file = fullfile(latest_exp_dir, 'labels\', 'temp_image.txt');
fileID = fopen(detected_seg_file, 'r');
data = textscan(fileID, '%s', 'Delimiter', '\n');
fclose(fileID);
% Inicializar la imagen binaria
BWimg = false(img_size, img_size);

% Recorrer cada línea de datos
for i = 1:numel(data{1})
    % Extraer las coordenadas de la línea actual
    coords_str = strsplit(data{1}{i});
    coords = str2double(coords_str);
    
    % Verificar si la conversión a double fue exitosa
    if any(isnan(coords))
        warning('Algunas coordenadas no se pudieron convertir a números en la línea %d', i);
        continue;
    end
    
    % Ignorar el primer número que es la clase
    coords = coords(2:end);
    
    % Convertir coordenadas normalizadas a píxeles
    x_coords = coords(1:2:end) * img_size;   % Coordenadas x
    y_coords = coords(2:2:end) * img_size;  % Coordenadas y
    
    % Crear un polígono a partir de las coordenadas
    mask = poly2mask(x_coords, y_coords, img_size, img_size);
    
    % Combinar la máscara con la imagen binaria
    BWimg = BWimg | mask;
    
end
% Create masked image.
maskedImage = img;
maskedImage(~BWimg) = 0;
end



