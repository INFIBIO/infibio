# YeaZ: yeast segmentation.

The original YeaZ repository can be found clicking here[https://github.com/rahi-lab/YeaZ-GUI]. This one uploaded is modified to avoid the tracking step since we're not interested on it. The folder located in \Lib\site-packages\yeaz\unet contains the main scripts.
retrain_model and retrain_model_V2 are the scripts used to retrain the CNN from their weights. In the weights folder is necessary to modify the names to add the .pth extension so the retraining scripts can read the weights, but to run the segmentation in the GUI, is necessary to delete it.
At the moment, it seems that the CNN is being retrained, but when you run the segmentation through the GUI, doesn't seem to work. 

Some key points:
- I think it's better to download the YeaZ - GUI from it's original repo and install it through anaconda, and then change the folder for those here uploaded.
- Only it's necessary to copy the site-packages folder in \YeaZ\Lib\
- It's necessary to modify the neural_network.py line 68 and LaunchBatchPrediction.py in line 51-56 to add more image type options, which in practice is the way to select the weights for the model.
