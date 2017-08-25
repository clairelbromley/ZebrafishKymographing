function data = calculate_rhombomere_extents(data, controls)

    % get edges of rhombomeres
    z = round((data.top_slice_index -  round(get(controls.hzsl, 'Value'))) * ...
    double(data.ome_meta.getPixelsPhysicalSizeZ(0).value(ome.units.UNITS.MICROM)));
    t = data.timepoint;

    ts = [data.edges.timepoint];
    zs = [data.edges.z];
    
    rh4 = data.edges((ts == t) & (zs == z)).Rh4;
    rh6 = data.edges((ts == t) & (zs == z)).Rh6;
   
    rh4msk = poly2mask(rh4(:,1), rh4(:,2), ...
        double(data.ome_meta.getPixelsSizeY(0).getValue()), ...
        double(data.ome_meta.getPixelsSizeX(0).getValue()));
    rh6msk = poly2mask(rh6(:,1), rh6(:,2), ...
        double(data.ome_meta.getPixelsSizeY(0).getValue()), ...
        double(data.ome_meta.getPixelsSizeX(0).getValue()));
    binim = rh4msk | rh6msk;
    
    imStats = regionprops(binim, 'Orientation', 'ConvexHull', ...
        'MajorAxisLength', 'MinorAxisLength', 'Area', 'Centroid');
    [~,sidx] = sort([imStats.Area], 'descend');   
    imStats = [imStats(sidx(1)); imStats(sidx(2))];
    
    % define limits of rhombomeres along long axis of tissue. In case of
    % lumen opening when only one half of rhombomere is identified, ensure
    % that only the orientation of the complete rhombomere is considered. 
    if (imStats(2).Area/imStats(1).Area) < 0.7
        rotAngle = imStats(1).Orientation;
    else
        rotAngle = mean([imStats.Orientation]);
    end
    binim2 = imrotate(binim, -rotAngle, 'bilinear', 'crop');
    rotated_rhombomere_lims = [find(sum(binim2, 2), 1, 'first'), ...
        find(sum(binim2, 2), 1, 'last')];
    cropped_binim = binim2(rotated_rhombomere_lims(1):rotated_rhombomere_lims(2), :);
    mid_rhombomere_lims = [find(~logical(sum(cropped_binim, 2)), 1, 'first'), ...
        find(~logical(sum(cropped_binim, 2)), 1, 'last')];
    
    data.edges((ts == t) & (zs == z)).tissueRotation = -rotAngle;
    data.edges((ts == t) & (zs == z)).rhombomereLimits = [rotated_rhombomere_lims(1), ...
        rotated_rhombomere_lims(1) + mid_rhombomere_lims(1), ...
        rotated_rhombomere_lims(1) + mid_rhombomere_lims(2), ...
        rotated_rhombomere_lims(2)];

end