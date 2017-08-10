function data = detect_rhombomeres(controls, data, im)

    busyOutput = busy_dlg();
    
    z = round((data.top_slice_index -  round(get(controls.hzsl, 'Value'))) * ...
        double(data.ome_meta.getPixelsPhysicalSizeZ(0).value(ome.units.UNITS.MICROM)));
    t = data.timepoint;
    
    if ~isempty(data.edges)
        zs = [data.edges.z];
        ts = [data.edges.timepoint];
        
        if any(ts == t)
            if any(zs(ts == t) == z)
                if (~isempty(data.edges(((ts == t) & (zs == z))).Rh4) && ...
                        ~isempty(data.edges(((ts == t) & (zs == z))).Rh6))
                    busy_dlg(busyOutput);
                    return;
                end
            end
        end
    end

    imf = medfilt2(im, [15 15]); % maximum kernel that would allow GPU operation. Empirically looks OK. 
    thr = 3 * quantile(imf(:), 0.75); % Emprically determined threshold
    binim = imf > thr;
    binim =  imfill(binim, 'holes');
    
    imStats = regionprops(binim, 'Orientation', 'ConvexHull', ...
        'MajorAxisLength', 'MinorAxisLength', 'Area', 'Centroid');
    [~,sidx] = sort([imStats.Area], 'descend');
    bwl = bwlabel(binim);
    
    imStats = [imStats(sidx(1)); imStats(sidx(2))];
    binim((bwl ~= sidx(1)) & (bwl ~= sidx(2))) = 0;
    
    % define limits of rhombomeres along long axis of tissue
    rotAngle = mean([imStats.Orientation]);
    binim2 = imrotate(binim, -rotAngle, 'bilinear', 'crop');
    rotated_rhombomere_lims = [find(sum(binim2, 2), 1, 'first'), ...
        find(sum(binim2, 2), 1, 'last')];
%     if isempty(data.edges)
    data.edges = [data.edges; Edges()];
%     end
    
    data.edges(end).tissueRotation = -rotAngle;
    data.edges(end).rhombomereLimits = rotated_rhombomere_lims;
    data.edges(end).z = z;
    data.edges(end).timepoint = t;
    
    % figure out which rhombomere falls closest to the top of the image -
    % call this Rh4    
    edges = bwboundaries(binim, 'noholes');
    % inelegant - improve?
    if isfield(data, 'current_edge')
        data.current_edge = [];
    end
    if imStats(2).Centroid(2) > imStats(1).Centroid(2)
        data.current_edge = fliplr(edges{1});
        data = add_edge('Rh4', controls, data);
        data.current_edge = fliplr(edges{2});
        data = add_edge('Rh6', controls, data);
    else
        data.current_edge = fliplr(edges{1});
        data = add_edge('Rh6', controls, data);
        data.current_edge = fliplr(edges{2});
        data = add_edge('Rh4', controls, data);
    end
    
    
    setappdata(controls.hfig, 'data', data);
    
    busy_dlg(busyOutput);
    
end