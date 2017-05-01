% function to assess ap length in krox20 labelled data from a single plane

function outStats = apLength(filename, pix2um)

    im = imread(filename);
    imf = medfilt2(im, [15 15]); % arbitrary smoothing kernel - think through how to choose better. % implement with GPU where supported?
    thr = 4 * median(imf(:)); % also arbitrary threshold scaliing...
    binim = imf > thr;
    
    binim =  imfill(binim, 'holes'); % do some processing
%     binim = imclose(binim, strel('disk', 25)); % AGAIN arbitary strel size...do we need this if we use convex hull?
    
    stats = regionprops(binim, 'Orientation', 'ConvexHull', ...
        'MajorAxisLength', 'MinorAxisLength', 'Area');
    
    % assume two largest regions are two stained rhombomeres
    [~,sidx] = sort([stats.Area], 'descend');
    stats = [stats(sidx(1)); stats(sidx(2))];
    
    bwl = bwlabel(binim);
    binim((bwl ~= sidx(1)) & (bwl ~= sidx(2))) = 0;
%     imagesc(binim);
%     colormap gray;
    
%     line(stats(2).ConvexHull(:,1), stats(2).ConvexHull(:,2), ...
%         'Color', 'r', 'LineWidth', 2)
%     line(stats(1).ConvexHull(:,1), stats(1).ConvexHull(:,2), ...
%         'Color', 'r', 'LineWidth', 2)
    
    angleToMeasureAlong = mean([stats.Orientation]);
    binim = imrotate(binim, -angleToMeasureAlong, 'bilinear'); % implement with GPU where supported?
    stats2 = regionprops(binim); % could calcualte from previous stats, but why bother...
    
    bboxes = round([stats2.BoundingBox]);
    oAX = [max([bboxes(1) bboxes(5)]) min([(bboxes(1)+bboxes(3)) (bboxes(5)+bboxes(7))])];
    oAY = round(sort([stats2(1).Centroid(2) stats2(2).Centroid(2)]));
    outArray =  binim(oAY(1):oAY(2), oAX(1):oAX(2));
    
    % fill gaps
    outArray = imclose(outArray, strel('disk', 10));
    
    apLengths = size(outArray, 1) - sum(outArray, 1);
    [mn, midx] = min(apLengths)
    outStats.minD = mn*pix2um;
    outStats.meanD = mean(apLengths)*pix2um;
    outStats.medianD = median(apLengths)*pix2um;

    % display original image and line showing minimum length
%     imagesc(im); 
%     colormap gray;
%     axis equal tight;
%     set(gca,'xtick',[], 'ytick', [])
    
    
    

    
    
    
    