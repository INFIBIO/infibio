% Function to convert time points to numeric values (if needed)
function timeValues = convertTimePointsToNumeric(timePoints)
    % Implement your logic to convert time points to numeric values
    % Example: 't0' -> 0, 't1' -> 1, etc.
    % Dummy implementation:
    timeValues = zeros(size(timePoints));
    for i = 1:length(timePoints)
        timeValues(i) = str2double(timePoints{i}(2:end)); % Convert 't0' to 0
    end
end