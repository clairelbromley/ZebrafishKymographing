% import image, perform median filter, threshold, , subtraction, erosion
% and dilation...

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

kym_startx = xcut(1) + (0:num_kyms-1)*(xcut(2)-xcut(1))/num_kyms;
kym_starty = ycut(1) + (0:num_kyms-1)*(ycut(2)-ycut(1))/num_kyms;
deltay = kym_line_len * cos(cut_theta);
deltax = -kym_line_len * sin(cut_theta);
kym_endx = kym_startx + deltax;
kym_endy = kym_starty + deltay;

data_path = 'C:\Users\Doug\Google Drive\DOug- cuts\Eroded 50 pixel MEDIAN THRESHOLDED Frames 30-172 without frames 144-146 of 240815_E9 complete data.tif';

f = imfinfo(data_path);
w = f(1).Width;

for ind=1:length(f)
    
    im = imread(data_path, ind);
    
    if (ind == length(f))
       
        disp('Displaying image')
        imagesc(im);
        colormap gray
        axis equal tight
        h_cutline = line(xcut, ycut, 'LineStyle', '--', 'Color', 'w', 'LineWidth', 3);
        line([kym_startx; kym_endx], [kym_starty; kym_endy], 'Color', 'b')
        
    end
    
    for kpos = 1:num_kyms
        
        if (ind == length(f))
            
            for subkpos = 0:kym_line_width-1
       
                shift = -(kym_line_width-1)/2 + subkpos;
                xshift = shift*cos(cut_theta);
                yshift = shift*sin(cut_theta);
                subk_x = round([kym_startx(kpos); kym_endx(kpos)] + xshift);
                subk_y = round([kym_starty(kpos); kym_endy(kpos)] + yshift);   
                a = improfile(im, subk_x, subk_y);
                
                if (kpos == num_kyms ) && (ind == length(f))
                    line(subk_x, subk_y, 'Color', [1 0 0], 'LineWidth', 1)
                    l = sqrt( (subk_x(1) - subk_x(2))^2 + (subk_y(1) - subk_y(2))^2 )
                    
                end
                
                % opacity supported in 2014b and later??
                %                 line(subk_x, subk_y, 'Color', [1 0 0 0.5], 'LineWidth', 3)

            end
            
        
        end
        
    end
    
end



% h_kymline = line([kym_startx(1); kym_endx(1)], [kym_starty(1); kym_endy(1)], 'Color', 'r', 'LineWidth', 3);