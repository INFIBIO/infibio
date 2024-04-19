function [x_c, y_c, theta, r, y_rel, x_rel] = angulos(x, y, x_center, y_center)
    x_a = x;
    y_a = y;
    x_c = x_center * ones(size(x));
    y_c = y_center * ones(size(y));
    x_rel = x_a - x_c;
    y_rel = y_a - y_c;
    r = sqrt(x_rel.^2 + y_rel.^2); % distancia de cada punto al centro de masas
    theta = atan2(y_rel, x_rel);
end