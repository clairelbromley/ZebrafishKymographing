% import image, perform median filter, threshold, , subtraction, erosion
% and dilation...
%TODO: do preprocessing in Matlab
%TODO: increase speed (? check in profiling) by removing improfile which is time-hungry, and
%instead cutting out a region of the plot around the cut, rotating it, and
%taking straight kymographs straight from the resulting array without any
%need to interpolate in improfile
%TODO: DON'T CUT OUT "CUT" frames because this leads to misleading
%kymographs; instead, set cut frames to zero so that it's obvious that time
%is passing but something is going on. Can do this from metadata (round
%time value up to nearest 200 ms and divide by 200 ms to get no frames) OR
%by looking at mean frame intensity and setting a threshold above which the
%whole frame is set to zero. 

% import dimension metadata
framespersecond = 5;
umperpixel = 0.218;
scalebarum = 10;

% import cut position from metadata - add offset??
xoffset = -20;
yoffset = -20;
xcut = [213 276] + xoffset;
ycut = [279 308] + yoffset;
cut_theta = atan( ( ycut(2)-ycut(1) )/( xcut(2) - xcut(1) ) );

% generate maximum intensity kymographs - USE IMPROFILE!!!
kym_line_len = 50;
kym_line_width = 9;
num_kyms = 15;
% TODO: extend range of kymographs beyond cut to get stationary regions
% TODO: other side of kymograph

kym_startx = xcut(1) + (-1:num_kyms-2)*1.3*(xcut(2)-xcut(1))/num_kyms;
kym_starty = ycut(1) + (-1:num_kyms-2)*1.3*(ycut(2)-ycut(1))/num_kyms;
deltay = kym_line_len * cos(cut_theta);
deltax = -kym_line_len * sin(cut_theta);
kym_endx = kym_startx + deltax;
kym_endy = kym_starty + deltay;

data_path = 'C:\Users\Doug\Google Drive\DOug- cuts\Eroded 50 pixel MEDIAN THRESHOLDED Frames 30-172 without frames 144-146 of 240815_E9 complete data.tif';

f = imfinfo(data_path);
w = f(1).Width;

max_kym_stack = ones(length(f), kym_line_len - 5, num_kyms);
avg_kym_stack = max_kym_stack;

for ind=1:length(f)
    
    im = imread(data_path, ind);
    
    if (ind == length(f)) || (ind == 1)
        
        if (ind == 1)
            imind = 1
        else
            imind = 2
        end
       
        disp('Displaying image');
        subplot(2,3,3*imind-2);
        imagesc(im);
        colormap gray
        axis equal tight
        h_cutline = line(xcut, ycut, 'LineStyle', '--', 'Color', 'w', 'LineWidth', 3);
        line([kym_startx; kym_endx], [kym_starty; kym_endy], 'Color', 'b')
        scx = [500-scalebarum/umperpixel 500];
        scy = 500;
        scline = line(xsc, ysc, 'Color', 'w', 'LineWidth', 3);
        scstr = [num2str(scalebarum) ' \mu m'];
        sctxt = text(scx(1), 485, scstr);
        set(sctxt, 'Color', 'w');
        set(sctxt, 'FontSize', 14);
        
    end
    
    for kpos = 1:num_kyms
        
%         if (ind == length(f))
            
            subk = zeros(kym_line_len, kym_line_width);            
            
            for subkpos = 0:kym_line_width-1
       
                shift = -(kym_line_width-1)/2 + subkpos;
                xshift = shift*cos(cut_theta);
                yshift = shift*sin(cut_theta);
                subk_x = round([kym_startx(kpos); kym_endx(kpos)] + xshift);
                subk_y = round([kym_starty(kpos); kym_endy(kpos)] + yshift);   
                a = improfile(im, subk_x, subk_y);
                l = length(a);
                subk(1:l, subkpos+1) = a;
                
%                 if (kpos == num_kyms ) && (ind == length(f))
%                     line(subk_x, subk_y, 'Color', [1 0 0], 'LineWidth', 1)
% %                     l = sqrt( (subk_x(1) - subk_x(2))^2 + (subk_y(1) - subk_y(2))^2 )
%                     
%                 end
                
                % opacity supported in 2014b and later??
                %                 line(subk_x, subk_y, 'Color', [1 0 0 0.5], 'LineWidth', 3)

            end
            
            avg_kym = mean(subk, 2);
            max_kym = max(subk, 2);
            
            max_kym_stack(ind, :, kpos) = max_kym(1:kym_line_len-5);
            avg_kym_stack(ind, :, kpos) = avg_kym(1:kym_line_len-5);
            
%         end
        
    end
    
end

for kpos = 1:num_kyms
    
    xt = (1/framespersecond)*((-143:size(avg_kym_stack,1)-143));
    yt = umperpixel*(1:size(avg_kym_stack,2));
    subplot(num_kyms, 3, kpos*3 - 1)
    imagesc(xt, yt, squeeze(max_kym_stack(:,:,kpos))');
    axis equal tight;
    subplot(num_kyms, 3, kpos*3);
    imagesc(xt, yt, squeeze(avg_kym_stack(:,:,kpos))');
    axis equal tight;
    xlabel('Time relative to cut, s')
    ylabel('Position relative to cut, \mum')
%     colormap jet
    
end

% % %% TO GET QUANTITATIVE DATA FROM KYMOGRAPHS
% % % for kpos = 1:num_kyms
% % for kpos = 1:10
% % % - trim kymograph - initially first 20 frames (=4 seconds)
% %     kym_segment = squeeze(avg_kym_stack(144:164,:,kpos))';
% % % - use canny edge filter to get binary image of membrane front movement
% %     filt_kym = edge(kym_segment, 'canny');
% % % - choose the highest edge to represent the membrane front, extract t, d
% % % co-ordinates for this edge...
% %     t = []; d = [];
% %     for tind = 1:size(filt,1)
% %         point_sel = false;
% %         
% %         for dind = 1:size(filt,2)
% %             
% %            if (not(point_sel)) && ( filt(tind, dind) > 0 )
% %                point_sel = true;
% %                filt_kym(tind, dind) = 1;
% %            else
% %                filt_kym(tind, dind) = 0;
% %            end
% %            
% %         end
% %         
% %     end
% %     
% %     figure;
% %     subplot(1,4,1);
% %     imagesc(kym_segment);
% %     axis equal tight;
% %     subplot(1,4,2);
% %     imagesc(filt_kym); 
% %     axis equal tight; 
% %     colormap gray;
% %     subplot(1,4,3);
% %     l = bwlabel(filt_kym);
% %     imagesc(l);
% %     r = regionprops(filt_kym);
% %     % Sort regions by y position (centroid)
% %     dpos = [];
% %     for i = 1:length(r)
% %         dpos = [dpos; r(i).Centroid(2)];
% %     end
% %     [dpos, I] = sort(dpos);
% %     % Then check the time extent of the trace for each of these in order;
% %     % the first one that is found that extends more than 80% of the trace
% %     % is considered to be the right one
% %     found = false;
% %     i = 1;
% %     while (found == false)
% %         
% %         if (r(I(i)).BoundingBox(3) > size(filt_kym,2)*.8)
% %             found = true;
% %         else
% %             ++i;
% %         end
% %     end
% %     correct_membrane = (l == I(i));
% %     subplot(1,4,4);
% %     imagesc(correct_membrane);
% %         
% % 
% % % - fit curve to this data (first order is a straight line, goodness of fit
% % % tells us how linear motion actually is, discuss with supervisors what
% % % alternative models to fit)
% % % - convert to um/second
% % 
% % 
% % end
% % % OUTPUT FOR SUPERVISORS:
% % % 
% % 
% % % h_kymline = line([kym_startx(1); kym_endx(1)], [kym_starty(1); kym_endy(1)], 'Color', 'r', 'LineWidth', 3);