%% contour analyses from the cells in trackData


pixels_ordered  = image_sort(trackData.Tracks(1).Data.Border{1,1}(:,1), trackData.Tracks(1).Data.Border{1,1}(:,2));
pixels_ordered = pixels_ordered;

filament_shape(pixels_ordered)