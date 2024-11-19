function combinedData = combineMatFiles(folderPath, Concentration, Zymolyase, Velocity, Temperature)
    % Get the list of .mat files in the directory and its subfolders
    matFiles = dir(fullfile(folderPath, '**', '*.mat'));
    
    % Initialize an empty table
    combinedData = table();  % Initialize as an empty table
    
    % Iterate over each .mat file
    for i = 1:numel(matFiles)
        % Construct the full path of the file
        filePath = fullfile(matFiles(i).folder, matFiles(i).name);
        
        % Load data from the .mat file
        load(filePath);
        
        % Check if there is more than one row in the data
        if size(propsbw_cleaned, 2) > 1
            % Extract the file name
            fileName = matFiles(i).name;
            
            % Extract the well and replicate
            well = regexp(fileName, '([A-Z]+[0-9]+)', 'match', 'once');
            replicate = regexp(fileName, '^[A-Z]+[0-9]+\.([0-9]+)_.*', 'tokens', 'once');
            replicate = str2double(replicate{1});
            
            % Calculate normalizedArea
            MyMatrix = sort(vertcat(propsbw_cleaned.Area));
            normalizedArea = round(vertcat(propsbw_cleaned.Area) ./ mean(quantile(MyMatrix, 0.25)));
            
            % Add fields to each element in propsbw_cleaned
            for k = 1:length(propsbw_cleaned)
                propsbw_cleaned(k).Well = well;
                propsbw_cleaned(k).Replica = replicate;
                propsbw_cleaned(k).Zymolyase = Zymolyase;
                propsbw_cleaned(k).Velocity = Velocity;
                propsbw_cleaned(k).Temperature = Temperature;
                propsbw_cleaned(k).Concentration = Concentration;
                
                % Handle NormalizedArea
                if normalizedArea(k) > 6
                    propsbw_cleaned(k).NormalizedArea = 7;
                else
                    propsbw_cleaned(k).NormalizedArea = normalizedArea(k);
                end
            end
            
            % Convert propsbw_cleaned to a table
            propsbw_cleaned_table = struct2table(propsbw_cleaned);
            
            % Combine the data into the combined data table
            combinedData = [combinedData; propsbw_cleaned_table];
            
        end
    end
end

