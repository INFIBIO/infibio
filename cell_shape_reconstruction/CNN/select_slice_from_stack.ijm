// Script to extract selected slices from a stack in Fiji (ImageJ)



// Define the range of slices you want to extract

// Iterate through each slice in the specified range
// Recorre el stack de imágenes

// Recorre el stack de imágenes
for (i = 1; i <= 98; i++) {
    setSlice(i);
    
    // Duplicate the current slice to a new image window
    run("Duplicate...", "title=" + i-1);
    
    // Optionally, save each slice as an individual image
   saveAs("png", "C:/Users/uib/Desktop/NN_training/classification/cropped_img/slices/" + i-1 + ".png");
	close();
}

