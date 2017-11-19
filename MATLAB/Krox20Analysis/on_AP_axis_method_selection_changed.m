function on_AP_axis_method_selection_changed(hObject, eventdata, handles, controls)

    data = getappdata(controls.hfig, 'data');
    selection_ind = eventdata.NewValue;

    AP_axis_methods = {'Rhombomeres', 'RotatedImage'};
    
    data.AP_axis_method = AP_axis_methods(hAPaxradios == selection_ind);
    
    setappdata(controls.hfig, 'data', data);

end