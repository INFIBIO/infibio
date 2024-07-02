function [features] = run_yolo_img(img,props)

    % Load the image
    pyenv('Version', 'C:\Users\uib\anaconda3\envs\yolov5-env\python.exe');
    
    % Localize bbox in the image
    for k = 1 : length(props)
        rectangle('Position', props(k).BoundingBox, 'EdgeColor', 'r');
    end
    hold off;
    
    
    % Define paths to Python executable and script
    python_executable = 'C:/Users/uib/anaconda3/envs/yolov5-env/python.exe';
    detect_script = 'C:/Users/uib/Desktop/CSIC_IARB/CSIC_IARB/new_batch/yolov5/classify/predict.py';
    weights = 'C:/Users/uib/Desktop/CSIC_IARB/CSIC_IARB/new_batch/yolov5/runs/train-cls/exp13/weights/best.pt';
    img_size = 128;
    
    % Add a new field to props to store detected classes
    [props.DetectedClass] = deal('');
    
    % Apply yolov5 model to classify the bbox
    for k = 1:length(props)
        % Crop the image to the bounding box
        bbox = round(props(k).BoundingBox);
        cropped_img = imcrop(img, bbox);
        cropped_img = imadjust(cropped_img);
        % Save the cropped image to a temporary file
        temp_img_path = fullfile(tempdir, sprintf('temp_image_%d.png', k));
        imwrite(cropped_img, temp_img_path);
    
        % Adjust the paths to be compatible with Windows
        temp_img_path = strrep(temp_img_path, '/', '//');
        %results = model(py.list({temp_img_path}));
    
        % Construct the Python command
        python_cmd = sprintf('%s %s --weights %s --img %d --source %s --save-txt', python_executable, detect_script, weights, img_size,  temp_img_path);
    
        % Execute the Python command
        status = system(python_cmd);
    
        % Check if the command executed correctly
        if status == 0
            disp(['Python script executed correctly for bbox ' num2str(k)]);
        else
            disp(['Error executing Python script for bbox ' num2str(k)]);
            continue;
        end
        % Find the latest exp folder in the runs/detect directory
        detect_dir = 'C:\Users\uib\Desktop\CSIC_IARB\CSIC_IARB\new_batch\yolov5\runs\predict-cls';
        exp_dirs = dir(fullfile(detect_dir, 'exp*'));
        [~, idx] = max([exp_dirs.datenum]);
        latest_exp_dir = fullfile(detect_dir, exp_dirs(idx).name);
        % Load the detected classes from the .mat file
        detected_classes_file = fullfile(latest_exp_dir, 'labels\', sprintf('temp_image_%d.txt', k));
    
    
        if isfile(detected_classes_file)
            % Read the file contents
            fileID = fopen(detected_classes_file, 'r');
            fileContent = textscan(fileID, '%f %f', 'Delimiter', ' ');
            fclose(fileID);
    
            % Get the last number of the first row
            if ~isempty(fileContent{1})
                first_row_last_number = fileContent{2}(1);
                props(k).DetectedClass = first_row_last_number;
            else
                disp('The file is empty or does not contain the expected structure.');
                props(k).DetectedClass = 'ND';  % Return original props if there's no detection results
            end
            rmdir(latest_exp_dir, 's');
        end
    end
    features = props;
end

