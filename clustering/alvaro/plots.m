function plots(df, bins, path_save)
    % bins = 100;
    % df = csv_combined;
    if ~exist('bins', 'var')
        bins = 100;
    end
    
    if ~exist('path_save', 'var')
        path_save = '';
    end
    
    % Define el criterio para los valores atípicos (por ejemplo, valores fuera de 1.5 * IQR)
    MyMatrix = sort(vertcat(df.areaNorm));
    % lower_bound = quantile(MyMatrix, 0.25) - iqr(MyMatrix);
    % upper_bound = quantile(MyMatrix, 0.75) + 5 * iqr(MyMatrix);
    % % Filtra los valores atípicos
    % df_filtered = df(df(:).areaNorm > lower_bound & df(:).areaNorm < upper_bound, :);
    
    % Ordena el factor de Time para estar en orden numérico
    % df.Time = categorical(df.Time);
    mask = ~isnan([df.Time]);
    datos_limpios = df(mask);
    % Obtener los tiempos únicos
    tiempos_unicos = unique(vertcat(datos_limpios.Time));
    % Definir el nombre de la subcarpeta
    subcarpeta = 'graficos';
    
    % Comprobar si la subcarpeta existe, si no, crearla
    if ~exist(fullfile(path_save, subcarpeta), 'dir')
        mkdir(fullfile(path_save, subcarpeta));
    end
    
    % Iterar sobre cada Time y crear un histograma para el área correspondiente
    for i = 1:length(tiempos_unicos)
        mask = [df.Time] == tiempos_unicos(i);
        
        % Filtrar los df para el Time actual
        datos_tiempo_actual = df(mask);
        figure;
        hold on;
        matrix = vertcat(datos_tiempo_actual.areaNorm);
        % Crear el histograma para el área
        h = histogram(matrix);
        
        % Añadir etiquetas y título
        xlabel('Área');
        ylabel('Frecuencia');
        title(['Distribución del Área para Time ', num2str(tiempos_unicos(i))]);
        % Guardar el gráfico en la subcarpeta
        nombre_archivo = sprintf('hist_plot%d.png', tiempos_unicos(i));
        ruta_archivo = fullfile(path_save, subcarpeta, nombre_archivo);
        saveas(gcf, ruta_archivo);
        
        % Cerrar la figura actual para evitar acumulación
        close(gcf);
    end
    
    % Filter out extreme values
    mask = [df.areaNorm] > 2;
    df_extreme = df(mask);
    
    
    for i = 1:length(tiempos_unicos)
        mask = [df_extreme.Time] == tiempos_unicos(i);
        
        % Filtrar los df para el Time actual
        datos_tiempo_actual = df_extreme(mask);
        figure;
        hold on;
        matrix = vertcat(datos_tiempo_actual.areaNorm);
        % Crear el histograma para el área
        h = histogram(matrix);
        
        % Añadir etiquetas y título
        xlabel('Área');
        ylabel('Frecuencia');
        title(['Distribución del Área para Time ', num2str(tiempos_unicos(i))]);
         % Guardar el gráfico en la subcarpeta
        nombre_archivo = sprintf('extreme_plot%d.png', tiempos_unicos(i));
        ruta_archivo = fullfile(path_save, subcarpeta, nombre_archivo);
        saveas(gcf, ruta_archivo);
        
        % Cerrar la figura actual para evitar acumulación
        close(gcf);
    end
    
    
    figure;
    distributionPlot(vertcat(datos_limpios.areaNorm), 'group', [datos_limpios.Time], 'histOpt', 2);
    title('Distribution of Areas per Time Violin Plot');
    xlabel('Time');
    ylabel('Area');
    nombre_archivo ='violin_plot.png';
    ruta_archivo = fullfile(path_save, subcarpeta, nombre_archivo);
    saveas(gcf, ruta_archivo);
    
    % Cerrar la figura actual para evitar acumulación
    close(gcf);

    probability = struct(); % Inicializar la estructura vacía

    for i = 1:length(tiempos_unicos)
        mask = [df.Time] == tiempos_unicos(i);
        % Filtrar los df para el Time actual
        datos_tiempo_actual = df(mask);
        
        areas_unicas = unique(vertcat(datos_tiempo_actual.areaNorm));
        area_total = sum(vertcat(datos_tiempo_actual.areaNorm));
        
        for j = 1:length(areas_unicas) % Corregido el bucle for
            probability(end+1).time = tiempos_unicos(i);
            mask = [datos_tiempo_actual.areaNorm] == areas_unicas(j);
            filtro = datos_tiempo_actual(mask);
            suma = sum(vertcat(filtro.areaNorm));
            
            probability(end).probabilidad = suma / area_total;
            probability(end).area = areas_unicas(j); % Corregido el formato de asignación
        end
    end
end