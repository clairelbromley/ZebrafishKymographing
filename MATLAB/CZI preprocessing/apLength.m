% function to assess ap length in krox20 labelled data from a single plane

%TODO: deal with case when lumen opening is occuring and rhombomeres aren't
%contiguous across the midline

function [imStats, outStats, binim] = apLength(im, pix2um, hfig, lastBinIm)

    imf = medfilt2(im, [15 15]); % arbitrary smoothing kernel - think through how to choose better. % implement with GPU where supported?
    thr = 4 * quantile(imf(:), 0.75); % also arbitrary threshold scaliing...
    binim = imf > thr;
    
    binim =  imfill(binim, 'holes'); % do some processing
    
    imStats = regionprops(binim, 'Orientation', 'ConvexHull', ...
        'MajorAxisLength', 'MinorAxisLength', 'Area');
    
    % assume two largest regions are two stained rhombomeres
    [~,sidx] = sort([imStats.Area], 'descend');
    imStats = [imStats(sidx(1)); imStats(sidx(2))];
    
    bwl = bwlabel(binim);
    
    if ~isempty(lastBinIm)
        % if previous mask is provided, check for overlap with 3rd largest
        % mask region: if overlap > 90%, say this is part of rhombomere
        % that is separated from 2nd largest mask region by lumen
        % opening...
        imStats = [imStats(sidx(1)); imStats(sidx(2));...
            imStats(sidx(3))];
        binim((bwl ~= sidx(1)) & (bwl ~= sidx(2)) & ...
            (bwl ~= sidx(3))) = 0;
        thrd = binim(bwl == sidx(3));
        if sum(sum(thrd & lastBinIm)) < 0.9 * sum(thrd(:))
            imStats = imStats(1:2);
            imStats = [imStats(sidx(1)); imStats(sidx(2))];
            binim((bwl ~= sidx(1)) & (bwl ~= sidx(2))) = 0;
        else
            imStats = [imStats(sidx(1)); imStats(sidx(2))];
            binim((bwl ~= sidx(1)) & (bwl ~= sidx(2))) = 0;
        end
    
    
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
        if length(imStats) > 2
            edge3 = edges{3};
            hp3 = patch(edge3(:,2), edge2(:,1), 'r', 'FaceAlpha', 0.2, ...
            'EdgeColor', 'r', 'LineWidth', 2);
        end
    end
    
    % loop next part twice if length(imStats) > 3...
    
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
    outStats.q25D = quantile(apLengths, 0.25) * pix2um;
    outStats.q75D = quantile(apLengths, 0.75) * pix2um;
    outStats.maxD = max(apLengths)*pix2um;
    a = imcrop(binim, imStats2(1).BoundingBox);
    outStats.stainedR1Length = mean(sum(a, 1))*pix2um;
    outStats.stainedR1Width = mean(sum(a,2))*pix2um;
    a = imcrop(binim, imStats2(2).BoundingBox);
    outStats.stainedR2Length = mean(sum(a, 1))*pix2um;
    outStats.stainedR2Width = mean(sum(a,2))*pix2um;
    

    % display original image and line showing minimum length
%     imagesc(im); 
%     colormap gray;
%     axis equal tight;
%     set(gca,'xtick',[], 'ytick', [])
    
    
    

    
    
    
    