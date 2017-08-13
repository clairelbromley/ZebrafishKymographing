function midline_definition = calc_midline_definition(data, edge)

    midline_thickness_pix = 10;

    % get z index
    z_ind_to_micron_depth = double(data.ome_meta.getPixelsPhysicalSizeZ(0).value(ome.units.UNITS.MICROM));
    slices_relative_to_top = round(edge.z ./ z_ind_to_micron_depth);
    z_index = data.top_slice_index - slices_relative_to_top;
    c = find(strcmp(data.channel_names, 'Ncad'));
    
    im = bfGetPlane(data.czi_reader, ...
        data.czi_reader.getIndex(z_index - 1, c - 1, 0) + 1);
        
    rotim = imrotate(im, edge.tissueRotation, 'bilinear', 'crop');
    theta = -deg2rad(edge.tissueRotation);
    rotMatrix = [cos(theta) -sin(theta); sin(theta) cos(theta)];
    c = [double(data.ome_meta.getPixelsSizeY(0).getNumberValue()), ...
        double(data.ome_meta.getPixelsSizeX(0).getNumberValue())]/2;
    
    edgLs = {'L', 'M', 'R'};
    rhs = [4, 5, 6];
    
    for edg = edgLs
        cc = repmat(c, size(edge.(edg{1}), 1), 1);
        rotated_e.(edg{1}) = (rotMatrix * (edge.(edg{1}) - cc)')' + cc; 
        x = rotated_e.(edg{1})(:,1);
        y = rotated_e.(edg{1})(:,2);
        [y, I] = sort(y);
        x = x(I);
        x = interp1(y, x, ...
            edge.rhombomereLimits(1):edge.rhombomereLimits(4), 'pchip');
        rotated_e.(edg{1}) = [x' (edge.rhombomereLimits(1):edge.rhombomereLimits(4))'];
            
    end
    
    % NO - calculate midline ratios for all y, then segment up?
    midline_im = rotim;
    out = zeros(size(rotim));
    for yind = min(rotated_e.M(:,2)):max(rotated_e.M(:,2))
        out(yind, round(rotated_e.M(yind, 1) - midline_thickness_pix/2):round(rotated_e.M(yind, 1) + midline_thickness_pix/2)) = midline_im(yind, round(rotated_e.M(yind, 1) - midline_thickness_pix/2):round(rotated_e.M(yind, 1) + midline_thickness_pix/2));
    end
    
    
    for rh = rhs
        temp_e.L = rotated_e.L;
        msk1 = rotated_e.L(:, 2) > edge.rhombomereLimits(rh-min(rhs)+2);
        msk2 = rotated_e.L(:, 2) < edge.rhombomereLimits(rh-min(rhs)+1);
        msk = msk1 | msk2;
        temp_e.L(msk, :) = [];
        
        temp_e.R = rotated_e.R;
        temp_e.R(msk, :) = [];
        
        temp_e.M = rotated_e.M;
        temp_e.M(msk, :) = [];
        
        midline_im = rotim(edge.rhombomereLimits(rh-min(rhs)+1):edge.rhombomereLimits(rh-min(rhs)+2), :);
        
        midline_im(:, (temp_e.M - midline_thickness_pix/2):(temp_e.M + midline_thickness_pix/2)) = 0;
%         midline_intesity = 
        
    end

end