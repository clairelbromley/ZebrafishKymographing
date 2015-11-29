%FINAL SCRIPT?%
description_string = '1x binning on resultant images';
axBin = 1;
zBin = 1;
pixel_micron_conversion = 9.455;
% clim = [0 10000];
% basePath = 'C:\Users\d.kelly\Google Drive\Transplant analysis take3';
% outputPath = 'C:\Users\d.kelly\Google Drive\Transplant analysis take3\Code\Test results';
% basePath = 'C:\Users\Doug\Google Drive\Transplant analysis take3\Code\DATA';
% outputPath = 'C:\Users\Doug\Google Drive\Transplant analysis take3\Code\Test results';
basePath = 'C:\Users\Doug\Downloads\Data-2015-06-15\Data'
outputPath = 'C:\Users\Doug\Downloads\Data-2015-06-15\Data\Results\1x binning'
mkdir(outputPath);
um = (1:axBin:1024) /  pixel_micron_conversion;
apical_point = [373, 352, 352, 354, 360, 346, 350, 346, 360, 350, 348, 364, 354, 356, 356, 350, 350, 350, 350, 350, 350, 350] / 9.455;
ab_axis = repmat(um, length(apical_point), 1);


dirs = dir([basePath filesep '*.tif']);
if length(dirs) == 0
    errordlg(['No suitable images in the supplied basePath = ' basePath]);
end
resultStruct = [];

aPointWRTBinnedImage = zeros(1,length(dirs));
aPointWRTBinnedCroppedImage = zeros(1,length(dirs));

hwait = waitbar(0, 'Processing images...');


for imageInd = 1:length(dirs)
    
    waitbar(imageInd/length(dirs))
    
    f = imfinfo([basePath filesep dirs(1).name]);
%     figure('Name', dirs(imageInd).name);
    
    abResult = zeros(length(f), f(1).Width);
    apResult = zeros(length(f), f(1).Height);

    for z = 1:length(f)

        im = imread([basePath filesep dirs(imageInd).name], z);

        % Show images in zstack tiled...
%         subplot(3,4,z);
%         imagesc(im);
%         colormap gray;
%         axis equal tight;
%         set(gca, 'XTick', []);
%         set(gca, 'YTick', []);

            % Get (unbinned) results...
            abResult(z, :) = max(im, [],1);
            apResult(z, :) = max(im, [],2);
        
    end
    
    %% Crop results to remove excess zeros...
    abBin = binning(abResult, axBin, zBin);
    aPointWRTBinnedImage(imageInd) = apical_point(imageInd)*pixel_micron_conversion/axBin;
    abCrop = abBin;
    aPointWRTBinnedCroppedImage(imageInd) = aPointWRTBinnedImage(imageInd) - find(~(sum(abCrop,1) == 0), 1)
    abCrop(:, sum(abCrop,1) == 0) = [];
    resultStruct(imageInd).abCrop = abCrop;
    resultStruct(imageInd).abCropSize = size(abCrop)';
    resultStruct(imageInd).maxValue = max(abCrop(:));

    apCrop = apResult;
    apCrop = binning(apCrop, axBin, zBin);
    apCrop(:, sum(apCrop,1) == 0) = [];
    resultStruct(imageInd).apCrop = apCrop;
    resultStruct(imageInd).apCropSize = size(apCrop)';
    resultStruct(imageInd).maxValue = max(apCrop(:));
    
%     %% Display figures
%     figure('Name', dirs(imageInd).name);
%     subplot(2,1,1);
    ab_axis(imageInd,:) = ab_axis(imageInd,:) - apical_point(imageInd);
    ab_temp = ab_axis(imageInd, :);
    ab_temp(sum(abBin,1) == 0) = [];
    resultStruct(imageInd).abAxis = ab_temp;
%     imagesc(ab_temp, (1:length(f)), abCrop, clim);
% %     imagesc(squeeze(ab_axis(imageInd,:)), (1:length(f)), abResult);
% %     xlim([-500 500]);
%     axis equal tight;
% %     set(gca, 'XTick', []);
%     set(gca, 'YTick', []);
%     xlabel('Apical-basal axis position, \mum');
%     ylabel('Z position, \mum');
%     c = colorbar;
%     colormap jet;
%     ylabel(c,'GFP signal');
%     
%     subplot(2,1,2);
%     imagesc(um(1:length(apCrop)), (1:length(f)), apCrop, clim);
%     axis equal tight;
% %     set(gca, 'XTick', []);
%     set(gca, 'YTick', []);
%     xlabel('Anterior-posterior axis position, \mum');
%     ylabel('Z position, \mum');
%     c = colorbar;
%     colormap jet;
%     ylabel(c,'GFP signal');
%     
%     print([outputPath filesep sprintf('%d-%02d-%02d_%d%d%d ', round(clock)) ' ' description_string ' ' dirs(imageInd).name], '-dtiff');
    
end
delete(hwait);


%% Make movie frames for AB images
% Shift apical points to the centre - NEED TO ACCOUNT FOR CROPPING!!!!

padded_results = zeros(uint16(max([resultStruct.abCropSize]')) + [0 2 * uint16(max(aPointWRTBinnedCroppedImage) - min(aPointWRTBinnedCroppedImage))]);
padded_results = repmat(padded_results, 1, 1, length(resultStruct));
new_um = ((1:size(padded_results, 2)) - size(padded_results,2)/2) / pixel_micron_conversion*axBin;
cmax = max([resultStruct.maxValue]);

hwait = waitbar(0, 'Saving output figures...');
starttime = round(clock);
moviefilepath = [outputPath filesep sprintf('%d-%02d-%02d_%d%d%d ', round(clock)) ' Movie ' description_string '.tif']
for frame = 1:length(resultStruct)
    
    waitbar(frame/length(resultStruct), hwait);
    hfig = figure;
    % Save figures
    subplot(2,1,1);
    imagesc(resultStruct(frame).abAxis, (1:2:resultStruct(frame).abCropSize(1)), resultStruct(frame).abCrop, [0 cmax]);
%     imagesc(squeeze(ab_axis(imageInd,:)), (1:length(f)), abResult);
%     xlim([-500 500]);
    axis tight;
%     set(gca, 'XTick', []);
%     set(gca, 'YTick', []);
    xlabel('Apical-basal axis position, \mum');
    ylabel('Z position, \mum');
    c = colorbar;
    colormap jet;
    ylabel(c,'GFP signal');
    
    subplot(2,1,2);
    imagesc(um(1:length(resultStruct(frame).apCrop)), (1:2:resultStruct(frame).apCropSize(1)), resultStruct(frame).apCrop, [0 cmax]);
    axis tight;
%     set(gca, 'XTick', []);
%     set(gca, 'YTick', []);
    xlabel('Anterior-posterior axis position, \mum');
    ylabel('Z position, \mum');
    c = colorbar;
    colormap jet;
    ylabel(c,'GFP signal');
    
    print([outputPath filesep sprintf('%d-%02d-%02d_%d%d%d ', starttime) ' ' description_string ' ' dirs(frame).name], '-dtiff');
    close(hfig);
    
    disp('Just dropping the image in at the LHS of the padded space, the apical point ends up at: ');
    a = uint16(aPointWRTBinnedCroppedImage(frame))
    disp(' which is ');
    b = uint16(size(padded_results,2)/2 - a)
    disp('from the centre of the padded image.');
    padded_results(:,1+b:resultStruct(frame).abCropSize(2)+b, frame) = resultStruct(frame).abCrop;

    % Show movie frames
%     subplot(length(resultStruct), 1, frame);
%     imagesc(new_um, 1:length(resultStruct), squeeze(padded_results(:,:,frame)), [0 cmax]);
%     axis tight;
%     colorbar;
    
    if frame == 1
        imwrite(uint16(squeeze(padded_results(:,:,1))), moviefilepath);
    else
        imwrite(uint16(squeeze(padded_results(:,:,frame))), moviefilepath, 'writemode', 'append');
    end
%     
end
delete(hwait);