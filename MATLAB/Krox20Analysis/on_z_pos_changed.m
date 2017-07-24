function on_z_pos_changed(hObject, eventdata, handles, controls)

    data = getappdata(controls.hfig, 'data');
    
    data.curr_z_plane = round(get(hObject, 'Value'));
    update_image(controls)
    
    setappdata(controls.hfig, 'data', data);
