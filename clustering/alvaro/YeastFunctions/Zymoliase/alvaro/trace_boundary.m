
ruta_imagen = 'C:/Users/alvar/Desktop/InFiBio/infibio-main/infibio-main/YeastFunctions/Zymoliase/Matlab/alvaro/tiff/binarized_img/E1.0_0093.tif';
image = imread(ruta_imagen);
bw = imclose(image > 0, strel('square', 3));
padded_img = padarray(bw, [1, 1]);

[rows, cols] = size(padded_img);
border = zeros(4, rows, cols, 'int32');

border(Directions.NORTH+1, 2:end-1, 2:end-1) = (bw == 1) & (padded_img(1:end-2, 2:end-1) == 0);
border(Directions.EAST+1, 2:end-1, 2:end-1) = (bw == 1) & (padded_img(2:end-1, 3:end) == 0);
border(Directions.SOUTH+1, 2:end-1, 2:end-1) = (bw == 1) & (padded_img(3:end, 2:end-1) == 0);
border(Directions.WEST+1, 2:end-1, 2:end-1) = (bw == 1) & (padded_img(2:end-1, 1:end-2) == 0);

adjacent = zeros(4, rows-2, cols-2, 'int32');
adjacent(Directions.NORTH+1, :, :) = max(cat(1, border(Directions.WEST+1, 1:end-2, 2:end-1), ...
    border(Directions.NORTH+1, 2:end-1, 2:end-1), ...
    border(Directions.EAST+1, 2:end-1, 3:end)), [], 1);
adjacent(Directions.EAST+1, :, :) = max(cat(1, border(Directions.NORTH+1, 2:end-1, 3:end), ...
    border(Directions.EAST+1, 2:end-1, 2:end-1), ...
    border(Directions.SOUTH+1, 3:end, 2:end-1)), [], 1);
adjacent(Directions.SOUTH+1, :, :) = max(cat(1, border(Directions.EAST+1, 3:end, 2:end-1), ...
    border(Directions.SOUTH+1, 2:end-1, 2:end-1), ...
    border(Directions.WEST+1, 2:end-1, 1:end-2)), [], 1);
adjacent(Directions.WEST+1, :, :) = max(cat(1, border(Directions.SOUTH+1, 2:end-1, 1:end-2), ...
    border(Directions.WEST+1, 2:end-1, 2:end-1), ...
    border(Directions.NORTH+1, 1:end-2, 2:end-1)), [], 1);

directions = zeros(int32(Directions.WEST+1), size(border(Directions.NORTH+1, 2:end-1, 2:end-1), 2), size(border(Directions.NORTH+1, 2:end-1, 2:end-1), 3), 3, 3, 'int32');
% Obtener las dimensiones adecuadas
[~, rows, cols, ~] = size(directions);

% Crear una matriz con las dimensiones correctas y asignar valores
values = repmat([3, -1, 1; 0, 0, 1; 1, 0, 0], [1, 1, rows, cols]);
values = permute(values, [5, 3, 4, 2, 1]); % Reordenar las dimensiones
directions(int32(Directions.NORTH+1), :, :, :,:) = values;
values = repmat([-1, 1, 1; 0, 1, 0; 1, 0, 0], [1, 1, rows, cols]);
values = permute(values, [5, 3, 4, 2, 1]); % Reordenar las dimensiones
directions(int32(Directions.EAST+1), :, :, :, :) = values;
values = repmat([-1, 1, -1; 0, 0, -1; 1, 0, 0], [1, 1, rows, cols]);
values = permute(values, [5, 3, 4, 2, 1]); % Reordenar las dimensiones
directions(int32(Directions.SOUTH+1), :, :, :, :) = values;
values = repmat([-1, -1, -1; 0, -1, 0; -3, 0, 0], [1, 1, rows, cols]);
values = permute(values, [5, 3, 4, 2, 1]); % Reordenar las dimensiones
directions(int32(Directions.WEST+1), :, :, :, :) = values;

% Obtener las dimensiones de directions y adjacent
[numDirs, numRows, numCols, ~, ~] = size(directions);

% Crear índices para las dimensiones
indDirs = ones(numDirs, 1, 1); % Se mantiene igual
indRows = repmat(reshape(1:numRows, [1, numRows]), [1, 1]);
indCols = repmat(reshape(1:numCols, [1, 1, numCols]), [1, 1, 1]);

% Realizar la operación de indexación
proceding_edge = directions(indDirs, indRows, indCols, :, :) .* adjacent;


% Crear una copia de la matriz border excluyendo la primera fila y la primera columna
unprocessed_border = border(:, 2:end-1, 2:end-1);

% Crear una lista vacía para almacenar los bordes encontrados
borders = cell(0);

% Obtener las coordenadas de los elementos no cero en unprocessed_border
% Obtener las coordenadas de los elementos no cero en unprocessed_border
[rows, cols, depths] = ind2sub(size(unprocessed_border), find(unprocessed_border ~= 0));

% Iterar sobre las coordenadas
for k = 1:numel(rows)
    start_pos = [rows(k), cols(k), depths(k)];
    
    % Verificar si el valor en unprocessed_border en las coordenadas actuales es cero
    % Verificar si algún valor de start_pos es menor o igual a cero
    if any(start_pos <= 0)
        continue;  % Saltar al siguiente bucle si alguno es menor o igual a cero
    end

    
    % Obtener el índice actual en la lista de bordes borders
    idx = length(borders) + 1;
    
    % Agregar una nueva lista vacía al final de la lista borders
    borders{idx} = {};
    
    % Convertir las coordenadas del punto de inicio a un array de tipo int32
    start_arr = int32(start_pos);
    
    % Inicializar la variable current_pos con las coordenadas del punto de inicio
    current_pos = start_arr;
    disp(current_pos)

    % Iniciar un bucle while que continuará hasta que se complete un ciclo completo alrededor del borde
    while true
        try
            % Actualizar el valor en unprocessed_border en la posición actual a cero
            unprocessed_border(current_pos(1), current_pos(2), current_pos(3)) = 0;
             % Agregar la coordenada actual al borde actual en la lista borders
            borders{idx} = [borders{idx}, current_pos(1:3)];
            
            % Actualizar current_pos sumando el desplazamiento determinado por proceding_edge en la posición actual
            current_pos = current_pos + proceding_edge(current_pos(1), current_pos(2), current_pos(3),:,:);
            
            % Verificar si se ha completado un ciclo completo alrededor del borde
                if isequal(current_pos, start_pos)
                    break;
                end
            catch
            % Si se produce un error al intentar actualizar unprocessed_border, salta al siguiente bucle
            break;
        end
    
        
       
    end
end


% match np.nonzero style output
border_pos = cell(0, 1);
for i = 1:length(borders)
    border_pos{i} = borders{i}' * pixel_size;
end

