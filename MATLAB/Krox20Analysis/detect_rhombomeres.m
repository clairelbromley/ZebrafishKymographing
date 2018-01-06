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
    
    
    % If tissue is at an arbitrary angle:
    % define limits of rhombomeres along long axis of tissue. In case of
    % lumen opening when only one half of rhombomere is identified, ensure
    % that only the orientation of the complete rhombomere is considered. 
    % Otherwise, if tissue is pre-rotated, don't bother:
    if strcmp(data.AP_axis_method, 'Rhombomeres')
        if (imStats(2).Area/imStats(1).Area) < 0.7
            rotAngle = imStats(1).Orientation;
        else
            rotAngle = mean([imStats.Orientation]);
        end
        binim2 = imrotate(binim, -rotAngle, 'bilinear', 'crop');
    else
        rotAngle = 0;
        binim2 = binim;
    end
    rotated_rhombomere_lims = [find(sum(binim2, 2), 1, 'first'), ...
        find(sum(binim2, 2), 1, 'last')];
    cropped_binim = binim2(rotated_rhombomere_lims(1):rotated_rhombomere_lims(2), :);
    mid_rhombomere_lims = [find(~logical(sum(cropped_binim, 2)), 1, 'first'), ...
        find(~logical(sum(cropped_binim, 2)), 1, 'last')];
    
    data.edges = [data.edges; Edges()];
    
    data.edges(end).tissueRotation = -rotAngle;
    data.edges(end).z = z;
    data.edges(end).timepoint = t;
    
    % figure out which rhombomere falls closest to the top of the image -
    % call this Rh4    
    edges = bwboundaries(binim, 'noholes');
    e1 = fliplr(edges{1});
    e2 = fliplr(edges{2});
    % inelegant - improve?
    if isfield(data, 'current_edge')
        data.current_edge = [];
    end
    if (mean(e1(:,2)) < mean(e2(:,2)))
        % in this case, mean of y coords linked to the first edge lie
        % closer to the top of the image, and e1 should therefore be linked
        % to Rh4
        data.current_edge = e1;
        data = add_edge('Rh4', controls, data);
        data.current_edge = e2;
        data = add_edge('Rh6', controls, data);
    else
        data.current_edge = e1;
        data = add_edge('Rh6', controls, data);
        data.current_edge = e2;
        data = add_edge('Rh4', controls, data);
    end
        
    setappdata(controls.hfig, 'data', data);
    
    busy_dlg(busyOutput);
    
end