plots <- function (df, bins=100, path_save){
  library(dplyr)
  library(ggplot2)
  
  #browser()
  df<- df %>% 
    arrange(as.numeric(Time))
  
  # Define outlier criterion (for example, values outside 1.5 * IQR)
  lower_bound <- quantile(df$area_norm, 0.25) - 5 * IQR(df$area_norm)
  upper_bound <- quantile(df$area_norm, 0.75) + 5 * IQR(df$area_norm)
  
  # Filter out outliers
  df_filtered <- df %>%
    filter(area_norm >= lower_bound  & area_norm <= upper_bound )
  # Reordenar el factor Time para que esté en orden numérico
  df_filtered$Time <- factor(df_filtered$Time, levels = unique(df_filtered$Time))
  
  
  # Plot relative count of areas per time using bins after filtering outliers
  ggplot(df_filtered, aes(x = area_norm, fill = as.factor(sort(as.numeric(Time))))) +
    geom_histogram(binwidth = (max(df_filtered$area_norm) - min(df_filtered$area_norm)) / bins, alpha = 0.5, position = "identity") +
    ggtitle("Distribution of Areas per Time (Excluding Outliers)") +
    xlab("Area normalized") +
    ylab("Count") +
    theme_minimal() +
    facet_wrap(~as.numeric(Time))+
    theme(legend.position = "none")
  if (!file.exists(paste0(path_save, "/results"))) {
    dir.create(paste0(path_save, "/results"))
  }
  ggsave("Distribution of Areas per Time (Excluding Outliers).png", path = paste0(path_save,"\\results"), width = 1920, height = 1216, units = "px",bg = 'white')
  
  ggplot(df, aes(x = area_norm, fill = as.factor(sort(as.numeric(Time))))) +
    geom_histogram(binwidth = (max(df_filtered$area_norm) - min(df_filtered$area_norm)) / bins, alpha = 0.5, position = "identity") +
    ggtitle("Relative distribution of Areas per Time") +
    xlab("Area normalized") +
    ylab("Count") +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1))+
    facet_wrap(~as.numeric(Time))+
    theme(legend.position = "none")
  ggsave( "Relative distribution of Areas per Time.png", path = paste0(path_save,"\\results"), width = 1920, height = 1216, units = "px", bg = 'white')
  
  
  # Filter out extreme values
  df_extreme <- df %>%
    filter(area_norm > 2)
  
  # Plot extreme values per time
  ggplot(df_extreme, aes(x = area_norm, fill = as.factor(sort(as.numeric(Time))))) +
    geom_histogram(binwidth = (max(df_extreme$area_norm) - min(df_extreme$area_norm)) / bins, alpha = 0.5, position = "identity") +
    ggtitle("Areas > 2 per Time") +
    xlab("Area normalized") +
    ylab("Count") +
    facet_wrap(~as.numeric(Time))+
    theme(legend.position = "none")
  ggsave( "Relative areas - 2 per Time.png", path = paste0(path_save,"\\results"), width = 1920, height = 1216, units = "px", bg = 'white')
  
  # Plot violin plots per time after filtering outliers
  ggplot(df, aes(x = as.factor(sort(as.numeric(Time))), y = area_norm)) +
    geom_violin() +
    geom_count(alpha=0.1)+
    ggtitle("Distribution of Areas per Time Violin Plot") +
    xlab("Time") +
    ylab("Area") 
  ggsave( "Distribution of Areas per Time Violin Plot.png", path = paste0(path_save,"\\results"),  width = 1920, height = 1216, units = "px", bg = 'white') 
  
  df_extreme$rel_axis <- df_extreme$MajorAxisLength/df_extreme$MinorAxisLength
  
  ggplot(df_extreme, aes(x = rel_axis, fill = as.factor(sort(as.numeric(Time))))) +
    geom_histogram(aes(y = ..count.. / sum(..count..)), binwidth = (max(df_extreme$area_norm) - min(df_extreme$area_norm)) / bins, alpha = 0.5, position = "identity") +
    ggtitle("Aspect Ratio for Area Normalized > 2") +
    scale_color_manual(values = rainbow(length(levels(df_extreme$Time)))) +
    labs(x = "Aspect ratio", y = "PDF (Probability Density Function)", color = "Time") +
    facet_wrap(~as.numeric(Time)) +
    scale_size_continuous(range = c(0.05, 0.1)) +
    theme_minimal()
  
  ggsave( "Relative distribution of Aspect Ratio for area normalized - 2.png", path = paste0(path_save,"\\results"), width = 1920, height = 1216, units = "px", bg = 'white')
}
