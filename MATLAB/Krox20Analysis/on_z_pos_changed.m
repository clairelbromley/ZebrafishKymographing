function on_z_pos_changed(hObject, eventdata, handles, controls)

    data = getappdata(controls.hfig, 'data');
    
    data.curr_z_plane = round(get(hObject, 'Value'));
    fprintf('z = %d of %d\r\n', data.curr_z_plane, get(controls.hzsl, 'Max'));
%     data.curr_c_plane = round(get(controls.hcsl, 'Value'));
    update_image(controls)
    
    % enable edge selection only if a relevant frame is imaged
    edge_buts = [controls.hmidlbut, controls.hledgebut, controls.hredgebut];
    rh_buts = [controls.hrh4but, controls.hrh6but];
    rhl_buts = [controls.hrh4topbut, ...
                controls.hrh4botbut, ...
                controls.hrh6topbut, ...
                controls.hrh6botbut];
    if isfield(data, 'top_slice_index')
        if ~isempty(data.top_slice_index)
            z_ind_to_micron_depth = double(data.ome_meta.getPixelsPhysicalSizeZ(0).value(ome.units.UNITS.MICROM));
            slices_relative_to_top = round(data.z_offsets/ z_ind_to_micron_depth);

            if any(data.curr_z_plane == (data.top_slice_index - slices_relative_to_top))
                if strcmp(data.rh_definition_method, 'Staining')
                    rhombomere_im = bfGetPlane(data.czi_reader, ...
                        data.czi_reader.getIndex(data.curr_z_plane - 1, ....
                        find(strcmp(data.channel_names, 'Krox20')) - 1, 0) + 1);
                    data = detect_rhombomeres(controls, data, rhombomere_im);
                end
                if strcmp(data.channel_names{data.curr_c_plane}, 'Krox20')
                    set(rh_buts, 'Enable', 'on');
                    set(edge_buts, 'Enable', 'off');
                elseif ((data.curr_c_plane == 1) && ...
                        (data.curr_c_plane ~= get(controls.hcsl, 'Value')) && ...
                        strcmp(data.rh_definition_method, 'MorphologicalMarkers'))
                    set(rh_buts, 'Enable', 'off');
                    set(edge_buts, 'Enable', 'off');
                    set(rhl_buts, 'Enable', 'on');
                else
                    set(edge_buts, 'Enable', 'on');
                    set(rh_buts, 'Enable', 'off');
                end
            else
                set([edge_buts rh_buts rhl_buts], 'Enable', 'off');
            end
        else
            set([edge_buts rh_buts rhl_buts], 'Enable', 'off');
        end
        
    else
        set([edge_buts rh_buts rhl_buts], 'Enable', 'off');
    end
    
    setappdata(controls.hfig, 'data', data);
