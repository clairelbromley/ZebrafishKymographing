function on_z_slice_selection_changed(hObject, eventdata, handles, controls)

    data = getappdata(controls.hfig, 'data');
    selection_ind = eventdata.NewValue;

    z_ind_to_micron_depth = double(data.ome_meta.getPixelsPhysicalSizeZ(0).value(ome.units.UNITS.MICROM));
    slice_relative_to_top = round(data.z_offsets((controls.hzradios == selection_ind)) / z_ind_to_micron_depth);
    
    set(controls.hzsl, 'Value', (data.top_slice_index - slice_relative_to_top));
    on_z_pos_changed(controls.hzsl, eventdata, handles, controls);
    update_image(controls);
    
%     setappdata(controls.hfig, 'data', data);

end