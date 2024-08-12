# Cell classification using YOLOv5 model

The run_yolo_img.m function is already implemented in do_features_extraction.m to extract the features and classify bbox for further analysis. 

To use the cell classification model developed with YOLOv5, follow these steps:

1. Create a conda environment with the yolov5-env.yaml file.

conda env create -f yolov5-env.yaml

This must have installed all the dependencies needed in conda. Check for the correct path of conda and yolov5-env.yaml file.

# To activate this environment, use
#
#     $ conda activate yolov5-env
#
# To deactivate an active environment, use
#
#     $ conda deactivate


2. Clone yolov5:

git clone https://github.com/ultralytics/yolov5.git


3. Configure python environment in Matlab.

pyenv('Version', pythonPath);

# pythonPath = C:\Users\xisca\anaconda3\envs\yolov5-env\python.exe


4. Specify the directories.

In the run_yolo_img.m is necessary to specify the following directories:

python_executable = 'path/in/conda/to/python.exe';
detect_script = 'path/in/cloned/repo/to/predict.py';
weights = 'path/to/yolov5/weights/best.pt';

# MATLAB

imgpath = 'C:\Users\xisca\Desktop\Trials_scripts_XF\trials_feature_and_track_yeast-main_v2\images\';
python_path = 'C:\Users\xisca\anaconda3\envs\yolov5-env\python.exe';
yolo_path = 'C:\Users\xisca\yolov5';
predict_script = 'C:\Users\xisca\yolov5\classify\predict.py';
weights = 'C:\Users\xisca\Desktop\Trials_scripts_XF\trials_feature_and_track_yeast-main_v2/best.pt';


# predict_XF.py

# For Windows users:
from pathlib import Path
import pathlib
temp = pathlib.PosixPath
pathlib.PosixPath = pathlib.WindowsPath

# For Linux users (or deploying for Linux):
from pathlib import Path
import pathlib
temp = pathlib.WindowsPath
pathlib.WindowsPath = pathlib.PosixPath