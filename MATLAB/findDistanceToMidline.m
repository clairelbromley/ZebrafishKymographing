function md = findDistanceToMidline(stack, md)

    kp = md.kym_region;

    %% Extrapolate perpendicular bisector of the cut to edge of image
    num_kym = length(kp.kym_starty);
    centre_ind = ceil(num_kym/2);
    m = (kp.kym_endy(centre_ind) - kp.kym_starty(centre_ind))/(kp.kym_endx(centre_ind) - kp.kym_startx(centre_ind));
    b = kp.kym_starty(centre_ind);
    a = kp.kym_startx(centre_ind);
    
    angle_made_with_xaxis = atan(m);
    
    maxx = size(stack, 1);
    maxy = size(stack, 2);
    
    line_thru_centre_y = [[1; maxx] m*([1; maxx] - a) + b];
    line_thru_centre_x = [a + (1/m)*([1; maxy] - b) [1; maxy]];
    
    ltc = [line_thru_centre_x; line_thru_centre_y];
    ll = ltc > 512 | ltc < 1;
    ll = sum(ll,2);
    ltc = ltc(~logical(ll),:);
    
    ltc_len = ltc(1,:) - ltc(2,:);
    ltc_len = round(sqrt(ltc_len(1)^2  + ltc_len(2)^2));
    
    
    %% Generate image profiles along perpendicular bisector and several parallel 
    %% lines on either side, taking average to give smoothed profile
    
    ltc_base = ltc;
    p = ltc == 1 | ltc == maxx | ltc == maxy;
%     if max(sum(p,1)) == 2
    for reps = 1:3
        ltc = [ltc; ltc_base + reps * ~p];
        ltc = [ltc; ltc_base - reps * ~p];
    end
%     end

    for ind = 1:7
        profs(ind, :) = improfile(squeeze(stack(:,:,1)),...
            [ltc(2*ind - 1, 1) ltc(2*ind, 1)], [ltc(2*ind - 1, 2) ltc(2*ind, 2)], ...
            ltc_len);
    end
    
    prof = mean(profs, 1);
    
    %% Then from the image profile maximum, identify the distance of the cut
    %% from the apical surface
    [~, maxind] = max(prof);
    x_apical_point = ltc(1,1) + maxind * cos(angle_made_with_xaxis);
    y_apical_point = ltc(1,2) + maxind * sin(angle_made_with_xaxis);
    
    distance_cut_to_apical_surface = sqrt((x_apical_point - a)^2 + ...
        (y_apical_point - b)^2);
    
    md.distanceToApicalSurface = distance_cut_to_apical_surface * md.umperpixel;
    
end