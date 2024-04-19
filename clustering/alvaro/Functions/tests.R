tests <- function (df, path_save){
  kruskal_result <- kruskal.test(area_norm ~ as.factor(sort(as.numeric(Time))), data = df)

  # browser()
  # Tukey post hoc test
  tukey_result <- pairwise.wilcox.test(df$area_norm, as.factor(sort(as.numeric(df$Time))))

  # Save ANOVA summary to CSV
  anova_summary <- summary(kruskal_result, Time)
  capture.output(kruskal_result,file=paste0(path_save,"\\results","\\kruskal.csv"))   
  # Extract individual tables from Tukey result and save to CSV
  capture.output(tukey_result,file=paste0(path_save,"\\results","\\wilcox.csv"))
}