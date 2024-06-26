% function tests(df, path_save)
% Check normal distribution and homoscedasticity
% Perform Shapiro-Wilk test for normality
% Initialize cell array to store Shapiro-Wilk test results
df = mat_cleaned ;
df=transpose(df);
mask = ~isnan([df.Time]);
clean_data = df(mask);
unique_times = unique(horzcat(clean_data.Time));
shapiro_test = cell(size(unique_times));

% Iterate over each unique value of Time
for i = 1:length(unique_times)
    % Filter data for the current Time
    mask = [clean_data.Time] == unique_times(i);
    subset_data = clean_data(mask);
    
    % Perform Shapiro-Wilk test for normality on the normalized areas
    shapiro_test{i} = swtest(vertcat(subset_data.Area));
end

% Perform Levene's test for homogeneity of variances
levene_test = vartestn(vertcat(clean_data.NormalizedArea), vertcat(clean_data.Time));

% Perform Kruskal-Wallis test
[p, tbl, stats] = kruskalwallis([clean_data.NormalizedArea], [clean_data.Time]);

% Save Kruskal-Wallis result to a CSV file
% writetable(tbl, fullfile(path_save, 'results', 'kruskal.csv'));
% clean_data = struct2table(clean_data)
% Perform Tukey post hoc test

[c, m, h, nms] = multcompare(stats, 'ctype', 'bonferroni', 'display', 'off', 'dimension', 2);

% Create a table for Tukey post hoc result
tukey_tbl = array2table(c, 'VariableNames', {'Group1', 'Group2', 'LowerCI','Difference', 'UpperCI', 'pValue'});
% tukey_tbl.Group1 = groups(tukey_tbl.Group1);
% tukey_tbl.Group2 = groups(tukey_tbl.Group2);
tukey_numbers = unique(vertcat(tukey_tbl.Group1));
[~, idx] = ismember(vertcat(tukey_tbl.Group1), tukey_numbers);
tukey_tbl.Group1 = cell2table(nms(idx));
tukey_numbers = unique(vertcat(tukey_tbl.Group2));
[~, idx] = ismember(vertcat(tukey_tbl.Group2), tukey_numbers);
nms = nms(2:end, :);
tukey_tbl.Group2 = cell2table(nms(idx));
disp(tukey_tbl)

% Save Tukey post hoc result to a CSV file
%writetable(tukey_tbl, fullfile(path_save, 'results', 'tukey.csv'));

