# Cell segmentation and classification using YOLOv5 model

The classification.m and segmentation.m functions are already implemented in do_features_extraction.m to generate the mask, extract the features and classify bbox for further analysis. 

To use the models developed with YOLOv5, follow these steps:

1. Create a conda environment with the yolo5v-env.yaml file.
```
conda env create -f yolo5v-env.yaml
```
This must have installed all the dependencies needed in conda.

2. Download yolov5:
Download the modified yolov5 repository.
3. Configure python environment in Matlab.
```
pyenv('Version', pythonPath);
```
4. Specify the directories.

In the do_features_extraction.m is necessary to specify the following directories:
```
predict_clas_script = 'path/in/downloaded/repo/to/classify/predict.py'; % predict_script: path to predict.py script in yolov5 cloned folder.
weights_class = 'path/to/yolov5/classify_weights/best.pt'; % weights: path to best.pt weight.
python_path = 'path/in/conda/to/python.exe';
yolo_path = 'path/to/yolov5/folder';
predict_seg_script = 'path/in/downloaded/repo/to/segment/predict.py';
weights_seg = 'path/to/yolov5/segmentation_weights/best.pt';
```
