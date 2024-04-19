# Define function to read CSV files from a folder and combine them into a single dataframe
combine_csv <- function(folder_path) {
  # Set working directory to the specified folder
  #browser()
  # CSV file list in the folder
  archivos_csv <- list.files(pattern = "\\.csv$", recursive = TRUE, full.names = TRUE)
  
  # Initialize an empty dataframe
  df_combinado <- data.frame()
  
  # Iterate over each CSV file
  for (archivo in archivos_csv) {
    # Build the full file path
    ruta_archivo <- file.path(folder_path, archivo)
    
    # Read the CSV file
    datos <- read.csv(ruta_archivo, sep = ",")
    
    # Check if there is more than one row in the DataFrame
    if (nrow(datos) > 1) {
      # Obtener el nombre del archivo
      nombre_archivo <- basename(archivo)
      # Extraer el pocillo
      pocillo <- as.factor(sub("^([A-Z]+[0-9]+).*","\\1", nombre_archivo))
      
      # Extraer el tercer número después del segundo _
      replica <- as.factor(sub("^[A-Z]+[0-9]+.([0-9]+)_.*","\\1", nombre_archivo))
      
      # Extraer el segundo número después del primer _
      tiempo <- as.factor(sub("^[A-Z]+[0-9]+.[0-9]+_[0-9]+_(-?[0-9]+).*", "\\1", nombre_archivo))
      
      
      
      # Crear la columna area_norm y dividir cada valor de el valor medio de cada csv para obtener las areas normalizadas
      datos$area_norm <- datos$Area / mean(quantile(datos$Area, 0.25))
      
      # Agregar las columnas al dataframe datos
      datos$pocillo <- pocillo
      datos$replica <- replica
      datos$Time <- tiempo
      datos$Concentration <- as.factor(datos$Concentration)
      # Combinar los datos al dataframe existente
      df_combinado <- rbind(df_combinado, datos)
    }
  }
  
  # Return the combined dataframe
  return(df_combinado)
}

# Example usage of the function
