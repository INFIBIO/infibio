function combinFiles()
    % Get a list of all .mat files in the workspace
    files = dir('*.mat');

    % Initialize an empty cell array to hold the loaded structures
    loadedStructs = cell(1, length(files));

    % Loop over the files
    for i = 1:length(files)
        % Load the current file
        loadedData = load(files(i).name);

        % Get the name of the variable in the file
        varName = fieldnames(loadedData);

        % Add the loaded structure to the cell array
        loadedStructs{i} = loadedData.(varName{1});
    end

    % Concatenate the loaded structures into a single structure array
    combined = vertcat(loadedStructs{:});
end