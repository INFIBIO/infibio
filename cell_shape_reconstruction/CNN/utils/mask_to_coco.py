# script developed to translate from mask to coco format in order to upload the masks in the 
# correct format to Roboflow.
# INPUT: folder with the BW png images of the masks.
# OUTPUT: .json file with the masks in coco format for each image in the input folder
# HISTORY:
# --------
# Created 16 July 24. AR.
import numpy as np
import cv2
from pycocotools import mask
import json
import os

# Path to the mask file
mask_path = 'C:/Users/uib/Documents/Alvaro_2324/Segmentation/yeaz/images_for_masks/masks_2/'

# Load the binary mask
for file_name in os.listdir(mask_path):
    if file_name.endswith('.png'):
        # Build the full file path
        file_path = os.path.join(mask_path, file_name)
        
        # Load the binary mask
        mask_image = cv2.imread(file_path, cv2.IMREAD_GRAYSCALE)
        
        # Rest of the code...
        contours, _ = cv2.findContours(mask_image, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
        
        # Find contours
        print(f"{len(contours)} contours were found in the mask")

        # Initialize list of annotations
        annotations = []

        # Iterate over contours
        for contour in contours:
            # Convert contour to a list of points
            segmentation = contour.flatten().tolist()

            # Create binary mask for the current contour
            mask_binary = np.zeros_like(mask_image)
            cv2.drawContours(mask_binary, [contour], -1, 1, thickness=cv2.FILLED)

            # Get the bounding box
            x, y, w, h = cv2.boundingRect(contour)

            # Increase the bounding box size by 20% (adjust as needed)
            width_factor = 1.2
            height_factor = 1.2  # You can adjust this value as well if you want to increase the height

            # Calculate the new width and height
            new_w = int(w * width_factor)
            new_h = int(h * height_factor)

            # Adjust the position to center the new bounding box
            new_x = max(x - (new_w - w) // 2, 0)  # Ensures it is not negative
            new_y = max(y - (new_h - h) // 2, 0)  # Ensures it is not negative

            # Convert the binary mask to RLE format
            rle = mask.encode(np.asfortranarray(mask_binary))

            # Calculate the area
            area = mask.area(rle)
            print(f"Area: {area}")

            # Create the annotation in COCO format
            annotation = {
                "id": len(annotations) + 1,
                "image_id": int(file_name.split('.')[0]),  # You should adjust this according to your data
                "category_id": 1,  # Adjust according to your category
                "bbox": [new_x, new_y, new_w, new_h],
                "area": area.tolist(),
                "segmentation": [segmentation],
                "iscrowd": 0    
            }

            annotations.append(annotation)

        # Create COCO structure
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
                    "id": 1,  # Adjust according to the category
                    "name": "mask",  # Category name
                    "supercategory": "mask"  # Supercategory name
                }
            ],
            "images": [
                {
                    "id": int(file_name.split('.')[0]),  # Adjust according to the image
                    "license": 1,
                    "file_name": '{}.png'.format(str(int(file_name.split('.')[0]))),  # Original image name without extension
                    "width": mask_image.shape[1],
                    "height": mask_image.shape[0],
                    "date_captured": "2024-06-25T13:08:10+00:00"
                }
            ],
            "annotations": annotations
        }

        # Build the JSON file path in the same folder as the mask
        json_path = os.path.join(os.path.dirname(mask_path), '{}_annotations.coco.json'.format(str(int(file_name.split('.')[0]))))
        print(json_path)    
        
        # Save to JSON file
        with open(json_path, 'w') as f:
            json.dump(coco_format, f)

        print(f"JSON file saved at: {json_path}")
