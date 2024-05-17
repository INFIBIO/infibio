%% Input and output info
imgpath = 'C:\Users\uib\Desktop\diploid-spor diff\Network_training_IMAGES\';
datapath = [imgpath,'data/'];
imgextension = 'tif'; %make sure you use single quotation marks, e.g. 'tif', and not double, e.g. "tif". String concatenation is different
myfiles = dir([imgpath,'*.',imgextension]);
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
    features = regionprops(BW, "BoundingBox");

    %read new image
    
    features_modified = segmentationGUI(img, paramSegment, features);
    saveCorrectedImageAndAnnotations(img, features_modified, imgpath)
end
