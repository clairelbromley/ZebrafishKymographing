function on_edge_button_press(hObject, eventdata, handles, controls)

    data = getappdata(controls.hfig, 'data');

    edg = get(hObject, 'Tag');
    z = round((data.top_slice_index -  round(get(controls.hzsl, 'Value'))) * ...
        double(data.ome_meta.getPixelsPhysicalSizeZ(0).value(ome.units.UNITS.MICROM)));
    t = data.timepoint;
    
    % check whether current z plane exists in array of stored edges...
    ts = [data.edges.timepoint];
    zs = [data.edges.z];
    if any(ts == t)
        if any(zs(ts == t) == z)
            data.edges((ts == t) & (zs == z)).(edg) = data.current_edge;
        else
            data.edges = [data.edges; Edges()];
            data.edges(end).timepoint = t;
            data.edges(end).z = z;
            data.edges(end).(edg) = data.current_edge;
        end
    else
        data.edges = [data.edges; Edges()];
        data.edges(end).timepoint = t;
        data.edges(end).z = z;
        data.edges(end).(edg) = data.current_edge;
    end
    
    % update UI
    edg_let = ['L', 'R', 'M'];
    set(controls.hffchecks((data.z_offsets == z), (strcmp(edg_let, edg))), ...
        'Value', 1);
    
    setappdata(controls.hfig, 'data', data);
    
end