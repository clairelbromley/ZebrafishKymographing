function on_c_pos_changed(hObject, eventdata, handles, controls)
    
    data = getappdata(controls.hfig, 'data');
    
    data.curr_c_plane = round(get(hObject, 'Value'));
    disp(data.curr_c_plane);
    update_image(data, controls)

    setappdata(controls.hfig, 'data', data);