function show_edges(controls, data)

    if get(controls.hshowchk, 'Value')

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

        % access the edges structure and draw the edges
        edgs = {'hlL', 'hlM', 'hlR'};
        if ~isempty(data.edges)
            ts = [data.edges.timepoint];
            zs = [data.edges.z];
            if any(ts == t)
                if any(zs(ts == t) == z)
                    for edg = edgs
                        if ~isempty(data.edges(zs(ts == t) == z).(edg{1}))
                            set(data.edges(zs(ts == t) == z).(edg{1}), 'Visible', 'on');
                        end
                    end
                end
            end
        end
        
    else    
        if ~isempty(data.edges)
            edgelines = {'hlL', 'hlR', 'hlM'};
            for eidx = 1:length(data.edges)
                for elidx = 1:length(edgelines)
                    if ~isempty(data.edges(eidx).(edgelines{elidx}))
                        set(data.edges(eidx).(edgelines{elidx}), 'Visible', 'off');
                    end
                end
            end
        end
    end
    
    setappdata(controls.hfig, 'data', data);
    
end