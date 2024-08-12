function combinedData = combineMatFiles(folderPath, Zymolyase, Velocity, Temperature)
    % Get the list of .mat files in the directory and its subfolders
    matFiles = dir(fullfile(folderPath, '**', '*.mat'));
    
    % Initialize an empty data structure
    combinedData = struct('Area', [], 'Centroid', [],  'Perimeter', [], ...
        'Circularity', [], 'Eccentricity', [], 'Solidity', [], ...
        'MinorAxisLength', [], 'MajorAxisLength', [], 'Concentration', [], ...
        'Time', [], 'Enumeration', [], 'Well', [], 'Replica', [], ...
        'NormalizedArea', [], 'Zymolyase', [], 'Velocity', [], ...
        'Temperature', []);
    
    % Iterate over each .mat file
    for i = 1:numel(matFiles)
        % Construct the full path of the file
        filePath = fullfile(matFiles(i).folder, matFiles(i).name);
        
        % Load data from the .mat file
        load(filePath);
        
        % Extract the necessary fields from the loaded data
        % Make sure to adjust the variable name based on what's in your .mat files
        
        % Check if there is more than one row in the data
        if size(propsbw_cleaned, 2) > 1
            % Extract the file name
            fileName = matFiles(i).name;
            
            % Extract the well
            well = regexp(fileName, '([A-Z]+[0-9]+)', 'match', 'once');
    
            % Extract the replicate
            replicate = regexp(fileName, '^[A-Z]+[0-9]+\.([0-9]+)_.*', 'tokens', 'once');
            replicate = str2double(replicate{1});
            
            % Extract the second number after the first _
            MyMatrix = sort(vertcat(propsbw_cleaned.Area));
            normalizedArea = round(vertcat(propsbw_cleaned.Area) ./ mean(quantile(MyMatrix, [0.25])));
            for j = 1:length(propsbw_cleaned)
                propsbw_cleaned(j).Well = [];
                propsbw_cleaned(j).Replica = [];
                propsbw_cleaned(j).NormalizedArea = [];
                propsbw_cleaned(j).Zymolyase = [];
                propsbw_cleaned(j).Velocity = [];
                propsbw_cleaned(j).Temperature = [];
            end
            % Add fields to the data structure
            for k = 1:length(propsbw_cleaned)
                propsbw_cleaned(k).Well = well;
                propsbw_cleaned(k).Replica = replicate;
                propsbw_cleaned(k).Zymolyase = Zymolyase;
                propsbw_cleaned(k).Velocity = Velocity;
                propsbw_cleaned(k).Temperature = Temperature;
                % Change values in NormalizedArea
                if normalizedArea(k) > 6
                    % Since it's difficult to distinguish the number of
                    % cells in big clusters, all clusters above 6 will be
                    % considered as >6 (this will be evident in the plots?
                    propsbw_cleaned(k).NormalizedArea = 7;
                else
                    propsbw_cleaned(k).NormalizedArea = normalizedArea(k);
                end
            end
            % Combine the data into the combined data structure
            for l = 1:length(propsbw_cleaned)
                combinedData(end+1) = propsbw_cleaned(l);
            end
        end
    end
combinedData(1) = [];
combinedData = struct2table(combinedData);
end