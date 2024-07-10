%% Input and output info
imgpath = 'C:\Users\alvar\Desktop\Network_training_IMAGES\already_labeled\';
datapath = [imgpath, 'data/'];
annotationsFile = fullfile(datapath, 'annotations.json');
imgextension = 'tif';
myfiles = dir([imgpath, '*.', imgextension]);
%% Parameter definition
%%Segmentation
invert = 1;
paramSegment.int_threshold = 2.325310e+04;
paramSegment.mode_threshold = 5e4;
paramSegment.arearange = [2000,inf];
paramSegment.morph_close_radius = 3;
for tt = 1:length(myfiles)
    
    if mod(tt-1,10)==0
        disp(['Extracting features from frame ',num2str(tt),' out of ',num2str(length(myfiles))]);
    end
    img = imread([imgpath,myfiles(tt).name]);
    if invert
        img = imcomplement(img);
    end
    [BW, maskedImage] = segmentImage_AR(img, paramSegment);
    features = regionprops(BW, "BoundingBox", "PixelIdxList");

    %read new image
    
    features_modified = segmentationGUI(img, paramSegment, features, tt);
    saveCorrectedImageAndAnnotations2(img, features_modified, imgpath, tt, annotationsFile);

end
