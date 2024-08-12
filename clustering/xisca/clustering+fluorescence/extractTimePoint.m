% Function to extract time point from folder name
function timePoint = extractTimePoint(folderName)
    % Implement your logic to extract time point from folder name
    % Example: folderName = 'A1.0_t0', extract 't0'
    splitName = strsplit(folderName, '_');
    timePoint = splitName{end}; % Assuming last part is the time point
end