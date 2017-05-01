% function to assess ap length in krox20 labelled data from a single plane

%TODO: deal with case when lumen opening is occuring and rhombomeres aren't
%contiguous across the midline

function [imStats, outStats] = apLength(im, pix2um, hfig)

%     im = imread(filename);
    imf = medfilt2(im, [15 15]); % arbitrary smoothing kernel - think through how to choose better. % implement with GPU where supported?
    thr = 4 * quantile(imf(:), 0.75); % also arbitrary threshold scaliing...
    binim = imf > thr;
    
    binim =  imfill(binim, 'holes'); % do some processing
%     binim = imclose(binim, strel('disk', 25)); % AGAIN arbitary strel size...do we need this if we use convex hull?
    
    imStats = regionprops(binim, 'Orientation', 'ConvexHull', ...
        'MajorAxisLength', 'MinorAxisLength', 'Area');
    
    % assume two largest regions are two stained rhombomeres
    [~,sidx] = sort([imStats.Area], 'descend');
    imStats = [imStats(sidx(1)); imStats(sidx(2))];
    
    bwl = bwlabel(binim);
    binim((bwl ~= sidx(1)) & (bwl ~= sidx(2))) = 0;
    
    if ~isempty(hfig)
        set(0, 'currentfigure', hfig)
        imagesc(im);
        colormap gray;
        axis equal tight;
        set(gca, 'XTick', []);
        set(gca, 'YTick', []);
        edges = bwboundaries(binim, 'noholes');
        edge1 = edges{1};
        hp1 = patch(edge1(:,2), edge1(:,1), 'r', 'FaceAlpha', 0.2, ...
            'EdgeColor', 'r', 'LineWidth', 2);
        edge2 = edges{2};
        hp2 = patch(edge2(:,2), edge2(:,1), 'r', 'FaceAlpha', 0.2, ...
            'EdgeColor', 'r', 'LineWidth', 2);
    end
    
    angleToMeasureAlong = mean([imStats.Orientation]);
    binim = imrotate(binim, -angleToMeasureAlong, 'bilinear'); % implement with GPU where supported?
    imStats2 = regionprops(binim); % could calcualte from previous imStats, but why bother...
    
    bboxes = round([imStats2.BoundingBox]);
    oAX = [max([bboxes(1) bboxes(5)]) min([(bboxes(1)+bboxes(3)) (bboxes(5)+bboxes(7))])];
    oAY = round(sort([imStats2(1).Centroid(2) imStats2(2).Centroid(2)]));
    outArray =  binim(oAY(1):oAY(2), oAX(1):oAX(2));
    
    % fill gaps
    outArray = imclose(outArray, strel('disk', 10));
    
    apLengths = size(outArray, 1) - sum(outArray, 1);
    [mn, midx] = min(apLengths);
    outStats.minD = mn*pix2um;
    outStats.meanD = mean(apLengths)*pix2um;
    outStats.medianD = median(apLengths)*pix2um;
    outStats.maxD = max(apLengths)*pix2um;

    % display original image and line showing minimum length
%     imagesc(im); 
%     colormap gray;
%     axis equal tight;
%     set(gca,'xtick',[], 'ytick', [])
    
    
    

    
    
    
    