function show_edges(controls, data)

    % get the current z value and check whether it's in the list
    current_z_ind = get(controls.hzsl, 'Value');
    if isfield(data, 'top_slice_index')
        c = [double(data.ome_meta.getPixelsSizeY(0).getNumberValue()), ...
            double(data.ome_meta.getPixelsSizeX(0).getNumberValue())]/2;
        x_size = 2 * c(1);
        z_ind_to_micron_depth = double(data.ome_meta.getPixelsPhysicalSizeZ(0).value(ome.units.UNITS.MICROM));
        slices_relative_to_top = round(data.z_offsets/ z_ind_to_micron_depth);
        z = round((data.top_slice_index - current_z_ind) * z_ind_to_micron_depth);
        if ~any(current_z_ind == (data.top_slice_index - slices_relative_to_top))
            return;
        end
    else
        return;
    end

    % get the current timepoint
    t = data.timepoint;

    if get(controls.hshowchk, 'Value')
        
        % access the edges structure and draw the edges
        edgs = {'L', 'M', 'R', 'Rh4', 'Rh6'};
        kids = get(controls.hax, 'Children');
        delete(kids(strcmp(get(kids, 'Type'), 'patch')));
        if ~isempty(data.edges)
            ts = [data.edges.timepoint];
            zs = [data.edges.z];
            if any(ts == t)
                if any(((zs == z) & (ts == t)))
                    for edg = edgs
                        if ~isempty(data.edges((zs == z) & (ts == t)).(['hl' edg{1}]))
                            if isgraphics(data.edges((zs == z) & (ts == t)).(['hl' edg{1}]))
                                set(data.edges((zs == z) & (ts == t)).(['hl' edg{1}]), 'Visible', 'on');
                            else
                                if ~( strcmp(edg{1}, 'Rh4') || strcmp(edg{1}, 'Rh6') )
                                    data.edges((zs == z) & (ts == t)).(['hl' edg{1}]) = ...
                                        line(data.edges((zs == z) & (ts == t)).(edg{1})(:,1), ...
                                        data.edges((zs == z) & (ts == t)).(edg{1})(:,2), ...
                                        'Color', 'r', 'Visible', 'on');
                                else
                                    if strcmp(data.channel_names(get(controls.hcsl, 'Value')), 'Krox20')
                                        data.edges(end).(['hl' edg{1}]) = patch(data.edges((zs == z) & (ts == t)).(edg{1})(:,1), ...
                                            data.edges((zs == z) & (ts == t)).(edg{1})(:,2), ...
                                            'r', ...
                                            'EdgeColor', 'r', ...
                                            'LineWidth', 2, ...
                                            'FaceAlpha', 0.25, ...
                                            'Visible', 'on');
                                    end
                                end
                            end
                        end
                    end
                    
                    if ~strcmp(data.channel_names(get(controls.hcsl, 'Value')), 'Krox20')
                        rlh = [];
                        for rlidx = 1:length(data.edges((zs == z) & (ts == t)).rhombomereLimits)
                             rlhtmp = line([-500 x_size+500], ...
                                 [data.edges((zs == z) & (ts == t)).rhombomereLimits(rlidx) data.edges((zs == z) & (ts == t)).rhombomereLimits(rlidx)], ...
                                 'Color', 'g', 'LineStyle', '--', 'LineWidth', 2, 'Visible', 'on');
                             direction = [0 0 1];
                             origin = [c(1) c(2) 0];
                             rotate(rlhtmp, direction, ...
                                 data.edges((zs == z) & (ts == t)).tissueRotation, ...
                                 origin);
                             rlh = [rlh; rlhtmp];
                        end
                    end
                end
            end
        end
        
    else    
        kids = get(controls.hax, 'Children');
        delete(kids(strcmp(get(kids, 'Type'), 'line') | strcmp(get(kids, 'Type'), 'patch')));
    end
    
    setappdata(controls.hfig, 'data', data);
    
end