path = 'C:\Users\uib\Nextcloud\LAB\Wetlab\Yeast_experiments\Clustering experiments\Exps_clustering_20240327_tiff\SK1_1000_30_0.1zymo';

% Carga las funciones necesarias (asegúrate de que las funciones estén en la misma carpeta)


% % Ruta donde se encuentra el modelo utilizado para diferenciar entre células con formas normales y extrañas
% model_path = 'C:\Users\uib\Desktop\infibio_repository_new\infibio\clustering\alvaro\Functions\classification_cells_not_wanted.rds';
% 
% Combina los archivos CSV generados por el análisis de imágenes de MATLAB
csv_combined = combineMatFiles(path);

% Limpia las formas celulares extrañas
% csv_cleaned = clean_weird_shapes(csv_combined, model_path);

% Genera gráficos para analizar la distribución de áreas
plots(csv_combined, 100, path);

% Realiza pruebas estadísticas
tests(csv_combined, path);
