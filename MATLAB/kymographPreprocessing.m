function imageStack = kymographPreprocessing(imageStack, metadata)
%kymographPreprocessing applies preprocessing steps to images from 
% timelapse data

% See also quantitativeKymographs

%% -------------------------------------------------------------------
% Remove frames in which scattered light from cut is a problem, based on
% metadata. 
% -------------------------------------------------------------------%%
for ind = 1:ceil(metadata.cutDuration/metadata.frameDuration)
   
    imageStack(:,:,ind+metadata.cutStartFrame) = zeros(size(squeeze(imageStack(:,:,1))));
    
end


for ind = 1:size(imageStack, 3)
    image = squeeze(imageStack(:,:,ind));
    %% -------------------------------------------------------------------
    % EITHER threshold based on median filter OR threshold based on median
    % value
    % -------------------------------------------------------------------%%

    med = median(image(:));
    thresh = ones(size(image))*med;

    % thresh = medfilt2(image, [50 50]);

    image(image < thresh) = 0;

    %% -------------------------------------------------------------------
    % Perform erosion followed by dilation on a binary image to get rid of
    % single pixel noise, then use this binary mask to get rid of single
    % pixel noise in the thresholded data
    % -------------------------------------------------------------------%%

    binary_im = (image > 0);
    se = strel('disk', 1);
    binary_im = imerode(binary_im, se);
    binary_im = imdilate(binary_im, se);
    image(binary_im == 0) = 0;

    imageStack(:,:,ind) = image;
end

