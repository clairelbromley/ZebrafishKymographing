function on_z_slice_selection_changed(hObject, eventdata, handles, controls)

    data = getappdata(controls.hfig, 'data');
    selection_ind = eventdata.NewValue;
    disp(data.z_offsets(find(controls.hzradios == selection_ind)));
    
    setappdata(controls.hfig, 'data', data);

end