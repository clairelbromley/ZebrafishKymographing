basePath = 'C:\Users\Doug\Google Drive\Transplant analysis take3';
um = (1:1024) /  9.455;
apical_point = [396, 300, 300, 365, 300, 356] / 9.455;
% apical point in number of pixels
ab_axis = repmat(um, length(apical_point), 1);

dirs = dir([basePath filesep '*.tif']);

for imageInd = 1:length(dirs)
    
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
        abResult(z, :) = max(im,[],1);
        apResult(z, :) = max(im,[],2);
        
    end
    
    figure('Name', dirs(imageInd).name);
    subplot(1,2,1);
    imagesc(squeeze(ab_axis(imageInd,:)) - apical_point(imageInd), (1:length(f)), abResult);
    
    xlim([-500 500]);
    axis equal tight;
    %equal means that 1 count along the y is the same as along x
%     set(gca, 'XTick', []);
%     set(gca, 'YTick', []);
    xlabel('Apical-basal axis position, \mum');
    ylabel('Z plane <- change to \mum?');
    c = colorbar;
    ylabel(c,'GFP signal');
    
    subplot(1,2,2);
    imagesc(um, (1:length(f)), apResult);
    axis equal tight;
%     set(gca, 'XTick', []);
%     set(gca, 'YTick', []);
    xlabel('Anterior-posterior axis position, \mum');
    ylabel('Z plane <- change to z position in \mum?');
    c = colorbar;
    ylabel(c,'GFP signal');
    
end