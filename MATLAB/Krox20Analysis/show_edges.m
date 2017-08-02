function show_edges(controls, data)

    % get the current z value and check whether it's in the list
    current_z_ind = get(controls.hzsl, 'Value');
    if isfield(data, 'top_slice_index')
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
        edgs = {'L', 'M', 'R'};
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
                                data.edges((zs == z) & (ts == t)).(['hl' edg{1}]) = ...
                                    line(data.edges((zs == z) & (ts == t)).(edg{1})(:,1), ...
                                    data.edges((zs == z) & (ts == t)).(edg{1})(:,2), ...
                                    'Color', 'r', 'Visible', 'on');
                            end
                        end
                    end
                end
            end
        end
        
    else    
        kids = get(controls.hax, 'Children');
        delete(kids(strcmp(get(kids, 'Type'), 'line')));
    end
    
    setappdata(controls.hfig, 'data', data);
    
end