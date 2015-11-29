mean_window = 50

raw_data_path = 'C:\Users\Doug\Google Drive\DOug- cuts\Frames 30-172 without frames 144-146 of 240815_E9 complete data.tif';
mean_data_path = sprintf('C:\\Users\\Doug\\Google Drive\\DOug- cuts\\%d pixel median filter Frames 30-172 without frames 144-146 240815_E9 complete data.tif', mean_window);
output_path = sprintf('C:\\Users\\Doug\\Google Drive\\DOug- cuts\\Eroded %d pixel MEDIAN THRESHOLDED Frames 30-172 without frames 144-146 of 240815_E9 complete data.tif', mean_window);

disp(mean_data_path)

f = imfinfo(raw_data_path);
disp(length(f))

for ind = 1:length(f)
    
   disp(ind)
   % read data in
   im = imread(raw_data_path, ind);
   thresh_im = imread(mean_data_path, ind);
   % apply threshold such that if intensity is less than rolling median,
   % the pixel is set to zero
   im(im < thresh_im) = 0;
    
   % Perform erosion followed by dilation on a binary image to get rid of
   % single pixel noise, then use this binary mask to get rid of single
   % pixel noise in the thresholded data
   bin_image = (im > 0);
   se = strel('disk', 1);
   bin_image = imerode(bin_image, se);
   bin_image = imdilate(bin_image, se);
   im(bin_image == 0) = 0;

   % TODO: rotate image so that midline is straight across the image
   % horizontally, then perform a kymograph along an axis perpendicular to
   % the midline, taking the maximal intensity over a ?9 pixel? region
   % perpendicular to the kymograph axis to account for membrane movement
   % parallel to the cut. Try performing this for all positions along the
   % cut axis (beyond the start and end of the cut position) and output to
   % a TIFF stack, then allowing the user to choose the best kymographs at
   % various positions. Record these positions. 
   
   % From kymographs, we need to extract speed data - average speed?
   % Fitting a line would be easiest? 
   
   % OUTPUT: a figure with the kymograph axes plotted relative the the
   % original data (first frame?) and multiple kymographs. 
   
   % save resulting image
    if ind == 1
        imwrite(uint16(im), output_path)
    else
        imwrite(uint16(im), output_path, 'writemode', 'append');
    end
    
    
end