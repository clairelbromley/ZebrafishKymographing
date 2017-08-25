function on_next_button_press(hObject, eventdata, handles, controls)

    data = getappdata(controls.hfig, 'data');
    
    if ~all(cell2mat(get(controls.hffchecks, 'Value')))
        answer = questdlg('Not all edges are found for this timepoint - proceed anyway?', ...
            'Proceed to next timepoint?', ...
            'Yes', 'No', 'Yes');
        if strcmp(answer, 'No')
            return;
        end
    end
    
    busyOutput = busy_dlg();
    
    %% save .mat file containing all data for recovery, just in case
    save([data.out_folder filesep 'backup.m'], 'data');
    
    %% save .mat file containing Edges instance for this timepoint
    % implement as a method of the Edges class?
    
    %% save tiffs and pngs with identified edges - pngs should have scale
    % bars, tiffs (for import to ImageJ) shouldn't
    save_images(controls, data);
    
    %% calculate output stats and append to a .csv (for Mac compatibility)
    edges = calculate_output_stats(data);
    if ~isempty(edges)
        hdr_string = save_results(data, edges);
    end
%     ...
%         [edges.basal_basal_distances.];
%     dlmwrite([data.out_folder filesep 'results.csv'], results, '-append', 'delimiter', ',');
    
    
    %% update timepoint and display accordingly
    if (data.timepoint < length(data.files))
        data.timepoint = data.timepoint + 1;
        data.czi_reader = bfGetReader([data.in_folder filesep data.files(data.timepoint).name]);
        data.ome_meta = data.czi_reader.getMetadataStore();
        initialise_sliders(controls, data);
        set(controls.hfig, 'Name', data.files(data.timepoint).name)

%         %% go to approximate top of tissue based on previous timepoint?
%         if isempty(data.top_slice_index)
%             set(controls.hzsl, 'Value', 1);
%         else
%             set(controls.hzsl, 'Value', (data.top_slice_index));
%         end
        on_z_pos_changed(controls.hzsl, eventdata, handles, controls);
        update_image(controls);

        %% reset checkboxes and disable controls 
        set(controls.hffchecks(:), 'Value', 0)
        set(controls.hzradios, 'Enable', 'off')
        edge_buts = [controls.hmidlbut, controls.hledgebut, controls.hredgebut];
        set(edge_buts, 'Enable', 'off');
        data.top_slice_index = [];

        busy_dlg(busyOutput);
        setappdata(controls.hfig, 'data', data);
    
    else
        fid = fopen([data.out_folder filesep 'results.csv'],'a');
        fprintf(fid,hdr_string);
        fclose(fid);
        busy_dlg(busyOutput);
        msgbox('Reached the end of the current timecourse!');
        close(controls.hfig);
    end
    
    initialise_sliders(controls, data);

end