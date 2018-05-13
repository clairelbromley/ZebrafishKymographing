function on_bottom_edge_button_press(hObject, eventdata, handles, controls)

    data = getappdata(controls.hfig, 'data');

    edg = get(hObject, 'Tag');
    
    data = add_edge(edg, controls, data);
    data = translate_line_pairs_to_rh_edges(edg, controls, data);
    % for now, restrict user interface to force top edges to be found
    % first, and in so doing avoid issues of checking which edges currently
    % exist...
    set(hObject, 'Enable', 'off')
    
    setappdata(controls.hfig, 'data', data);
    
end