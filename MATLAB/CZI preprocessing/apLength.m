% function to assess ap length in krox20 labelled data from a single plane

%TODO: deal with case when lumen opening is occuring and rhombomeres aren't
%contiguous across the midline

function [imStats, outStats, thisBinIm] = apLength(im, pix2um, hfig, prevBinIm)

    %% process image to find krox20-labelled rhombomeres
    imf = medfilt2(im, [15 15]); % maximum kernel that would allow GPU operation. Empirically looks OK. 
    thr = 3 * quantile(imf(:), 0.75); % Emprically determined threshold
    binim = imf > thr;
    binim =  imfill(binim, 'holes'); % aim for contiguous regions
    
    % assume two largest contiguous regions are two stained rhombomeres -
    % unless previous mask has been passed, in which case check whether
    % next largest region corresponds >90% with previous rhombomere region,
    % AND is greater than 40% of the area of the largest region, 
    % suggesting that it's one rhombomere split by lumen opening
    
    %TODO: deal with case when BOTH rhombomeres split to give 4 relevant
    %areas
    imStats = regionprops(binim, 'Orientation', 'ConvexHull', ...
        'MajorAxisLength', 'MinorAxisLength', 'Area');
    [~,sidx] = sort([imStats.Area], 'descend');
    bwl = bwlabel(binim);
    
    % TODO: error checking for case when too few regions are found
    lumenOpening = false;
    if length(sidx) > 2
        thirdLargestA = binim;
        thirdLargestA( (bwl ~= sidx(3)) ) = 0;
        areaCheck = (imStats(sidx(3)).Area > 0.4 * imStats(sidx(1)).Area);
    else
        thirdLargestA = zeros(size(binim));
        areaCheck = false;
    end
    
    if ~isempty(prevBinIm)
        if areaCheck && (sum(thirdLargestA(:) & prevBinIm(:)) > 0.7 * sum(thirdLargestA(:)))
%             beep;
            lumenOpening = true;
            imStats = [imStats(sidx(1)); imStats(sidx(2)); imStats(sidx(3))];
            binim((bwl ~= sidx(1)) & (bwl ~= sidx(2)) & (bwl ~= sidx(3))) = 0;
        else
            imStats = [imStats(sidx(1)); imStats(sidx(2))];
            binim((bwl ~= sidx(1)) & (bwl ~= sidx(2))) = 0;
        end
    else
        imStats = [imStats(sidx(1)); imStats(sidx(2))];
        binim((bwl ~= sidx(1)) & (bwl ~= sidx(2))) = 0;
    end
    
    %% if figure handle passed, update display - useful for debug/demo
    if ~isempty(hfig)
        % TODO: make edges/patches more general, for >2 regions
        set(0, 'currentfigure', hfig)
        imagesc(im);
        colormap gray;
        axis equal tight;
        set(gca, 'XTick', []);
        set(gca, 'YTick', []);
        edges = bwboundaries(binim, 'noholes');
        hps = [];
        for ridx = 1:length(imStats)
            edge = edges{ridx};
            hp = patch(edge(:,2), edge(:,1), 'r', 'FaceAlpha', 0.2, ...
                'EdgeColor', 'r', 'LineWidth', 2);
            hps = [hps; hp];
        end
    end
    
    %% define axis ~perpendicular to edges and get distance between actual
    % edges of mask (i.e. don't fit an edge)
    apLengths = [];
    for regidx = 2:(length(imStats))
        angleToMeasureAlong = mean([imStats(1).Orientation imStats(regidx).Orientation]);
        rbinim = imrotate(binim, -angleToMeasureAlong, 'bilinear'); % implement with GPU where supported?
        imStats2 = regionprops(rbinim); 
        % sort by area
        [~,sidx] = sort([imStats2.Area], 'descend');
        bboxes = round([imStats2(sidx(1)).BoundingBox; imStats2(sidx(regidx)).BoundingBox]);
        oAX = [max([bboxes(1) bboxes(5)]) min([(bboxes(1)+bboxes(3)) (bboxes(5)+bboxes(7))])];
        oAY = round(sort([imStats2(1).Centroid(2) imStats2(regidx).Centroid(2)]));
        outArray =  rbinim(oAY(1):oAY(2), oAX(1):oAX(2));
        outArray = imclose(outArray, strel('disk', 10)); % fill gaps
        apLengths = [apLengths (size(outArray, 1) - sum(outArray, 1))];
    end
    
    %% calculate summary stats to describe distances between edges
    [mn, midx] = min(apLengths);
    outStats.minD = mn*pix2um;
    outStats.meanD = mean(apLengths)*pix2um;
    outStats.medianD = median(apLengths)*pix2um;
    outStats.maxD = max(apLengths)*pix2um;
    outStats.q25D = quantile(apLengths, 0.25) * pix2um;
    outStats.q75D = quantile(apLengths, 0.75) * pix2um;
    a = imcrop(binim, imStats2(1).BoundingBox);
    outStats.stainedR1Length = mean(sum(a, 1))*pix2um;
    outStats.stainedR1Width = mean(sum(a,2))*pix2um;
    a = imcrop(binim, imStats2(2).BoundingBox);
    outStats.stainedR2Length = mean(sum(a, 1))*pix2um;
    outStats.stainedR2Width = mean(sum(a,2))*pix2um;

    thisBinIm = binim;
    % display original image and line showing minimum length
%     imagesc(im); 
%     colormap gray;
%     axis equal tight;
%     set(gca,'xtick',[], 'ytick', [])