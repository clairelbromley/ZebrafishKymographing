function hotkey_event_handler(hObject, eventdata, handles, controls)

    if strcmp(eventdata.Key, '5')
        % add bottom edge of rhombomere 5
        hObject = controls.hrh6botbut;
        if strcmp(get(hObject, 'Enable'), 'on') && ...
                strcmp(get(hObject, 'Visible'), 'on')
            on_topbottom_edge_button_press(hObject, eventdata, handles, controls);
        end
    end
    
    if strcmp(eventdata.Key, '3')
        % add top edge of rhombomere 3
        hObject = controls.hrh4topbut;
        if strcmp(get(hObject, 'Enable'), 'on') && ...
                strcmp(get(hObject, 'Visible'), 'on')
            on_topbottom_edge_button_press(hObject, eventdata, handles, controls);
        end
    end

end