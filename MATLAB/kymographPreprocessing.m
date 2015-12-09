function [stack, kym_region] = kymographPreprocessing(stack, metadata, kym_region, userOptions)
%kymographPreprocessing applies preprocessing steps to images from 
% timelapse data

% See also quantitativeKymographs

md = metadata;
kp = kym_region;
uO = userOptions;
dir_txt = sprintf('%s, Embryo %s', md.acquisitionDate, md.embryoNumber);

if ~isdir([uO.outputFolder filesep dir_txt]) && (uO.savePreprocessed)
    mkdir([uO.outputFolder filesep dir_txt])
end

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
% tic
% disp('Rotating...')
% stack = imrotate(stack, radtodeg(md.cutTheta));
% t = toc;
% timeStr = sprintf('Rotating E%s C%d took %f seconds', md.embryoNumber, md.cutNumber, t);
% errorLog(uO.outputFolder, timeStr);

%DEBUG - check that cut is in right place on processed image...
firstFigure(squeeze(stack(:,:,1)), md, uO, true);

if uO.savePreprocessed
    
    output_path = [uO.outputFolder filesep dir_txt filesep sprintf('trimmed_stack_cut_%d.tif', md.cutNumber)];
    for ind = 1:size(stack, 3)
        if ind == 1
            imwrite(uint16(squeeze(stack(:,:,ind))), output_path);
        else
            imwrite(uint16(squeeze(stack(:,:,ind))), output_path, 'writemode', 'append');
        end
    end
    
    c = struct2cell(kp);
    f = fields(kp);
    
    cutDataPath = [uO.outputFolder filesep dir_txt filesep sprintf('trimmed_cutinfo_cut_%d.txt', md.cutNumber)];
    fid = fopen(cutDataPath, 'wt');
    for ind = 1:length(f)
        fprintf(fid, '%s\t', f{ind});
        nc = c{ind};
        for jind = 1:length(nc)
            if isfloat(nc(jind))
                fprintf(fid, '%f\t', nc(jind));
            else
                fprintf(fid, '%d\t', nc(jind));
            end
        end
        fprintf(fid, '\r\n');
    end
    fclose(fid);
    
end

