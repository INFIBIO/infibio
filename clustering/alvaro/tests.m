function tests(df, path_save)
% Check normal distribution and homoscedasticity
% Perform Shapiro-Wilk test for normality
% Initialize cell array to store Shapiro-Wilk test results
shapiro_test = cell(size(unique_times));

% Iterate over each unique value of Time
for i = 1:length(unique_times)
    % Filter data for the current Time
    mask = [clean_data.Time] == unique_times(i);
    subset_data = clean_data(mask);
    
    % Perform Shapiro-Wilk test for normality on the normalized areas
    shapiro_test{i} = swtest(vertcat(subset_data.NormalizedArea));
end

% Perform Levene's test for homogeneity of variances
levene_test = arrayfun(@(x) levenetest(x.NormalizedArea), df, 'UniformOutput', false);

% Perform Kruskal-Wallis test
[p, tbl, stats] = kruskalwallis([df.NormalizedArea], [df.Time]);

% Save Kruskal-Wallis result to a CSV file
%writetable(tbl, fullfile(path_save, 'results', 'kruskal.csv'));

% Perform Tukey post hoc test
groups = cellstr(num2str([df.Time]));
[c, m, h, nms] = multcompare(stats, 'ctype', 'bonferroni', 'display', 'off', 'dimension', 2);

% Create a table for Tukey post hoc result
tukey_tbl = array2table(c, 'VariableNames', {'Group1', 'Group2', 'LowerCI', 'UpperCI', 'pValue'});
tukey_tbl.Group1 = groups(tukey_tbl.Group1);
tukey_tbl.Group2 = groups(tukey_tbl.Group2);

% Save Tukey post hoc result to a CSV file
%writetable(tukey_tbl, fullfile(path_save, 'results', 'wilcox.csv'));

