function on_load_edge_click(hObject, eventdata, handles, controls)
% load previously drawn edges to overlay current data
    
    answer = questdlg('Loading old edges will replace current edges - are you sure?', ...
        'Load old edges?');
    
    if strcmp(answer, 'Yes')
        data = getappdata(controls.hfig, 'data');

        [fname, pname, ~] = uigetfile('*.mat', ...
            'Please select backup *.mat file containing edges...', ...
            '*.mat');
        
        if ~(fname == 0)

            d = load([pname fname]);
            
            % check that the filename associated with the edges matches
            % the filename of the data currently being analysed    
            if strcmp(d.data.filename, data.filename)
                prev_edges = d.data.edges;
                data.edges = prev_edges;
                data.top_slice_index = prev_edges(1).top_slice_index;
                setappdata(controls.hfig, 'data', data); 
                set(controls.hzradios, 'Enable', 'on');
                set(controls.hzradios(1), 'Value', 1);
                eventdata.NewValue = controls.hzradios(1);
                on_z_slice_selection_changed(hObject, eventdata, [], controls);
                update_edges_display_checkboxes(data, controls);
            end
            
        end
         
    end
        
end