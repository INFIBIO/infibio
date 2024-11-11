# This script is developed to segment and identify yeast pictures. 
# The expected input is a folder containing the png images. 
# The output are BW mask images with each classification as a different grayscale.
# HISTORY:
# ---------
# 08. Sept, 2024. AR: Created.
import os
import cv2
import numpy as np
import tempfile
from pathlib import Path
import scipy
from skimage.draw import polygon
from skimage.morphology import disk, closing
from skimage.measure import label, regionprops
import importlib.util
import glob
import torch
import shutil

# Check if GPU is available
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
print(f'Using device: {device}')

# Import the necessary module for dynamic import
import importlib.util

def load_module(script_path, module_name):
    # Create a module specification based on the given file path
    # "segment" is used as the name of the module being loaded
    # PARAMETERS:
    # -----------
    # script_path: path to the Python script containing the module
    # RETURNS:
    # --------
    # segment: dynamically loaded module object
    # HISTORY:
    # ---------
    # 08. Sept, 2024. AR: Created.

    spec = importlib.util.spec_from_file_location(module_name, script_path)

    # Create a new module based on the specification
    module = importlib.util.module_from_spec(spec)

    # Execute the module's code within its own namespace
    spec.loader.exec_module(module)

    # Return the dynamically loaded module object
    return module


def run_yolo_segmentation(segment, weights_seg, img_path):
    # Run segmentation using the segment module
    # PARAMETERS:
    # -----------
    # segment: dynamically loaded module object
    # weights_seg: path to the weights file for segmentation
    # img_path: path to the image to be segmented
    # RETURNS:
    # --------
    # labels: list of labels for each detected object as a list of strings
    # HISTORY:  
    # ---------
    # 08. Sept, 2024. AR: Created.
    segment.run(weights_seg, img_path, save_txt=True)
    
    # Find the latest 'exp' directory in the YOLOv5 results path
    results_path = os.path.join("yolov5", "runs", "predict-seg")
    exp_dirs = sorted(glob.glob(os.path.join(results_path, "exp*")), key=os.path.getmtime)
    
    if not exp_dirs:
        print("No 'exp' directories found in results path.")
        return None

    latest_exp_dir = exp_dirs[-1]  # Get the latest 'exp' directory
    labels_dir = os.path.join(latest_exp_dir, "labels")

    # Check if the labels directory exists
    if not os.path.exists(labels_dir):
        print(f"No 'labels' directory found in {latest_exp_dir}.")
        return None

    # Gather all label files from the labels directory
    label_files = glob.glob(os.path.join(labels_dir, "*.txt"))
    
    if not label_files:
        print(f"No label files found in {labels_dir}.")
        return None

    # Read labels from each file
    labels = []
    for label_file in label_files:
        with open(label_file, 'r') as file:
            labels.append(file.read().splitlines())  # Split lines for better handling of each label
    try:
        shutil.rmtree(os.path.join('/home/araya/zymo_exp_subset/',latest_exp_dir))
    except Exception as e:
        print(f'Cleanup error: {e}')
    return labels



def run_yolo_classification(classify, weights_clas, img_path):
    # Run classification using the classify module
    # PARAMETERS:
    # -----------
    # classify: dynamically loaded module object
    # weights_clas: path to the weights file for classification
    # img_path: path to the image to be classified
    # RETURNS:
    # --------
    # value: integer value representing the classification result
    # HISTORY:
    # ---------
    # 08. Sept, 2024. AR: Created.

    # Run segmentation using the segment module
    classify.run(weights_clas, img_path, save_txt=True)
    
    # Find the latest 'exp' directory in the YOLOv5 results path
    results_path = os.path.join("yolov5", "runs", "predict-cls")
    exp_dirs = sorted(glob.glob(os.path.join(results_path, "exp*")), key=os.path.getmtime)
    
    if not exp_dirs:
        print("No 'exp' directories found in results path.")
        return None

    latest_exp_dir = exp_dirs[-1]  # Get the latest 'exp' directory
    labels_dir = os.path.join(latest_exp_dir, "labels")

    # Check if the labels directory exists
    if not os.path.exists(labels_dir):
        print(f"No 'labels' directory found in {latest_exp_dir}.")
        return None

    # Gather all label files from the labels directory
    label_file = glob.glob(os.path.join(labels_dir, "*.txt"))[0]
    if not label_file:
        print(f"No label files found in {labels_dir}.")
        return None

    # Read labels from each file
    with open(label_file, 'r') as file:
        # Lee la primera línea del archivo
        first_line = file.readline().strip()  # Leer y quitar espacios o saltos de línea al final
        
        # Divide la línea en valores, por ejemplo, por espacios o comas
        value = int(first_line.split()[-1])  # Cambia el separador si es necesario
    try:
        shutil.rmtree(os.path.join('/home/araya/zymo_exp_subset/',latest_exp_dir))
    except Exception as e:
        print(f'Cleanup error: {e}')
    return value

def segmentation_fullsize(img_path, predict_seg_script, weights_seg, predict_clas_script, weights_clas):
    # Perform segmentation on the full-size image
    # PARAMETERS:
    # -----------
    # img_path: path to the image to be segmented
    # predict_seg_script: path to the segmentation prediction script
    # weights_seg: path to the weights file for segmentation
    # predict_clas_script: path to the classification prediction script
    # weights_clas: path to the weights file for classification
    # RETURNS:
    # --------
    # BWimg_full: binary mask of the segmented image
    # HISTORY:
    # ---------
    # 08. Sept, 2024. AR: Created.

    # Load and adjust image
    img = cv2.imread(img_path)
    img = cv2.normalize(img, None, 0, 255, cv2.NORM_MINMAX)

    # Get image dimensions
    height, width, _ = img.shape

    # Initialize the final binary mask
    BWimg_full = np.zeros((height, width), dtype=bool)

    # Define crop parameters
    crop_size = int(640)
    overlap = int(100)

    # Compute the number of crops required
    x_steps = int(np.ceil((width - overlap) / (crop_size - overlap)))
    y_steps = int(np.ceil((height - overlap) / (crop_size - overlap)))

    # Load YOLO model
    segment_module = load_module(predict_seg_script, 'segment')
    class_module = load_module(predict_clas_script, 'classify')

    crops_save_folder = os.path.join(Path(img_path).parent, 'crops')
    os.makedirs(crops_save_folder, exist_ok=True)

    # Iterate over the image to create crops
    for i in range(y_steps):
        for j in range(x_steps):
            # Define crop boundaries with overlap consideration
            x_start = max(0, j * (crop_size - overlap))
            y_start = max(0, i * (crop_size - overlap))
            x_end = min(x_start + crop_size, width)
            y_end = min(y_start + crop_size, height)

            # Extract the crop
            img_crop = img[y_start:y_end, x_start:x_end]

            # Pad the crop if it's smaller than the crop_size
            pad_width = crop_size - (x_end - x_start)
            pad_height = crop_size - (y_end - y_start)
            if pad_width > 0 or pad_height > 0:
                img_crop = cv2.copyMakeBorder(img_crop, 0, pad_height, 0, pad_width, cv2.BORDER_CONSTANT, value=0)

            # Save the crop to a temporary file
            temp_img_path = os.path.join(tempfile.gettempdir(), f'temp_image_{i}_{j}.png')
            cv2.imwrite(temp_img_path, img_crop)

            # Run YOLO segmentation
            seg_masks = run_yolo_segmentation(segment_module, weights_seg, temp_img_path)
           
            BWimg_crop = np.zeros((crop_size, crop_size), dtype=bool)
            try:
                for k in seg_masks:
                    for l in k:
                        # Split the string by spaces to get a list of number strings
                        num_strings = l.split(" ")

                        # Convert the list of number strings to floats
                        coords = np.array(num_strings, dtype=float)

                        # Check if conversion to float was successful
                        if np.any(np.isnan(coords)):
                            print(f"Warning: Some coordinates could not be converted to numbers on line {k + 1}")
                            continue

                        # Ignore the first number (class)
                        coords = coords[1:]

                        # Convert normalized coordinates to pixels
                        x_coords = coords[0::2] * crop_size  # x-coordinates
                        y_coords = coords[1::2] * crop_size  # y-coordinates

                        # Create a polygon from the coordinates
                        rr, cc = polygon(y_coords, x_coords, shape=(crop_size, crop_size))

                        # Create mask and combine with the binary image
                        mask = np.zeros((crop_size, crop_size), dtype=bool)
                        mask[rr, cc] = True
                        BWimg_crop = np.logical_or(BWimg_crop, mask)
            except Exception as e:
                print(f"Error processing segmentation masks: {e}")
                continue
           
            # Update the full-size mask
            BWimg_full[y_start:y_end, x_start:x_end] = np.logical_or(
                BWimg_full[y_start:y_end, x_start:x_end], BWimg_crop[:y_end-y_start, :x_end-x_start]
            )

            # Clean up temporary files
            try:
                os.remove(temp_img_path)
            except Exception as e:
                print(f'Cleanup error: {e}')
    
    # Post-process: Close small gaps between masks in BWimg_full
    BWimg_full = closing(BWimg_full, disk(5))  # Close gaps smaller than 5 pixels
    BWimg_full = (BWimg_full).astype(np.uint8)
    # Etiqueta las regiones conectadas en la imagen binaria
    labeled_img = label(BWimg_full)

    # Obtén las propiedades de cada región, en este caso los bounding boxes
    regions = regionprops(labeled_img)

    # Extrae los bounding boxes (bbox) de cada feature
    for region in regions:
        # Extrae las coordenadas del bbox
        min_row, min_col, max_row, max_col = region.bbox
        
        # Extrae la región correspondiente de la imagen original
        # Asegúrate de que las coordenadas no excedan los límites de la imagen original
        min_row_margin = max(min_row - 10, 0)  # No menor a 0
        max_row_margin = min(max_row + 10, img.shape[0])  # No mayor al alto de la imagen
        min_col_margin = max(min_col - 10, 0)  # No menor a 0
        max_col_margin = min(max_col + 10, img.shape[1])  # No mayor al ancho de la imagen

        # Define la región de la imagen con un margen
        region_image = img[min_row_margin:max_row_margin, min_col_margin:max_col_margin]

        # Save the crop to a temporary file
        temp_img_path = os.path.join(tempfile.gettempdir(), f'temp_image_{i}_{j}.png')
        cv2.imwrite(temp_img_path, region_image)
        # Aplica la función de clasificación a la región
        classification_result = run_yolo_classification(class_module, weights_clas, temp_img_path)
        subimage = BWimg_full[min_row:max_row, min_col:max_col]        
        # Etiqueta los objetos en la subimagen
        labeled_array, num_features = scipy.ndimage.label(subimage)

        # Si no hay objetos en la subimagen, no hay nada que modificar
        if num_features == 0:
            BWimg_full[min_row:max_row, min_col:max_col] = subimage
        else:
            # Calcula el tamaño de cada objeto etiquetado
            sizes = np.bincount(labeled_array.ravel())
            
            # Ignora el fondo (etiqueta 0)
            sizes[0] = 0
            
            # Encuentra la etiqueta del objeto más grande
            largest_label = sizes.argmax()
            
            # Modifica solo el objeto más grande
            subimage[labeled_array == largest_label] = (classification_result + 1) * 70

            # Asigna la subimagen modificada de vuelta a BWimg_full
            BWimg_full[min_row:max_row, min_col:max_col] = subimage
        # Clean up temporary files
        try:
            os.remove(temp_img_path)
        except Exception as e:
            print(f'Cleanup error: {e}')

    # Save BW image with '_BW' suffix in the correct folder
    bw_save_path = os.path.join(Path(img_path).parent, 'segmented', f"{Path(img_path).stem}_BW.tif")
    os.makedirs(os.path.dirname(bw_save_path), exist_ok=True)
    cv2.imwrite(bw_save_path, BWimg_full)  # Save as binary image
    return BWimg_full


def process_images_in_folder(folder_path, predict_seg_script, weights_seg, predict_clas_script, weights_clas):
    # Process all images in the folder
    # PARAMETERS:
    # -----------
    # folder_path: path to the folder containing subfolders with png images
    # yolo_path: path to the YOLOv5 directory
    # predict_seg_script: path to the segmentation prediction script
    # weights_seg: path to the weights file for segmentation
    # predict_clas_script: path to the classification prediction script
    # weights_clas: path to the weights file for classification
    # RETURNS:
    # --------
    # None
    # HISTORY: 
    # ---------
    # 08. Sept, 2024. AR: Created.


    # Define the image extensions to search for
    image_extensions = ['*.png', '*.jpg', '*.jpeg', '*.bmp', '*.tiff']
    
    # Iterate over each subfolder in the folder
    for folder in os.listdir(folder_path):
        folder_full_path = os.path.join(folder_path, folder)
        if os.path.isdir(folder_full_path):  # Check if it's a directory
            for subfolder in os.listdir(folder_full_path):
                subfolder_full_path = os.path.join(folder_full_path, subfolder)
                if os.path.isdir(subfolder_full_path):  # Check if it's a directory
                    # Get a list of all image files in the subfolder
                    image_files = []
                    for ext in image_extensions:
                        image_files.extend(glob.glob(os.path.join(subfolder_full_path, ext)))
                    
                    # Ensure the folder to save results exists
                    result_folder = os.path.join(subfolder_full_path, 'segmented')
                    os.makedirs(result_folder, exist_ok=True)

                    # Process each image in the subfolder
                    for img_path in image_files:
                        print(f'Processing image: {img_path}')
                        # Call the segmentation function
                        segmentation_fullsize(img_path, predict_seg_script, weights_seg, predict_clas_script, weights_clas)


# Main entry point
if __name__ == '__main__':
    # Define paths
    folder_path = '/home/araya/zymo_exp_subset/Exp_Zymolyase01-005_ConA03-2024110'  # Update this path
    predict_seg_script = '/home/araya/zymo_exp_subset/yolov5/segment/predict.py'  # Update this path
    weights_seg = '/home/araya/zymo_exp_subset/yolov5/runs/train-seg/best_seg/weights/best.pt'  # Update this path
    predict_clas_script = '/home/araya/zymo_exp_subset/yolov5/classify/predict.py'  # Update this path
    weights_clas = '/home/araya/zymo_exp_subset/yolov5/runs/train/definitive/weights/best.pt'  # Update this path

    # Process all images in the folder
    process_images_in_folder(folder_path, predict_seg_script, weights_seg, predict_clas_script, weights_clas)
