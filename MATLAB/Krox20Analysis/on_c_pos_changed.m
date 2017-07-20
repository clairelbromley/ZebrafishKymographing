function on_c_pos_changed(hObject, eventdata, handles, data, controls)

    new_c_plane = round(get(hObject, 'Value'));
    disp(new_c_plane);
    update_image(data, controls)
    
