%% To Do Tracking and Fluorescent Cells Identification
%
% Fluorescent Image Analysis from Raw Images obtained from the microscope.
% Font-Verdera, Francesca. June 2024.

% Define main directory path.
% INPUT: Path of images in .jpg. File format can be easily changed with ImageJ previously.
mainDirectoryPath = ' ';
% Create an output folder (and its path).
outdirectoryPath = setup_directories(mainDirectoryPath);

% Change file names. Check if the script needs to be changed depending on
% the files names when captures were performed. 
change_file_names(outdirectoryPath);

% Crop images (raw images are circular).
reductionFactor = 0.67;
crop_images(mainDirectoryPath, outdirectoryPath, reductionFactor);

% Create folders per well and time (in order to have a single folder for
% each sample, where all the generated plots and results will be).
create_folders_per_well_and_time(outdirectoryPath);

% Get the list of all the paths and folders.
folderList = dir(outdirectoryPath);
folderList = folderList([folderList.isdir]);
folderList = folderList(~ismember({folderList.name}, {'.', '..'}));

% Loop to go through all the folders.
    for folderIndex = 1:length(folderList)
        folderName = folderList(folderIndex).name;
        folderPath = fullfile(outdirectoryPath, folderName);

        disp(['Processing folder: ', folderName]);

        fileList = dir(fullfile(folderPath, '*.jpg'));
        brightfieldImage = [];
        fluorescenceImage1 = [];
        fluorescenceImage2 = [];

        for fileIndex = 1:numel(fileList)
            fileName = fileList(fileIndex).name;
            filePath = fullfile(folderPath, fileName);
            % Assignment of images: brightfield, fluorescence 1 and fluorescence 2.
            % Remind: check the identifiers to match with names!
            if contains(fileName, 'brightfield')
                brightfieldImage = imread(fullfile(folderPath, fileName));
            elseif contains(fileName, 'NBred')
                fluorescenceImage1 = imread(fullfile(folderPath, fileName));
            elseif contains(fileName, 'FDAblue')
                fluorescenceImage2 = imread(fullfile(folderPath, fileName));
            end
        end
        
        % Two options of identification and tracking of cells, with or without assessment of image quality.
        
        % Tracking and fluorescent cells identification.
        %[cellCentroidsBrightfield, cellCentroidsFluorescence1, cellCentroidsFluorescence2, ... 
        %cellPropertiesBrightfield, cellPropertiesFluorescence1, cellPropertiesFluorescence2, ...
        %processedFluorescence1, bwFluorescence11, processedFluorescence2, bwFluorescence22] = ...
        %track_and_identify_cells(brightfieldImage, fluorescenceImage1, fluorescenceImage2, folderPath);

        % Tracking and fluorescent cells identification (includes assessment of image quality).
        [cellCentroidsBrightfield, cellCentroidsFluorescence1, cellCentroidsFluorescence2, ... 
        cellPropertiesBrightfield, cellPropertiesFluorescence1, cellPropertiesFluorescence2, ...
        processedFluorescence1, bwFluorescence11, processedFluorescence2, bwFluorescence22] = ...
        track_and_identify_cells_v2(brightfieldImage, fluorescenceImage1, fluorescenceImage2, folderPath);
        
        % Comparison and cell matching (according fluorescences).
            [matchedCellsFluorescence1, matchedCellsFluorescence2, matchedCellsFluorescence12] = ...
            compare_and_match_cells(cellCentroidsBrightfield, cellCentroidsFluorescence1, cellCentroidsFluorescence2);
            
        % Data analysis and visualization of matched cells (according fluorescences).
            [percentageFluorescent1, percentageFluorescent2, percentageFluorescent12, matchedCellsFluorescence12, numIndividualCellsFluorescence12, numChainedCellsFluorescence12] = ...
                data_analysis(matchedCellsFluorescence1, matchedCellsFluorescence2, matchedCellsFluorescence12, ...
                brightfieldImage, cellPropertiesFluorescence1, cellCentroidsFluorescence1, brightfieldImage, folderPath);

            % Display and save percentages from results of the previous function (data analysis).
            disp(['Number of individual cells exhibiting fluorescence in channels 1 and 2: ', numIndividualCellsFluorescence12]);
            disp(['Number of chained/clustered cells exhibiting fluorescence in channels 1 and 2: ', numChainedCellsFluorescence12]);
            disp(['Percentage of brightfield-visible cells exhibiting fluorescence in channel 1: ', num2str(percentageFluorescent1), '%']);
            disp(['Percentage of brightfield-visible cells exhibiting fluorescence in channel 2: ', num2str(percentageFluorescent2), '%']);
            disp(['Percentage of brightfield-visible cells exhibiting fluorescence in channels 1 and 2: ', num2str(percentageFluorescent12), '%']);
            save(fullfile(folderPath, 'fluorescence_percentages.mat'), 'percentageFluorescent1', 'percentageFluorescent2', 'percentageFluorescent12');
            save(fullfile(folderPath, 'Indi-Clust_numberCells_Fluorescence12.mat'), 'numIndividualCellsFluorescence12', 'numChainedCellsFluorescence12');
        
            % Calculate cell intensities and visualize (optional).
            calculate_and_visualize_intensities(brightfieldImage, cellCentroidsFluorescence1, cellCentroidsFluorescence2, folderPath);
         
            % Color images with identified cells.
            color_images_with_identified_cells(processedFluorescence1, bwFluorescence11, processedFluorescence2, bwFluorescence22, folderPath);
            
            % Create graph with nodes and links, and calculate distances between two connected nodes.
            create_graph_with_nodes_and_links(brightfieldImage, cellCentroidsFluorescence1, cellCentroidsFluorescence2, folderPath);
    end


%% EXTRA: To obtain plots with results of fluorescence from all the samples.
% Plots are saved in mainDirectoryPath.

% Get list of folders (e.g., A1.0_t0, A4.1_t0, etc.)
folderList = dir(outdirectoryPath);
folderList = folderList([folderList.isdir]);
folderList = folderList(~ismember({folderList.name}, {'.', '..'}));

% Initialize arrays to store aggregated results
timePoints = {};
allPercentageFluorescent1 = {};
allPercentageFluorescent2 = {};
allPercentageFluorescent12 = {};
allnumIndividualCellsFluorescence12 = {};
allnumChainedCellsFluorescence12 = {};

% Loop through each folder
for folderIndex = 1:length(folderList)
    folderName = folderList(folderIndex).name;
    folderPath = fullfile(outdirectoryPath, folderName);

    disp(['Processing folder: ', folderName]);

    % Load processed data (assuming you have saved percentages in a mat file)
    load(fullfile(folderPath, 'fluorescence_percentages.mat'), 'percentageFluorescent1', 'percentageFluorescent2', 'percentageFluorescent12');
    load(fullfile(folderPath, 'Indi-Clust_numberCells_Fluorescence12.mat'), 'numIndividualCellsFluorescence12', 'numChainedCellsFluorescence12');
    
    % Extract time point from folder name (e.g., 't0', 't1', ...)
    timePoint = extractTimePoint(folderName); % Implement extractTimePoint based on your naming convention
    
    % Aggregate results by time point
    if ~ismember(timePoint, timePoints)
        timePoints{end+1} = timePoint;
        allPercentageFluorescent1{end+1} = percentageFluorescent1;
        allPercentageFluorescent2{end+1} = percentageFluorescent2;
        allPercentageFluorescent12{end+1} = percentageFluorescent12;
        allnumIndividualCellsFluorescence12 {end+1} = numIndividualCellsFluorescence12;
        allnumChainedCellsFluorescence12 {end+1} = numChainedCellsFluorescence12;
    else
        idx = find(strcmp(timePoints, timePoint));
        allPercentageFluorescent1{idx} = [allPercentageFluorescent1{idx}; percentageFluorescent1];
        allPercentageFluorescent2{idx} = [allPercentageFluorescent2{idx}; percentageFluorescent2];
        allPercentageFluorescent12{idx} = [allPercentageFluorescent12{idx}; percentageFluorescent12];
        allnumIndividualCellsFluorescence12{idx} = [allnumIndividualCellsFluorescence12{idx}; numIndividualCellsFluorescence12];
        allnumChainedCellsFluorescence12{idx} = [allnumChainedCellsFluorescence12{idx}; numChainedCellsFluorescence12];
    end
end

% Calculate mean and standard deviation for each time point
meanPercentageFluorescent1 = cellfun(@mean, allPercentageFluorescent1);
stdPercentageFluorescent1 = cellfun(@std, allPercentageFluorescent1);
meanPercentageFluorescent2 = cellfun(@mean, allPercentageFluorescent2);
stdPercentageFluorescent2 = cellfun(@std, allPercentageFluorescent2);
meanPercentageFluorescent12 = cellfun(@mean, allPercentageFluorescent12);
stdPercentageFluorescent12 = cellfun(@std, allPercentageFluorescent12);

meanNumIndiCells12 = cellfun(@mean, allnumIndividualCellsFluorescence12);
stdNumIndiCells12 = cellfun(@std, allnumIndividualCellsFluorescence12);
meanNumChainCells12 = cellfun(@mean, allnumChainedCellsFluorescence12);
stdNumChainCells12 = cellfun(@std, allnumChainedCellsFluorescence12);

% Plotting
timeValues = convertTimePointsToNumeric(timePoints); % Convert time points to numeric values
figure;
errorbar(timeValues, meanPercentageFluorescent1, stdPercentageFluorescent1, 'ro-', 'LineWidth', 1);
hold on;
errorbar(timeValues, meanPercentageFluorescent2, stdPercentageFluorescent2, 'bs-', 'LineWidth', 1);
errorbar(timeValues, meanPercentageFluorescent12, stdPercentageFluorescent12, 'gd-', 'LineWidth', 1);
xlabel('Time Points');
ylabel('Percentage (%)');
legend('Fluorescence Channel 1', 'Fluorescence Channel 2', 'Both Channels');
title('Mean percentage of fluorescent cells over time');
grid on;

% Save plot
plotFileName = fullfile(mainDirectoryPath, 'mean_fluorescence_percentages_plot.tif');
plotFileName2 = fullfile(mainDirectoryPath, 'mean_fluorescence_percentages_plot.fig');
saveas(gcf, plotFileName);
saveas(gcf, plotFileName2);

% Plotting
timeValues = convertTimePointsToNumeric(timePoints); % Convert time points to numeric values
figure;
errorbar(timeValues, meanNumIndiCells12, stdNumIndiCells12, 'ro-', 'LineWidth', 1);
hold on;
errorbar(timeValues, meanNumChainCells12, stdNumChainCells12, 'bs-', 'LineWidth', 1);
xlabel('Time Points');
ylabel('Number of groups');
legend('Number of Individual Cells', 'Number of Chained or Clustered Cells');
title('Mean number of fluorescent Cells over time');
grid on;

% Save plot
plotFileName = fullfile(mainDirectoryPath, 'mean_fluorescence_indichaincells_plot.tif');
plotFileName2 = fullfile(mainDirectoryPath, 'mean_fluorescence_indichaincells_plot.fig');
saveas(gcf, plotFileName);
saveas(gcf, plotFileName2);
