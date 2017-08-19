function midline_definition = calc_midline_definition(data, edge)

    midline_thickness_pix = 20;

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
    
    midline_im = zeros(size(rotim));
    midline_col = [];
    denominator_im = zeros(size(rotim));
    denominator_col = [];
    for yind = min(rotated_e.M(:,2)):max(rotated_e.M(:,2))
        myind = yind - min(rotated_e.M(:,2)) + 1;
        midline_im(yind, round(rotated_e.M(myind, 1) - midline_thickness_pix/2):round(rotated_e.M(myind, 1) + midline_thickness_pix/2)) =...
            rotim(yind, round(rotated_e.M(myind, 1) - midline_thickness_pix/2):round(rotated_e.M(myind, 1) + midline_thickness_pix/2));
        midline_col = [midline_col; rotim(yind, round(rotated_e.M(myind, 1) - midline_thickness_pix/2):round(rotated_e.M(myind, 1) + midline_thickness_pix/2))];
        denominator_im(yind, round(rotated_e.M(myind, 1) - 11 * midline_thickness_pix/2):round(rotated_e.M(myind, 1) - 9 * midline_thickness_pix/2)) =...
            rotim(yind, round(rotated_e.M(myind, 1) - 11 * midline_thickness_pix/2):round(rotated_e.M(myind, 1) - 9 * midline_thickness_pix/2));
        denominator_col = [denominator_col; rotim(yind, round(rotated_e.M(myind, 1) - 11 * midline_thickness_pix/2):round(rotated_e.M(myind, 1) - 9 * midline_thickness_pix/2))];
    end
    
    midline_definition_array = double(max(midline_col, [], 2)) ./  double(mean(denominator_col, 2));
    midline_definition.AllRh.mean_midline_def = mean(midline_definition_array);
    midline_definition.AllRh.median_midline_def = median(midline_definition_array);
    midline_definition.AllRh.std_midline_def = std(midline_definition_array);
    midline_definition.AllRh.min_midline_def = min(midline_definition_array);
    midline_definition.AllRh.max_midline_def = max(midline_definition_array);
    
    for rh = rhs
        
        temp_m = midline_definition_array((edge.rhombomereLimits(rh-min(rhs)+1) - min(edge.rhombomereLimits) + 1):...
            (edge.rhombomereLimits(rh-min(rhs)+2) - min(edge.rhombomereLimits) + 1));
        midline_definition.(['Rh' num2str(rh)]).mean_midline_def = mean(temp_m);
        midline_definition.(['Rh' num2str(rh)]).median_midline_def = median(temp_m);
        midline_definition.(['Rh' num2str(rh)]).std_midline_def = std(temp_m);
        midline_definition.(['Rh' num2str(rh)]).min_midline_def = min(temp_m);
        midline_definition.(['Rh' num2str(rh)]).max_midline_def = max(temp_m);
        
    end

end