function on_z_pos_changed(hObject, eventdata, handles, controls)

    data = getappdata(controls.hfig, 'data');
    
    data.curr_z_plane = round(get(hObject, 'Value'));
    update_image(controls)
    
    % enable edge selection only if a relevant frame is imaged
    edge_buts = [controls.hmidlbut, controls.hledgebut, controls.hredgebut];
    if isfield(data, 'top_slice_index')
        z_ind_to_micron_depth = double(data.ome_meta.getPixelsPhysicalSizeZ(0).value(ome.units.UNITS.MICROM));
        slices_relative_to_top = round(data.z_offsets/ z_ind_to_micron_depth);
        
        if any(data.curr_z_plane == (data.top_slice_index - slices_relative_to_top))
            set(edge_buts, 'Enable', 'on');
        else
            set(edge_buts, 'Enable', 'off');
        end
    else
        set(edge_buts, 'Enable', 'off');
    end
    
    setappdata(controls.hfig, 'data', data);
