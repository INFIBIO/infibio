# Featuring and Tracking yeast cells

do_features_extraction_bw.m script analyse the previously segmented and classified raw images with the YOLO CNN.

  - For each image: 
      > calculate parameters for each feature like centroid position, area, etc.
      > trace the boundary and return a spline fit for the boundary shape (together with other goodies, check functions' preambles)
  - track the features across the frames
  - save everything

## TO DO: 
- track the changes in orientation of the objects
- write "pull" functions to pull specific sets of observables for a specific object, along the whole movie.

# Notes
The script do_features_extraction.m is the original developed that expects raw images as input. It's been left to have the originals analysis in case it's necessary to step back.
