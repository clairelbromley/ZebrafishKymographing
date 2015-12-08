function [stack, kym_region] = kymographPreprocessing(stack, metadata, kym_region, userOptions)
%kymographPreprocessing applies preprocessing steps to images from 
% timelapse data

% See also quantitativeKymographs

md = metadata;
kp = kym_region;
uO = userOptions;

%% First, trim image to fit around the kymograph regigon
tic
disp('Trimming...')
stack = stack(kp.boundingBox_LTRB(2):kp.boundingBox_LTRB(4),...
    kp.boundingBox_LTRB(1):kp.boundingBox_LTRB(3),:);
t = toc;
timeStr = sprintf('Trimming E%s C%d took %f seconds', md.embryoNumber, md.cutNumber, t);
errorLog(uO.outputFolder, timeStr);

%% Then perform median filtering
tic
disp('Median filtering...')
for ind = 1:size(stack, 3)
    image = squeeze(stack(:,:,ind));
    %% -------------------------------------------------------------------
    % EITHER threshold based on median filter OR threshold based on median
    % value
    % -------------------------------------------------------------------%%

%     med = median(image(:));
%     thresh = ones(size(image))*med;

    thresh = medfilt2(image, [50 50]);

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

    stack(:,:,ind) = image;
end
t = toc;
timeStr = sprintf('Median filtering E%s C%d took %f seconds', md.embryoNumber, md.cutNumber, t);
errorLog(uO.outputFolder, timeStr);

%% Finally rotate image so that kymographs lie along a vertical column of 
%  pixels...
tic
disp('Rotating...')
stack = imrotate(stack, radtodeg(md.cutTheta));
t = toc;
timeStr = sprintf('Rotating E%s C%d took %f seconds', md.embryoNumber, md.cutNumber, t);
errorLog(uO.outputFolder, timeStr);

