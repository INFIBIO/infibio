function create_graph_with_nodes_and_links(brightfieldImage, cellCentroidsFluorescence1, cellCentroidsFluorescence2, folderPath)
% Calculate distances between centroids of two samples
num_centroids1 = size(cellCentroidsFluorescence1, 1);
num_centroids2 = size(cellCentroidsFluorescence2, 1);
distances_between_samples = zeros(num_centroids1, num_centroids2);

% Calculate pairwise distances
for i = 1:num_centroids1
    for j = 1:num_centroids2
        distances_between_samples(i, j) = sqrt(sum((cellCentroidsFluorescence1(i, :) - cellCentroidsFluorescence2(j, :)).^2));
    end
end

% Define a threshold distance
threshold = 50; % You can adjust this threshold as per your requirement

% Create adjacency matrix indicating whether distance between centroids of two samples is below threshold
adjacency_matrix = distances_between_samples <= threshold;

% Initialize empty arrays to store centroids, distances, and connection status
centroids1_all = [];
centroids2_all = [];
all_distances = [];
connection_status = [];
centroid1_indices = [];
centroid2_indices = [];

% Find all centroids and distances with connection status
for i = 1:num_centroids1
    for j = 1:num_centroids2
        centroids1_all = [centroids1_all; cellCentroidsFluorescence1(i, :)];
        centroids2_all = [centroids2_all; cellCentroidsFluorescence2(j, :)];
        all_distances = [all_distances; distances_between_samples(i, j)];
        centroid1_indices = [centroid1_indices; i];
        centroid2_indices = [centroid2_indices; j];
        if adjacency_matrix(i, j)
            connection_status = [connection_status; 'Y']; % Connection exists
        else
            connection_status = [connection_status; 'N']; % No connection
        end
    end
end

% Create a table with all centroids, distances, connection status, and indices
connected_table = table(centroid1_indices, centroid2_indices, centroids1_all, centroids2_all, all_distances, connection_status, ...
    'VariableNames', {'Centroid1_Index', 'Centroid2_Index', 'Centroid1', 'Centroid2', 'Distance', 'ConnectionStatus'});

% Save the table as a CSV file
% Specify the full file path and name
filename_table = fullfile(folderPath, 'connected_centroids_distances.csv');

% Write the table to CSV file
writetable(connected_table, filename_table);

% Create a logical array to identify rows with 'Y' connection status
is_connected = connection_status == 'Y';

% Filter the table to include only connected centroids
connected_table_filtered = connected_table(is_connected, :);

% Save the filtered table as a CSV file
filename_table = fullfile(folderPath, 'connected_centroids_distances_threshold.csv');
writetable(connected_table_filtered, filename_table);

% Define the full path for saving the adjacency matrix inside the folder
filename_adjacency = 'adjacency_matrix.mat';
fullFilePath = fullfile(folderPath, filename_adjacency);

% Save the adjacency matrix as a .mat file
save(fullFilePath, 'adjacency_matrix');

% Initialize graph
G = graph();

% Add nodes
G = addnode(G, num_centroids1 + num_centroids2);

% Add edges with connection status
[edge_rows, edge_cols] = find(adjacency_matrix);
for k = 1:numel(edge_rows)
    % Add edge if connection exists
    G = addedge(G, edge_rows(k), num_centroids1 + edge_cols(k));
end

% Create a figure with larger size
fig = figure('Position', [0, 0, 1200, 900]);
set(fig, 'PaperPositionMode', 'auto');

% Plot the graph with nodes and links
h = plot(G, 'Layout', 'force', 'MarkerSize', 4, 'NodeColor', 'k', 'EdgeAlpha', 1);
title('Graph of centroids with edges indicating distances below threshold of 50');
xlabel('X-coordinate');
ylabel('Y-coordinate');

% Adjust node positions for better visualization and flip vertically
h.XData = [cellCentroidsFluorescence1(:, 1); cellCentroidsFluorescence2(:, 1)];
h.YData = -[cellCentroidsFluorescence1(:, 2); cellCentroidsFluorescence2(:, 2)]; % Flip Y data

% Add numbers to nodes
node_numbers1_str = arrayfun(@num2str, 1:num_centroids1, 'UniformOutput', false);
node_numbers2_str = arrayfun(@num2str, 1:num_centroids2, 'UniformOutput', false);

for i = 1:num_centroids1
    text(cellCentroidsFluorescence1(i, 1) + 12, -cellCentroidsFluorescence1(i, 2), node_numbers1_str{i}, 'Color', [0, 0, 0.5], 'FontSize', 7);
end

for j = 1:num_centroids2
    text(cellCentroidsFluorescence2(j, 1), -cellCentroidsFluorescence2(j, 2) + 30, node_numbers2_str{j}, 'Color', [0, 0.5, 0], 'FontSize', 7);
end

% Specify the file name and path for FIG file
fig_filename = fullfile(folderPath, 'fluorescence_centroids_graph.fig');
saveas(fig, fig_filename);

% Specify the file name and path for TIFF image
filename = fullfile(folderPath, 'fluorescence_centroids_graph.tif');
saveas(fig, filename);

% Close the figure
close(fig);

% Load and display the brightfield image
imshow(brightfieldImage);
hold on; % Hold the current plot

% Plot centroids on the brightfield image
for i = 1:num_centroids1
    text(cellCentroidsFluorescence1(i, 1) + 12, cellCentroidsFluorescence1(i, 2), node_numbers1_str{i}, ...
        'Color', [0, 0, 0.5], 'FontSize', 7, 'FontWeight', 'bold'); % Adjust position and style as needed
end

for j = 1:num_centroids2
    text(cellCentroidsFluorescence2(j, 1), cellCentroidsFluorescence2(j, 2) + 30, node_numbers2_str{j}, ...
        'Color', [0, 0.5, 0], 'FontSize', 7, 'FontWeight', 'bold'); % Adjust position and style as needed
end

% Optionally, save the annotated brightfield image
filename_brightfield_annotated = fullfile(folderPath, 'brightfield_annotated.tif');
filename_brightfield_annotated2 = fullfile(folderPath, 'brightfield_annotated.fig');
saveas(gcf, filename_brightfield_annotated);
saveas(gcf, filename_brightfield_annotated2);
close(gcf);
end