function plots_x(df, path_save)

    if nargin < 2
        path_save = '';
    end

    clean_data = df(~isnan(df.Time), :);
    unique_times = unique(clean_data.Time);
    unique_zym = unique(clean_data.Zymolyase);
    unique_conc = unique(clean_data.Concentration);
    unique_areas = unique(clean_data.NormalizedArea);

    subfolder = 'plots';
    if ~exist(fullfile(path_save, subfolder), 'dir')
        mkdir(fullfile(path_save, subfolder));
    end

    % Calculate probability and standard deviation
    probability = table(); % Initialize empty table

    for i = 1:length(unique_times)
        current_time_data = clean_data(clean_data.Time == unique_times(i), :);

        for k = 1:length(unique_zym)
            for c = 1:length(unique_conc)
                current_zym_data = current_time_data(current_time_data.Zymolyase == unique_zym(k) & current_time_data.Concentration == unique_conc(c), :);
                total_area = sum(current_zym_data.NormalizedArea);

                for j = 1:length(unique_areas)
                    filtered_data = current_zym_data(current_zym_data.NormalizedArea == unique_areas(j), :);
                    sum_area = sum(filtered_data.NormalizedArea);

                    if total_area > 0
                        new_row = table();
                        new_row.time = unique_times(i);
                        new_row.zymolyase = unique_zym(k);
                        new_row.concentration = unique_conc(c);
                        new_row.area = unique_areas(j);
                        new_row.probability = sum_area / total_area;
                        new_row.positive_sd = sqrt((sum_area / total_area) * (1 - sum_area / total_area) / sum_area);

                        probability = [probability; new_row]; % Append row to probability table
                    end
                end
            end
        end
    end

    % Plot settings
    blue_colors = flipud([linspace(0.3, 0, length(unique_times))', linspace(0.5, 0, length(unique_times))', linspace(1, 0, length(unique_times))']);
    orange_colors = flipud([linspace(1, 1, length(unique_times))', linspace(0.5, 0.3, length(unique_times))', linspace(0, 0, length(unique_times))']);
    colors = lines(length(unique_zym) * length(unique_conc)); % Blue for zymolyase 0, Orange for zymolyase 0.1

    % Plot for each zymolyase concentration and concentration
    for i = 1:length(unique_zym)
        for c = 1:length(unique_conc)
            figure('Position', [100, 100, 1200, 800]);
            num_subplots = length(unique_times);
            num_cols = ceil(sqrt(num_subplots));
            num_rows = ceil(num_subplots / num_cols);

            current_zym_data = probability(probability.zymolyase == unique_zym(i) & probability.concentration == unique_conc(c), :);
            for j = 1:length(unique_times)
                subplot(num_rows, num_cols, j);
                hold on;

                current_time_data = current_zym_data(current_zym_data.time == unique_times(j), :);

                if ~isempty(current_time_data)
                    log_probability = current_time_data.probability;
                    log_positive_sd = current_time_data.positive_sd;

                    errorbar(current_time_data.area, log_probability, log_positive_sd, 'o');
                    semilogy(current_time_data.area, log_probability, 'o-');

                    title(['Time ' int2str(unique_times(j))]);
                    xlabel('Number of Cells');
                    ylabel('Probability (Semilog)');
                end
                hold off;
            end

            sgtitle(['Probability of Each Number of Cells for ' num2str(unique_zym(i)) ' mg/mL Zymolyase, Concentration ' num2str(unique_conc(c))]);

            % Save the plot
            save_plot(path_save, subfolder, sprintf('log_plot_probabilities_%d_%d', unique_zym(i), unique_conc(c)));
        end
    end

    % Combined plot for all zymolyase concentrations and concentrations
    plot_combined(probability, unique_zym, unique_conc, unique_times, path_save, subfolder);
    plot_combined_cells(probability, unique_zym, unique_conc, unique_areas, path_save, subfolder);
end

function save_plot(path_save, subfolder, filename)
    file_path = fullfile(path_save, subfolder, [filename '.tif']);
    file_path2 = fullfile(path_save, subfolder, [filename '.fig']);
    saveas(gcf, file_path);
    saveas(gcf, file_path2);
    close(gcf);
end
function plot_combined(probability, unique_zym, unique_conc, unique_times, path_save, subfolder)
    figure('Position', [100, 100, 1200, 800]);

    % Asignar un color único a cada combinación de unique_zym y unique_conc
    num_combinations = length(unique_zym) * length(unique_conc);
    colors = lines(num_combinations); 

    % Definir los símbolos de marcador disponibles
    available_markers = {'o', '+', '*', 's', 'd', '^', 'v', '>', '<', 'p', 'h', 'x', '|', '_'};
    num_markers = length(available_markers);

    % Generar colores adicionales si es necesario
    extra_colors_needed = length(unique_times) - num_combinations;
    if extra_colors_needed > 0
        extra_colors = hsv(extra_colors_needed); % Generar colores adicionales
        colors = [colors; extra_colors]; % Ampliar la paleta de colores
    end

    % Generar colores adicionales para reciclaje
    if length(unique_times) > size(colors, 1)
        num_additional_colors = length(unique_times) - size(colors, 1);
        additional_colors = hsv(num_additional_colors);
        colors = [colors; additional_colors];
    end
    
    % Definir los estilos de línea
    line_styles = {'-', '--', ':', '-.'};
    num_line_styles = length(line_styles);

    hold on;

    legend_entries = {};
    legend_index = 1;
    handles = [];

    % Iterar sobre las combinaciones únicas de zymolyase y concentración
    for i = 1:length(unique_zym)
        for c = 1:length(unique_conc)
            current_zym_data = probability(probability.zymolyase == unique_zym(i) & probability.concentration == unique_conc(c), :);

            for j = 1:length(unique_times)
                current_time_data = current_zym_data(current_zym_data.time == unique_times(j), :);

                if ~isempty(current_time_data)
                    log_probability = current_time_data.probability;
                    log_positive_sd = current_time_data.positive_sd;

                    % Asignar un color único a cada combinación de zymolyase, concentración y tiempo
                    color_index = (i - 1) * length(unique_conc) + c;
                    current_color = colors(mod(color_index-1, size(colors, 1)) + 1, :);

                    % Obtener el símbolo de marcador correspondiente al tiempo
                    time_marker_index = mod(j-1, num_markers) + 1;
                    time_marker = available_markers{time_marker_index};

                    % Alternar estilos de línea si hay más combinaciones
                    line_style = line_styles{mod(j-1, num_line_styles) + 1};

                    % Cambiar color del marcador al reasignar
                    marker_color = colors(mod(color_index + j - 1, size(colors, 1)) + 1, :);

                    % Graficar los datos
                    h = plot(current_time_data.area, log_probability, 'LineStyle', line_style, ...
                        'Marker', time_marker, 'Color', current_color, ...
                        'MarkerFaceColor', marker_color);
                    errorbar(current_time_data.area, log_probability, log_positive_sd, 'LineStyle', 'none', ...
                        'Marker', time_marker, 'Color', current_color, ...
                        'MarkerFaceColor', marker_color);

                    handles = [handles; h];
                    legend_entries{legend_index} = ['Zymolyase ' num2str(unique_zym(i)) ' mg/mL, Concentration ' num2str(unique_conc(c)) ', Time ' num2str(unique_times(j))];
                    legend_index = legend_index + 1;
                end
            end
        end
    end

    xlabel('Number of Cells');
    ylabel('Probability (Semilog)');
    title('Probability of Each Number of Cells for Different Zymolyase Concentrations, Concentrations and Times');
    legend(handles, legend_entries, 'Location', 'southeastoutside');

    save_plot(path_save, subfolder, 'log_plot_probabilities_all_zymolyase');
end
function plot_combined_cells(probability, unique_zym, unique_conc, unique_areas, path_save, subfolder)
    markers_0 = {'o', 's', '^', 'd', 'v', '>', '<'};
    markers_0_1 = {'x', '*', '.', 's', 'd', '^', 'v'};
    colors = lines(length(unique_zym) * length(unique_conc));
    
    num_areas = length(unique_areas);
    num_zym = length(unique_zym);
    num_conc = length(unique_conc);

    % Crear una figura con un layout en mosaico
    figure('Position', [100, 100, 1400, 800]);
    tcl = tiledlayout(ceil(num_areas / 2), 2, 'TileSpacing', 'compact', 'Padding', 'compact');
    
    % Inicializar entradas de leyenda
    legend_entries = {};
    legend_handles = []; % Guardar los handles de las líneas para la leyenda

    % Iterar sobre cada área única para crear subplots
    for j = 1:num_areas
        nexttile(tcl); % Crear el siguiente subplot en la cuadrícula

        hold on;

        % Iterar sobre los diferentes zymolyases y concentraciones
        for k = 1:num_zym
            for c = 1:num_conc
                % Filtrar los datos actuales
                current_zym_data = probability(probability.zymolyase == unique_zym(k) & ...
                                               probability.concentration == unique_conc(c) & ...
                                               probability.area == unique_areas(j), :);
        
                if ~isempty(current_zym_data)
                    log_probability = current_zym_data.probability;
                    log_positive_sd = current_zym_data.positive_sd;
        
                    % Calcular el índice de color
                    color_index = (k - 1) * num_conc + c;
                    current_color = colors(color_index, :);
        
                    % Determinar el marcador adecuado
                    if unique_zym(k) == 0
                        current_marker = markers_0{c};
                    else
                        current_marker = markers_0_1{c};
                    end
        
                    % Añadir las barras de error
                    h = errorbar(current_zym_data.time, log_probability, log_positive_sd, 'LineStyle', '-', ...
                        'Marker', current_marker, 'Color', current_color, ...
                        'MarkerFaceColor', current_color);
                    
                    % Guardar el handle y la entrada de leyenda
                    if j == 1 % Solo para el primer subplot para evitar duplicados
                        legend_handles(end+1) = h; % Guardar el handle de la línea
                        legend_entries{end+1} = sprintf('Zymolyase %d mg/mL, Concentration %d', ...
                                                        unique_zym(k), unique_conc(c));
                    end
                end
            end
        end
        
        % Configurar los ejes y título del subplot
        xlabel('Time');
        ylabel('Probability');
        title(sprintf('Area %d', unique_areas(j)));
        ylim([0, 1]); % Configurar el límite del eje y        
    end
    
    % Crear la leyenda global utilizando los handles y entradas recogidos
    hL = legend(legend_handles, legend_entries);
 % Ajustar el tamaño de la leyenda
    hL.FontSize = 6; % Reducir el tamaño de la fuente
    hL.ItemTokenSize = [8, 8]; % Reducir el tamaño de los iconos

    % Posicionar la leyenda manualmente en la esquina inferior derecha
    hL.Position = [0.65, 0.05, 0.25, 0.25]; % [left, bottom, width, height]

    % Guardar la imagen combinada
    saveas(gcf, fullfile(path_save, subfolder, 'combined_plot_probabilities_all_cells.png'));
    close(gcf); % Cerrar la figura después de guardarla
end
