function on_topbottom_edge_button_press(hObject, eventdata, handles, controls)

    data = getappdata(controls.hfig, 'data');

    edg = get(hObject, 'Tag');
    
    tbstr = {'Top', 'Bot'};
       
    data = add_edge(edg, controls, data);
    rhombomere_no = sscanf(edg, 'Rh%d');
    C = strsplit(edg, num2str(rhombomere_no));
    tb = C{2};  
    complimentary_edg = ['Rh' num2str(rhombomere_no) tbstr{~strcmp(tbstr, tb)}];
    
    z = round((data.top_slice_index -  round(get(controls.hzsl, 'Value'))) * ...
        double(data.ome_meta.getPixelsPhysicalSizeZ(0).value(ome.units.UNITS.MICROM)));
    t = data.timepoint;

    if ~isempty(data.edges)
        ts = [data.edges.timepoint];
        zs = [data.edges.z];
        if any(ts == t)
            if any(zs(ts == t) == z)
                if ~isempty(data.edges((ts == t) & (zs == z)).(complimentary_edg))
                    data = translate_line_pairs_to_rh_edges(edg, controls, data);
                end
            end
        end
    end
    
    setappdata(controls.hfig, 'data', data);
    
end