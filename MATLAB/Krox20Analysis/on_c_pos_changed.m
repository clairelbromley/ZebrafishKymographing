function on_c_pos_changed(hObject, eventdata, handles, controls)
    
    data = getappdata(controls.hfig, 'data');
    
    data.curr_c_plane = round(get(hObject, 'Value'));
    set(hObject, 'Value', data.curr_c_plane);
    data.curr_z_plane = round(get(controls.hzsl, 'Value'));
    set(controls.hzsl, 'Value', data.curr_z_plane);
    disp(data.curr_c_plane);
    update_image(controls);
    
    % enable edge selection only if a relevant frame is imaged
    edge_buts = [controls.hmidlbut, controls.hledgebut, controls.hredgebut];
    rh_buts = [controls.hrh4but, controls.hrh6but];
    if isfield(data, 'top_slice_index')
        if ~isempty(data.top_slice_index)
            z_ind_to_micron_depth = double(data.ome_meta.getPixelsPhysicalSizeZ(0).value(ome.units.UNITS.MICROM));
            slices_relative_to_top = round(data.z_offsets/ z_ind_to_micron_depth);

            if any(data.curr_z_plane == (data.top_slice_index - slices_relative_to_top))
                if strcmp(data.channel_names{data.curr_c_plane}, 'Krox20')
                    set(rh_buts, 'Enable', 'on');
                    set(edge_buts, 'Enable', 'off');
                    set(controls.hhicontrast, 'Value', 1);
                    update_image(controls);
                else
                    set(edge_buts, 'Enable', 'on');
                    set(rh_buts, 'Enable', 'off');
                end
            else
                set([edge_buts rh_buts], 'Enable', 'off');
            end
        end
    else
        set([edge_buts rh_buts], 'Enable', 'off');
    end

    setappdata(controls.hfig, 'data', data);