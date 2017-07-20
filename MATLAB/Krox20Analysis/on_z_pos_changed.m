function on_z_pos_changed(hObject, eventdata, handles, data, controls)

    new_z_plane = round(get(hObject, 'Value'));
    disp(new_z_plane);
    update_image(data, controls)
    
