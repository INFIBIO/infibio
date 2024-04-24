%function tests(df, path_save)
% Realiza la prueba de Kruskal-Wallis
[p, tbl, stats] = kruskalwallis([datos_limpios.areaNorm], [datos_limpios.Time]);

% Guarda el resultado de Kruskal-Wallis en un archivo CSV
%writetable(tbl, fullfile(path_save, 'results', 'kruskal.csv'));

% Realiza la prueba de Tukey post hoc
groups = cellstr(num2str([datos_limpios.Time]));
[c, m, h, nms] = multcompare(stats, 'ctype', 'bonferroni', 'display', 'off', 'dimension', 2);

% Crea una tabla para el resultado de Tukey post hoc
tukey_tbl = array2table(c, 'VariableNames', {'Group1', 'Group2', 'LowerCI', 'UpperCI', 'pValue'});
tukey_tbl.Group1 = groups(tukey_tbl.Group1);
tukey_tbl.Group2 = groups(tukey_tbl.Group2);

% Guarda el resultado de Tukey post hoc en un archivo CSV
%writetable(tukey_tbl, fullfile(path_save, 'results', 'wilcox.csv'));

