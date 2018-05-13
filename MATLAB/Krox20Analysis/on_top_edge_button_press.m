function on_top_edge_button_press(hObject, eventdata, handles, controls)

    data = getappdata(controls.hfig, 'data');

    edg = get(hObject, 'Tag');
    
    data = add_edge(edg, controls, data);
    filter_enabled_rhombomere_buts(data, controls);
    
    setappdata(controls.hfig, 'data', data);
    
end