function kymographs = plotAndSaveKymographsSlow(stack, metadata, userOptions)

md = metadata;
uO = userOptions;

for ind = 1:size(stack, 3)
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

            end
            
            if uO.avgOrMax == 1
                avg_kym = mean(subk, 2);
                avg_kym_stack(ind, :, kpos) = avg_kym(1:kym_line_len-5);
            else                               
                max_kym = max(subk, 2);
                max_kym_stack(ind, :, kpos) = max_kym(1:kym_line_len-5);
            end
        
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

end