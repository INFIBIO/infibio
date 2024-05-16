function tests(df, path_save)

% Check if the 'results' folder exists, if not, create it
results_folder = fullfile(path_save, 'results');
if ~exist(results_folder, 'dir')
    mkdir(results_folder);
end

% Check normal distribution and homoscedasticity
% Perform Shapiro-Wilk test for normality
% Initialize cell array to store Shapiro-Wilk test results
mask = ~isnan(df.Time);
clean_data = df(mask, :);
unique_times = unique(clean_data.Time);
shapiro_test = cell(size(unique_times));

% Iterate over each unique value of Time
for i = 1:length(unique_times)
    % Filter data for the current Time
    subset_data = clean_data(clean_data.Time == unique_times(i), :);
    
    % Perform Shapiro-Wilk test for normality on the normalized areas
    shapiro_test{i} = swtest(subset_data.Area);
end

% Perform Levene's test for homogeneity of variances
levene_test = vartestn(clean_data.NormalizedArea, clean_data.Time);
% Save Levene's test to a CSV file
writematrix(levene_test, fullfile(results_folder, 'levene.csv'));

% Perform Kruskal-Wallis test
[~, ~, stats] = kruskalwallis(clean_data.NormalizedArea, clean_data.Time);
% Save stats variable to a .mat file
save(fullfile(results_folder, 'kruskal.mat'), 'stats');

% Perform Tukey post hoc test
[c, ~, ~, nms] = multcompare(stats, 'ctype', 'bonferroni', 'display', 'off', 'dimension', 2);

% Create a table for Tukey post hoc result
tukey_tbl = array2table(c, 'VariableNames', {'Group1', 'Group2', 'LowerCI', 'Difference', 'UpperCI', 'pValue'});
tukey_tbl.Group1 = nms(tukey_tbl.Group1);
tukey_tbl.Group2 = nms(tukey_tbl.Group2);
disp(tukey_tbl)

% Save Tukey post hoc result to a CSV file
writetable(tukey_tbl, fullfile(results_folder, 'tukey.csv'));
