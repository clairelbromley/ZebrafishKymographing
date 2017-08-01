function on_edge_button_press(hObject, eventdata, handles, controls)

    data = getappdata(controls.hfig, 'data');

    edg = get(hObject, 'Tag');
    z = round((data.top_slice_index -  round(get(controls.hzsl, 'Value'))) * ...
        double(data.ome_meta.getPixelsPhysicalSizeZ(0).value(ome.units.UNITS.MICROM)));
    t = data.timepoint;
    
    vis = 'off';
    if get(controls.hshowchk, 'Value')
        vis = 'on';
    end
    
    % check whether current z plane exists in array of stored edges...
    if ~isempty(data.edges)
        ts = [data.edges.timepoint];
        zs = [data.edges.z];
        if any(ts == t)
            if any(zs(ts == t) == z)
                data.edges((ts == t) & (zs == z)).(edg) = data.current_edge;
                if isgraphics(data.edges(end).(['hl' edg]))
                    delete(data.edges(end).(['hl' edg]));
                end
                data.edges(end).(['hl' edg]) = line(data.current_edge(:,1), ...
                    data.current_edge(:,2), ...
                    'Color', 'r', ...
                    'Visible', vis);
            else
                data.edges = [data.edges; Edges()];
                data.edges(end).timepoint = t;
                data.edges(end).z = z;
                data.edges(end).(edg) = data.current_edge;
                data.edges(end).(['hl' edg]) = line(data.current_edge(:,1), ...
                    data.current_edge(:,2), ...
                    'Color', 'r', ...
                    'Visible', vis);
            end
        else
            data.edges = [data.edges; Edges()];
            data.edges(end).timepoint = t;
            data.edges(end).z = z;
            data.edges(end).(edg) = data.current_edge;
            data.edges(end).(['hl' edg]) = line(data.current_edge(:,1), ...
                    data.current_edge(:,2), ...
                    'Color', 'r', ...
                    'Visible', vis);
        end
    else
        data.edges = [data.edges; Edges()];
        data.edges(end).timepoint = t;
        data.edges(end).z = z;
        data.edges(end).(edg) = data.current_edge;
        data.edges(end).(['hl' edg]) = line(data.current_edge(:,1), ...
                    data.current_edge(:,2), ...
                    'Color', 'r', ...
                    'Visible', vis);
    end
    
    % update UI
    edg_let = {'L', 'R', 'M'};
    set(controls.hffchecks((data.z_offsets == z), (strcmp(edg_let, edg))), ...
        'Value', 1);
    show_edges(controls, data);
    kids = get(controls.hax, 'Children');
    delete(kids(strcmp(get(kids, 'Type'), 'hggroup')));
    
    % check if all edges are saved - if so, allow moving on to the next
    % timepoint
    if all(cell2mat(get(controls.hffchecks, 'Value')))
        set(controls.hnextbut, 'Enable', 'on');
    end
    
    setappdata(controls.hfig, 'data', data);
    
end