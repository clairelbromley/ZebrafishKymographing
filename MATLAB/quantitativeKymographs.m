%% TO GET QUANTITATIVE DATA FROM KYMOGRAPHS
% for kpos = 1:num_kyms
for kpos = 1:10
% - trim kymograph - initially first 20 frames (=4 seconds)
    kym_segment = squeeze(avg_kym_stack(144:164,:,kpos))';
% - use canny edge filter to get binary image of membrane front movement
    filt_kym = edge(kym_segment, 'canny');
% - choose the highest edge to represent the membrane front, extract t, d
% co-ordinates for this edge...
    t = []; d = [];
    for tind = 1:size(filt,1)
        point_sel = false;
        
        for dind = 1:size(filt,2)
            
           if (not(point_sel)) && ( filt(tind, dind) > 0 )
               point_sel = true;
               filt_kym(tind, dind) = 1;
           else
               filt_kym(tind, dind) = 0;
           end
           
        end
        
    end
    
    figure;
    subplot(1,4,1);
    imagesc(kym_segment);
    axis equal tight;
    subplot(1,4,2);
    imagesc(filt_kym); 
    axis equal tight; 
    colormap gray;
    subplot(1,4,3);
    l = bwlabel(filt_kym);
    imagesc(l);
    r = regionprops(filt_kym);
    % Sort regions by y position (centroid)
    dpos = [];
    for i = 1:length(r)
        dpos = [dpos; r(i).Centroid(2)];
    end
    [dpos, I] = sort(dpos);
    % Then check the time extent of the trace for each of these in order;
    % the first one that is found that extends more than 80% of the trace
    % is considered to be the right one
    found = false;
    i = 1;
    while (found == false)
        
        if (r(I(i)).BoundingBox(3) > size(filt_kym,2)*.8)
            found = true;
        else
            i=i+1;
        end
    end
    correct_membrane = (l == I(i));
    subplot(1,4,4);
    imagesc(correct_membrane);
        

% - fit curve to this data (first order is a straight line, goodness of fit
% tells us how linear motion actually is, discuss with supervisors what
% alternative models to fit)
% - convert to um/second


end
% OUTPUT FOR SUPERVISORS:
% 

% h_kymline = line([kym_startx(1); kym_endx(1)], [kym_starty(1); kym_endy(1)], 'Color', 'r', 'LineWidth', 3);