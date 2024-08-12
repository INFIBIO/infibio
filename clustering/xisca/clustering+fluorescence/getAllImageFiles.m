% Function to recursively get all image files in the folder
function fileList = getAllImageFiles(dirName)
    extensions = {'*.jpg', '*.jpeg', '*.png', '*.tif', '*.bmp'};
    fileList = {};
    for k = 1:length(extensions)
        dirData = dir(fullfile(dirName, '**', extensions{k}));
        for i = 1:length(dirData)
            fileList{end+1} = fullfile(dirData(i).folder, dirData(i).name);
        end
    end
end