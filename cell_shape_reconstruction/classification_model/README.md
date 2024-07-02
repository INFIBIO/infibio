# Cell classification using YOLOv5 model

The run_yolo_img.m function is already implemented in do_features_extraction.m to extract the features and classify bbox for further analysis. 

To use the cell classification model developed with YOLOv5, follow these steps:

1. Create a conda environment with the yolo5v-env.yaml file.
```
conda env create -f yolo5v-env.yaml
```
This must have installed all the dendendencies needed in conda.

2. Clone yolov5:
```
git clone https://github.com/ultralytics/yolov5.git
```
3. Configure python environment in Matlab.
```
pyenv('Version', pythonPath);
```
4. Specify the directories.

In the run_yolo_img.m is necessary to specify the following directories:
python_executable = 'path/in/conda/to/python.exe';
detect_script = 'path/in/cloned/repo/to/predict.py';
weights = 'path/to/yolov5/weights/best.pt';
