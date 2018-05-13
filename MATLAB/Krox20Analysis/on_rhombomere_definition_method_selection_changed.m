function on_rhombomere_definition_method_selection_changed(hObject, eventdata, handles, controls)

% modify the underlying variable to link to the UI

    data = getappdata(controls.hfig, 'data');
    selection_ind = eventdata.NewValue;

    rh_definition_methods = {'MorphologicalMarkers', 'Staining'};
    
    data.rh_definition_method = rh_definition_methods(controls.hRDefRadios == selection_ind);
    
    rh_buts = [controls.hrh4but, controls.hrh6but];
    rhl_buts = [controls.hrh4topbut, ...
                controls.hrh4botbut, ...
                controls.hrh6topbut, ...
                controls.hrh6botbut];
            
    if strcmp(data.rh_definition_method, 'MorphologicalMarkers')
        set(rh_buts, 'Visible', 'off');
        set(rhl_buts, 'Visible', 'on');
    else
        set(rh_buts, 'Visible', 'on');
        set(rhl_buts, 'Visible', 'off');
    end
    
    setappdata(controls.hfig, 'data', data);
    
    initialise_sliders(controls, data);
    
end