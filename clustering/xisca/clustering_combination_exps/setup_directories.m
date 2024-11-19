function outdirectoryPath = setup_directories(directoryPath)
    outdirectoryPath = fullfile(directoryPath, 'cropped_images');
    if ~isfolder(outdirectoryPath)
        mkdir(outdirectoryPath);
    end
end