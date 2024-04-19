padded_img = padarray(BW_out, [1, 1]);
[rows, cols] = size(padded_img);
img = padded_img(2:end-1, 2:end-1);
img_north = padded_img(1:end-2, 2:end-1);
img_south = padded_img(3:end, 2:end-1);
img_east = padded_img(2:end-1, 3:end);
img_west = padded_img(2:end-1, 1:end-2);

border = zeros(4, size(padded_img, 1), size(padded_img, 2), 'int32');
border(Directions.NORTH+1, 2:end-1, 2:end-1) = (image == 1) & (padded_img(1:end-2, 2:end-1) == 0);
border(Directions.EAST+1, 2:end-1, 2:end-1) = (image == 1) & (padded_img(2:end-1, 3:end) == 0);
border(Directions.SOUTH+1, 2:end-1, 2:end-1) = (image == 1) & (padded_img(3:end, 2:end-1) == 0);
border(Directions.WEST+1, 2:end-1, 2:end-1) = (image == 1) & (padded_img(2:end-1, 1:end-2) == 0);
adjacent = zeros(4, rows-2, cols-2, 'int32');
adjacent(Directions.NORTH+1, :, :) = max(cat(3,border(Directions.WEST+1, 1:end-2, 2:end-1), ...
    border(Directions.NORTH+1, 2:end-1, 2:end-1), ...
    border(Directions.EAST+1, 1:end-2, 3:end), [], 3);
adjacent(Directions.EAST+1, :, :) = max(cat(3, border(Directions.NORTH+1, 2:end-1, 3:end), ...
    border(Directions.EAST+1, 2:end-1, 2:end-1), ...
    border(Directions.SOUTH+1, 3:end, 3:end)), [], 'all');
adjacent(Directions.SOUTH+1, :, :) = max(cat(3, border(Directions.EAST+1, 3:end, 2:end-1), ...
    border(Directions.SOUTH+1, 2:end-1, 2:end-1), ...
    border(Directions.WEST+1, 3:end, 1:end-2)), [], 'all');
adjacent(Directions.WEST+1, :, :) = max(cat(3, border(Directions.SOUTH+1, 2:end-1, 1:end-2), ...
    border(Directions.WEST+1, 2:end-1, 2:end-1), ...
    border(Directions.NORTH+1, 1:end-2, 1:end-2)), [], 'all');
directions = zeros(int32(Directions.WEST+1), rows, cols, 3, 3, 'int32');
directions(int32(Directions.NORTH+1), :, :, :, :) = repmat([3, -1, 1; 0, 0, 1; 1, 0, 0], [1, 1, 1, 1, 1]);

directions(int32(Directions.EAST+1), :, :, :) = [-1, 1, 1; 0, 1, 0; 1, 0, 0];
directions(int32(Directions.SOUTH+1), :, :, :) = [-1, 1, -1; 0, 0, -1; 1, 0, 0];
directions(int32(Directions.WEST+1), :, :, :) = [-1, -1, -1; 0, -1, 0; -3, 0, 0];
