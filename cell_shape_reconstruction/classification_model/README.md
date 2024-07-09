# Cell classification using YOLOv5 model

The classification.m function is already implemented in do_features_extraction.m to extract the features and classify bbox for further analysis. 

To use the cell classification model developed with YOLOv5, follow these steps:

1. Create a conda environment with the yolo5v-env.yaml file.
```
conda env create -f yolo5v-env.yaml
```
This must have installed all the dependencies needed in conda.

2. Clone yolov5:
```
git clone https://github.com/ultralytics/yolov5.git
```

3. Specify the directories.

In the do_features_extraction.m is necessary to specify the following directories:
```
python_path = 'path/in/conda/to/python.exe';
yolo_path = 'path/to/yolov5';
predict_script = 'path/in/cloned/repo/to/predict.py';
weights = 'path/to/yolov5/weights/best.pt;
```
4. Correct dependencies.
Add these lines to the predict.py to solve problems with dependencies:

## For Windows users:
from pathlib import Path
import pathlib
temp = pathlib.PosixPath
pathlib.PosixPath = pathlib.WindowsPath
## For Linux users (or deploying for Linux):
from pathlib import Path
import pathlib
temp = pathlib.WindowsPath
pathlib.WindowsPath = pathlib.PosixPath
