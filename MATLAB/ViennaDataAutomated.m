% import image, perform median filter, threshold, , subtraction, erosion
% and dilation...
%TODO: do preprocessing in Matlab
%TODO: DON'T CUT OUT "CUT" frames because this leads to misleading
%kymographs; instead, set cut frames to zero so that it's obvious that time
%is passing but something is going on. Can do this from metadata (round
%time value up to nearest 200 ms and divide by 200 ms to get no frames) OR
%by looking at mean frame intensity and setting a threshold above which the
%whole frame is set to zero. 

% import cut position from metadata - add offset??
xoffset = -20;
yoffset = -20;
xcut = [213 276] + xoffset;
ycut = [279 308] + yoffset;
cut_theta = atan( ( ycut(2)-ycut(1) )/( xcut(2) - xcut(1) ) );

% generate maximum intensity kymographs - USE IMPROFILE!!!
kym_line_len = 50;
kym_line_width = 9;
num_kyms = 11;
% TODO: extend range of kymographs beyond cut to get stationary regions
% TODO: other side of kymograph

kym_startx = xcut(1) + (0:num_kyms-1)*(xcut(2)-xcut(1))/num_kyms;
kym_starty = ycut(1) + (0:num_kyms-1)*(ycut(2)-ycut(1))/num_kyms;
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
    
    subplot(num_kyms, 3, kpos*3 - 1)
    imagesc(squeeze(max_kym_stack(:,:,kpos))');
    axis equal tight;
    subplot(num_kyms, 3, kpos*3);
    imagesc(squeeze(avg_kym_stack(:,:,kpos))');
    axis equal tight;
%     colormap jet
    
end

% TO GET QUANTITATIVE DATA FROM KYMOGRAPHS
% - trim kymograph - initially first 20 frames (=4 seconds)
% - use canny edge filter to get binary image of membrane front movement
% - choose the highest edge to represent the membrane front
% - extract t,y coordinates of this edge
% - fit curve to this data (first order is a straight line, goodness of fit
% tells us how linear motion actually is, discuss with supervisors what
% alternative models to fit)
% - convert to um/second

% OUTPUT FOR SUPERVISORS:
% 

% h_kymline = line([kym_startx(1); kym_endx(1)], [kym_starty(1); kym_endy(1)], 'Color', 'r', 'LineWidth', 3);