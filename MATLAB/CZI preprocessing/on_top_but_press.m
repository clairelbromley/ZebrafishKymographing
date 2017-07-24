function on_top_but_press(hObject, eventdata, handles, controls)

    data = getappdata(controls.hfig, 'data');

    current_z_ind = get(controls.hzsl, 'Value');
    z_ind_to_micron_depth = double(data.ome_meta.getPixelsPhysicalSizeZ(0).value(ome.units.UNITS.MICROM));
    
    disp(current_z_ind);
    
    if any(cell2mat(get(controls.hffchecks, 'Value')))
       answer = questdlg(['Resetting top slice will remove existing edges. '...
           'Continue?'], 'Warning!', 'Yes', 'No', 'No');
       if strcmp(answer, 'No')
           return;
       else
           % remove stored edges from data structure
           % reset the checkboxes showing which edges are stored
       end
    end
    
    for zr = controls.hzradios
        set(zr, 'Enable', 'on');
    end
    
    data.top_slice_index = current_z_ind;

    setappdata(controls.hfig, 'data', data);
    
