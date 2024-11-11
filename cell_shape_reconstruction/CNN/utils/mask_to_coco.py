import numpy as np
import cv2
from pycocotools import mask
import json
import os

# Ruta al archivo de la máscara
mask_path = 'C:/Users/uib/Documents/Alvaro_2324/Segmentation/yeaz/images_for_masks/masks_2/'

# Cargar la máscara binaria
for file_name in os.listdir(mask_path):
    if file_name.endswith('.png'):
        # Construir la ruta completa del archivo
        file_path = os.path.join(mask_path, file_name)
        
        # Cargar la máscara binaria
        mask_image = cv2.imread(file_path, cv2.IMREAD_GRAYSCALE)
        
        # Resto del código...
        contours, _ = cv2.findContours(mask_image, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    # Encontrar contornos
        print( f"Se encontraron {len(contours)} contornos en la máscara")

        # Inicializar lista de anotaciones
        annotations = []

        # Iterar sobre los contornos
        # Iterar sobre los contornos
        for contour in contours:
            # Convertir contorno a una lista de puntos
            segmentation = contour.flatten().tolist()

            # Crear máscara binaria para el contorno actual
            mask_binary = np.zeros_like(mask_image)
            cv2.drawContours(mask_binary, [contour], -1, 1, thickness=cv2.FILLED)

            # Obtener el bounding box (caja delimitadora)
            x, y, w, h = cv2.boundingRect(contour)

            # Aumentar el tamaño del bounding box en un 20% (ajustar según sea necesario)
            factor_ancho = 1.2
            factor_alto = 1.2  # Puedes ajustar este valor también si quieres aumentar la altura

            # Calcular el nuevo ancho y alto
            nuevo_w = int(w * factor_ancho)
            nuevo_h = int(h * factor_alto)

            # Ajustar la posición para centrar el nuevo bounding box
            nuevo_x = max(x - (nuevo_w - w) // 2, 0)  # Asegura que no sea negativo
            nuevo_y = max(y - (nuevo_h - h) // 2, 0)  # Asegura que no sea negativo

            # Convertir la máscara binaria a formato RLE
            rle = mask.encode(np.asfortranarray(mask_binary))

            # Calcular el área
            area = mask.area(rle)
            print(f"Área: {area}")

            # Crear la anotación en formato COCO
            annotation = {
                "id": len(annotations) + 1,
                "image_id": int(file_name.split('.')[0]),  # Deberás ajustar esto según tus datos
                "category_id": 1,  # Ajusta según tu categoría
                "bbox": [nuevo_x, nuevo_y, nuevo_w, nuevo_h],
                "area": area.tolist(),
                "segmentation": [segmentation],
                "iscrowd": 0    
            }

            
            annotations.append(annotation)

        # Crear estructura COCO
        coco_format = {
            "info": {
                "year": "2024",
                "version": "1",
                "description": "Exported from roboflow.com",
                "contributor": "",
                "url": "https://public.roboflow.com/object-detection/undefined",
                "date_created": "2024-06-25T13:08:10+00:00"
            },
            "licenses": [
                {
                    "id": 1,
                    "url": "https://creativecommons.org/licenses/by/4.0/",
                    "name": "CC BY 4.0"
                }
            ],
            "categories": [
                {
            "id": 0,
            "name": "mask",
            "supercategory": "none"
                },
                {
                    "id": 1,  # Ajustar según la categoría
                    "name": "mask",  # Nombre de la categoría
                    "supercategory": "mask"  # Nombre de la supercategoría
                }
            ],
            "images": [
                {
                    "id": int(file_name.split('.')[0]),  # Ajustar según la imagen
                    "license": 1,
                    "file_name": '{}.png'.format(str(int(file_name.split('.')[0]))),  # Nombre de la imagen original without extension
                    "width": mask_image.shape[1],
                    "height": mask_image.shape[0],
                    "date_captured": "2024-06-25T13:08:10+00:00"
                }
            ],
            "annotations": annotations
        
        }

        # Construir la ruta del archivo JSON en la misma carpeta que la máscara
         # Define the variable "i" as the position of the file_name in the list
        json_path = os.path.join(os.path.dirname(mask_path), '{}_annotations.coco.json'.format(str(int(file_name.split('.')[0]))))
        print(json_path)    
        # Guardar en archivo JSON
        with open(json_path, 'w') as f:
            json.dump(coco_format, f)

        print(f"Archivo JSON guardado en: {json_path}")