function midline_definition = calc_new_midline_stats(data, xedge, midline_definition)

    stats = {'mean', 'median', 'std', 'min', 'max'};
    individual_rhombomeres = {'AllRh'};

    midline_definition = generate_stats_struct(midline_definition, ...
        'midline_intensity', ...
        stats, ...
        individual_rhombomeres);

    midline_definition = generate_stats_struct(midline_definition, ...
        'NOTmidline_intensity', ...
        stats, ...
        individual_rhombomeres);

    midline_definition = generate_stats_struct(midline_definition, ...
        'bg_region_intensity', ...
        stats, ...
        individual_rhombomeres);

    midline_definition.AllRh.sum_total = NaN;
    midline_definition.AllRh.sum_midline = NaN;
    midline_definition.AllRh.sum_bg_region = NaN;
    midline_definition.AllRh.sum_NOT_midline = NaN;

    if ~isempty(xedge.M)
        midline_thickness_pix = round(data.midline_thickness_um / double(data.ome_meta.getPixelsPhysicalSizeX(0).value(ome.units.UNITS.MICROM)));
        
        z_ind_to_micron_depth = double(data.ome_meta.getPixelsPhysicalSizeZ(0).value(ome.units.UNITS.MICROM));
        slices_relative_to_top = round(xedge.z ./ z_ind_to_micron_depth);
        z_index = data.top_slice_index - slices_relative_to_top;
        c = find(strcmp(data.channel_names, 'Ncad'));
        im = bfGetPlane(data.czi_reader, ...
            data.czi_reader.getIndex(z_index - 1, c - 1, 0) + 1);
        
        rotim = imrotate(im, xedge.tissueRotation, 'bilinear', 'crop');
        theta = -deg2rad(xedge.tissueRotation);
        rotMatrix = [cos(theta) -sin(theta); sin(theta) cos(theta)];
        c = [double(data.ome_meta.getPixelsSizeY(0).getNumberValue()), ...
            double(data.ome_meta.getPixelsSizeX(0).getNumberValue())]/2;

        edgLs = {'L', 'R', 'M'};
        for edg = edgLs
            cc = repmat(c, size(xedge.(edg{1}), 1), 1);
            rotated_e.(edg{1}) = (rotMatrix * (xedge.(edg{1}) - cc)')' + cc; 
            x = rotated_e.(edg{1})(:,1);
            y = rotated_e.(edg{1})(:,2);
    %         [y, I] = sort(y);
            [y, I, ~] = unique(y, 'sorted');
            x = x(I);
            x = interp1(y, x, ...
                xedge.rhombomereLimits(1):xedge.rhombomereLimits(4), 'pchip');
            rotated_e.(edg{1}) = [x' (xedge.rhombomereLimits(1):xedge.rhombomereLimits(4))'];

        end
        
        midline_im = zeros(size(rotim));
        midline_col = [];
        denominator_im = zeros(size(rotim));
        denominator_col = [];
        for yind = min(rotated_e.M(:,2)):max(rotated_e.M(:,2))
            myind = yind - min(rotated_e.M(:,2)) + 1;
            midline_im(yind, floor(rotated_e.M(myind, 1) - midline_thickness_pix/2):floor(rotated_e.M(myind, 1) + midline_thickness_pix/2)) =...
                rotim(yind, floor(rotated_e.M(myind, 1) - midline_thickness_pix/2):floor(rotated_e.M(myind, 1) + midline_thickness_pix/2));
            midline_col = [midline_col; rotim(yind, floor(rotated_e.M(myind, 1) - midline_thickness_pix/2):floor(rotated_e.M(myind, 1) + midline_thickness_pix/2))];
            denominator_im(yind, floor(rotated_e.M(myind, 1) - 11 * midline_thickness_pix/2):floor(rotated_e.M(myind, 1) - 9 * midline_thickness_pix/2)) =...
                rotim(yind, floor(rotated_e.M(myind, 1) - 11 * midline_thickness_pix/2):floor(rotated_e.M(myind, 1) - 9 * midline_thickness_pix/2));
            denominator_col = [denominator_col; rotim(yind, floor(rotated_e.M(myind, 1) - 11 * midline_thickness_pix/2):floor(rotated_e.M(myind, 1) - 9 * midline_thickness_pix/2))];
        end
    
        if strcmp(data.midline_definition_method, 'max')
            midline_definition_array = double(max(midline_col, [], 2)) ./  double(mean(denominator_col, 2));
        else
            midline_definition_array = double(mean(midline_col, 2)) ./  double(mean(denominator_col, 2));
        end


        % output raw data; that is, not ratiod
        midline_definition = generate_stats(midline_definition, 'midline_intensity', stats, {'AllRh'}, double(midline_col(:)));

        midline_definition = generate_stats(midline_definition, 'bg_region_intensity', stats, {'AllRh'}, double(denominator_col(:)));

        % output sums: total between basal edges, midline, and total between
        % basal edges that ISN'T midline. For completeness, also sum region
        % that was previously used to normalise the midline definition
        xs = [rotated_e.L(:,1); flipud(rotated_e.R(:, 1))];
        ys = [rotated_e.L(:,2); flipud(rotated_e.R(:, 2))];
        msk = poly2mask(xs, ys, size(im,1), size(im,2));

        midline_definition.AllRh.sum_total = sum(im(msk));
        midline_definition.AllRh.sum_midline = sum(midline_col(:));
        midline_definition.AllRh.sum_bg_region = sum(denominator_col(:));
        midline_definition.AllRh.sum_NOT_midline = midline_definition.AllRh.sum_total - ...
            midline_definition.AllRh.sum_midline;
                
        midline_definition = generate_stats(midline_definition, 'NOTmidline_intensity', stats, {'AllRh'}, double(im(msk)));

    end
end        