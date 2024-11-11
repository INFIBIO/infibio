// Define the positions of the areas
regions = newArray("0,0", "640,0", "1280,0","0,576", "640,576", "1280,576");
// This array defines six starting coordinates (x, y) for cropping regions on the image. 
// Each entry corresponds to the upper-left corner of a 640x640 pixel area on the image.

// Temporary directory to save cropped images
tempDir = "C:/Users/uib/Desktop/NN training/classification/cropped_img/";
// Specifies the folder path where cropped images will be saved.
// Ensure this path exists on your machine or modify it accordingly.

// Create the temporary directory if it does not exist
File.makeDirectory(tempDir);
// This line creates the folder specified in 'tempDir' if it doesn't already exist.

// Iterate through the image stack
for (i = 1; i <= nSlices; i++) {  
    // Loops through each slice in the image stack. 
    // `nSlices` should be defined as the total number of images in the stack.

    setSlice(i);  
    // Activates the current slice (i-th slice) in the stack.

    for (j = 0; j < regions.length; j++) {
        // Loops through each predefined region from the 'regions' array.
        
        coordinates = split(regions[j], ",");
        // Splits the region's string (e.g., "640,0") into two values: x and y coordinates.
        
        x = parseInt(coordinates[0]);
        y = parseInt(coordinates[1]);
        // Converts the split values into integers for x and y positions.
        
        makeRectangle(x, y, 640, 640);
        // Defines a rectangular area with the upper-left corner at (x, y) 
        // and a size of 640x640 pixels for cropping.
        
        run("Duplicate...", "title=Area_" + j + "_slice_" + i);
        // Creates a duplicate of the specified rectangular region.
        // Names the duplicate based on its region and slice, e.g., "Area_0_slice_1".
        
        saveAs("Tiff", tempDir + "Area_" + j + "_slice_" + i + ".png");
        // Saves the duplicated area as a TIFF file in the specified directory.
        // The file is named based on its area and slice, e.g., "Area_0_slice_1.png".
        
        close();
        // Closes the duplicated image to free up memory.
    }
}
