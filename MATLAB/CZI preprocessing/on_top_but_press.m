function on_top_but_press(hObject, eventdata, handles, data, controls)

    current_z_ind = get(controls.hzsl, 'Value');
    z_ind_to_micron_depth = double(data.ome_meta.getPixelsPhysicalSizeZ(0).value(ome.units.UNITS.MICROM));
    
    disp(z_ind_to_micron_depth);
    disp(current_z_ind);
    disp(get(controls.hffchecks, 'Value'));

    
