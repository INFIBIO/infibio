import os
from PIL import Image

def convert_tif_to_png(input_folder, output_folder):
    # Verifica si la carpeta de salida existe, si no, la crea
    if not os.path.exists(output_folder):
        os.makedirs(output_folder)

    # Recorre todos los archivos en la carpeta de entrada
    for filename in os.listdir(input_folder):
        if filename.endswith(".tif") or filename.endswith(".tiff"):
            # Ruta completa del archivo tif
            tif_path = os.path.join(input_folder, filename)
            # Abre la imagen
            with Image.open(tif_path) as img:
                # Nombre del archivo sin la extensión
                base_filename = os.path.splitext(filename)[0]
                # Ruta completa del archivo png de salida
                png_path = os.path.join(output_folder, base_filename + ".png")
                # Convierte y guarda la imagen en formato png
                img.save(png_path, "PNG")
                print(f"Convertido: {tif_path} -> {png_path}")

            
# Carpeta de entrada (donde se encuentran los archivos tif)
input_folder = "C:/Users/uib/Desktop/96wp_sedmentation_270924_2"
# Carpeta de salida (donde se guardarán los archivos png)
output_folder = "C:/Users/uib/Desktop/96wp_sedmentation_270924_2"

# Ejecuta la conversión
convert_tif_to_png(input_folder, output_folder)
