% Path to the Python executable
pythonPath = 'C:\Users\xisca\anaconda3\envs\yolov5-env\python.exe';

% Set the Python environment in MATLAB
pyenv('Version', pythonPath);

% Verify the configuration
disp(pyenv);