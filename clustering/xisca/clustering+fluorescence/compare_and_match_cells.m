function [matchedCellsFluorescence1, matchedCellsFluorescence2, matchedCellsFluorescence12] = ...
    compare_and_match_cells(cellCentroidsBrightfield, cellCentroidsFluorescence1, cellCentroidsFluorescence2)

    % Define tolerance for centroid matching
    centroidTolerance = 10; % Adjust as needed based on your images

    matchedCellsFluorescence1 = [];
    matchedCellsFluorescence2 = [];
    matchedCellsFluorescence12 = [];

    for i = 1:size(cellCentroidsBrightfield, 1)
        centroidBrightfield = cellCentroidsBrightfield(i, :);

        % Compare with fluorescence image 1
        for j = 1:size(cellCentroidsFluorescence1, 1)
            centroidFluorescence1 = cellCentroidsFluorescence1(j, :);
            if norm(centroidBrightfield - centroidFluorescence1) <= centroidTolerance
                matchedCellsFluorescence1 = [matchedCellsFluorescence1; centroidBrightfield];
                break;
            end
        end

        % Compare with fluorescence image 2
        for k = 1:size(cellCentroidsFluorescence2, 1)
            centroidFluorescence2 = cellCentroidsFluorescence2(k, :);
            if norm(centroidBrightfield - centroidFluorescence2) <= centroidTolerance
                matchedCellsFluorescence2 = [matchedCellsFluorescence2; centroidBrightfield];
                break;
            end
        end

        % Compare fluorescence 1 and 2
        for l = 1:size(cellCentroidsFluorescence2, 1)
            centroidFluorescence2 = cellCentroidsFluorescence2(l, :);
            if norm(centroidFluorescence1 - centroidFluorescence2) <= centroidTolerance
                matchedCellsFluorescence12 = [matchedCellsFluorescence12; centroidFluorescence1];
                break;
            end
        end
    end
end