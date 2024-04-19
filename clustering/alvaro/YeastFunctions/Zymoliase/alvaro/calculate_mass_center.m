function [x_center, y_center] = calculate_mass_center(x_coords, y_coords)
    total_mass = 0;
    x_mass_sum = 0;
    y_mass_sum = 0;

    for i = 1:length(x_coords)
        mass = 1;  % assume unit mass for each point
        total_mass = total_mass + mass;
        x_mass_sum = x_mass_sum + mass * x_coords(i);
        y_mass_sum = y_mass_sum + mass * y_coords(i);
    end

    x_center = x_mass_sum / total_mass;
    y_center = y_mass_sum / total_mass;
end