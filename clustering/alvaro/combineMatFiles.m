function combinedData = combineMatFiles(folderPath)
    % Obtiene la lista de archivos .mat en el directorio y sus subcarpeta    
    archivosMat = dir(fullfile(folderPath, '**', '*.mat'));
    
    % Inicializa una estructura de datos vacía
    combinedData = struct('Area', [], 'Centroid', [],  'Perimeter', [], 'Circularity', [], 'Eccentricity', [], 'Solidity', [], 'MinorAxisLength', [], 'MajorAxisLength', [], 'Concentration', [], 'Time', [], 'Enumeration', [],'pocillo', [], 'replica',[], 'areaNorm', []);
    % Itera sobre cada archivo .mat
    for i = 1:numel(archivosMat)
        % Construye la ruta completa del archivo
        rutaArchivo = fullfile(archivosMat(i).folder, archivosMat(i).name);
        
        % Carga los datos del archivo .mat
        load(rutaArchivo);
        
        % Extrae los campos necesarios de los datos cargados
         % Asegúrate de ajustar el nombre de la variable según lo que esté en tus archivos .mat
        
        % Comprueba si hay más de una fila en los datos
        if size(propsbw_cleaned, 2) > 1
            % Extrae el nombre del archivo
            nombreArchivo = archivosMat(i).name;
            
           
            % Extrae el pocillo
            pocillo = regexp(nombreArchivo, '([A-Z]+[0-9]+)', 'match', 'once');
    
            
            replica = regexp(nombreArchivo, '^[A-Z]+[0-9]+\.([0-9]+)_.*', 'tokens', 'once');
            replica = str2double(replica{1});
            
            % Extraer el segundo número después del primer _
            MyMatrix = sort(vertcat(propsbw_cleaned.Area));
            areaNorm = round(vertcat(propsbw_cleaned.Area) ./ mean(quantile(MyMatrix, [0.25])));
            for j = 1:length(propsbw_cleaned)
                propsbw_cleaned(j).pocillo = [];
                propsbw_cleaned(j).replica = [];
                propsbw_cleaned(j).areaNorm = [];
               
            end
            % Agrega los campos a la estructura de datos
            for k = 1:length(propsbw_cleaned)
                propsbw_cleaned(k).pocillo = pocillo;
                propsbw_cleaned(k).replica = replica;
                propsbw_cleaned(k).areaNorm = areaNorm(k);
            end
            % Combina los datos en la estructura de datos combinada
            for l = 1:length(propsbw_cleaned)
                combinedData(end+1) = propsbw_cleaned(l);
            end
            
        end
    end
combinedData(1) = [];