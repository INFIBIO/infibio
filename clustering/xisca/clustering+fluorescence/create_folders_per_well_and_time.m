function create_folders_per_well_and_time(outdirectoryPath)
    fileList = dir(fullfile(outdirectoryPath, '*.jpg'));
    createdFolders = containers.Map();

    for i = 1:length(fileList)
        currentFilename = fullfile(outdirectoryPath, fileList(i).name);
        image = imread(currentFilename);

        [~, filename, ext] = fileparts(fileList(i).name);
        filenameParts = split(filename, '_');
       
        % Extract the well name and time
        well_name = filenameParts{1};
        time_part = filenameParts{end};
        folder_name = [well_name '_t' time_part];
        
        % Create the output folder path
        outputFolder = fullfile(outdirectoryPath, folder_name);
        if ~isfolder(outputFolder)
            mkdir(outputFolder);
            createdFolders(folder_name) = true;
        end

        if isKey(createdFolders, folder_name)
            movefile(currentFilename, fullfile(outputFolder, fileList(i).name));
        else
            mkdir(outputFolder);
            movefile(currentFilename, fullfile(outputFolder, fileList(i).name));
        end
    end
end
