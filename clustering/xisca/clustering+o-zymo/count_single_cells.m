function countsTable = count_single_cells(table, value, path)
    % Check if the 'results' folder exists, if not, create it
    results_folder = fullfile(path, 'results');
    if ~exist(results_folder, 'dir')
        mkdir(results_folder);
    end
    
    % Create a mapping for well names to numbers
    wellMap = containers.Map('KeyType', 'char', 'ValueType', 'int32');
    wellCounter = 1;
    newWellColumn = zeros(height(table), 1);

    for idx = 1:height(table)
        wellName = table.Well{idx};
        if ~isKey(wellMap, wellName)
            wellMap(wellName) = wellCounter;
            wellCounter = wellCounter + 1;
        end
        newWellColumn(idx) = wellMap(wellName);
    end

    % Replace the well column with the new numeric values
    table.Well = newWellColumn;

    % Get unique values of other columns
    uniqueT = unique(table.Time);
    uniqueR = unique(table.Replica);
    uniqueZ = unique(table.Zymolyase);
    uniqueW = unique(table.Well);
    uniqueC = unique(table.Concentration);

 % Initialize empty array of structs
    countsTable = struct('count', [],'Time', [], 'Well', [], 'Replica', [], 'Zymolyase', [], 'Concentration', []);

    % Loop and populate the counts array
    for k = 1:length(uniqueZ)
        for i = 1:length(uniqueT)
            for h = 1:length(uniqueW)
                 for j = 1:length(uniqueR)
                     for e = 1:length(uniqueC)
                    % Filter the table based on current 'Time', 'Well', 'Zymolyase' and 'Replica' values
                    filteredTable = table(table.Time == uniqueT(i) & table.Well == uniqueW(h) & table.Replica == uniqueR(j) & table.Zymolyase == uniqueZ(k) & table.Concentration == uniqueC(e), :);
                    
                    % Count occurrences of the value in the filtered column
                    count = sum(filteredTable.NormalizedArea == value);
                    
                    % Only append a new struct element if count is non-zero
                    if count > 0
                        % Create a new struct element
                        newRow = struct('count', count, 'Time', uniqueT(i), 'Well', uniqueW(h), 'Replica', uniqueR(j), 'Zymolyase', uniqueZ(k), 'Concentration', uniqueC(e));
                        
                        % Append the new struct to countsTable
                        countsTable = [countsTable; newRow];
                    end
                end
            end
        end
    end

    % Convert struct to table
    csvTable = struct2table(countsTable);

    % Create the filename string
    filename = fullfile(results_folder, ['countsTable_', num2str(value), '.csv']);
    
    % Save the table as a CSV file
    writetable(csvTable, filename);
    
    % Read the table from the CSV file
    csvTable = readtable(filename);
    
    % Group the data by 'Time', 'Zymolyase', and 'Replica', and calculate mean
    % and standard deviation of count
    groupedData = groupsummary(csvTable, {'Time', 'Zymolyase', 'Concentration'}, {'mean', 'std'}, 'count');
    
    % Display or save the results
    disp(groupedData);
    
    % Create the filename string
    filename = fullfile(results_folder, ['mean_std_counts_per_time_and_zymolyase_', num2str(value), '.csv']);
    
    % Save the table as a CSV file
    writetable(groupedData, filename);
end
