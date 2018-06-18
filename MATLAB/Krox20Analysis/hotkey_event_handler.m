function hotkey_event_handler(hObject, eventdata, handles, controls)

    %% define the button referenced by the hotkey
    
    if strcmp(eventdata.Key, '5')
        % add bottom edge of rhombomere 5
        hObject = controls.hrh6botbut;
    end
    
    if strcmp(eventdata.Key, '3')
        % add top edge of rhombomere 3
        hObject = controls.hrh4topbut;
    end
    
    if strcmp(eventdata.Key, 'l')
        % add edge as left basal surface
        hObject = controls.hledgebut;
    end
    
    if strcmp(eventdata.Key, 'm')
        % add edge as midline
        hObject = controls.hmidlbut;
    end
    
    if strcmp(eventdata.Key, 'r')
        % add edge as right basal surface
        hObject = controls.hredgebut;
    end
    
    if strcmp(eventdata.Key, 'uparrow')
        % go up a Z plane (from pre-selected depths)
        rdios = controls.hzradios;
        move_radio_sel(rdios, 'up');
    end
    
    if strcmp(eventdata.Key, 'downarrow')
        % go down a Z plane (from pre-selected depths)
        rdios = controls.hzradios;
        move_radio_sel(rdios, 'down');
    end
    
    
    %% run callback associated with selected button
    
    if strcmp(get(hObject, 'Enable'), 'on') && ...
                strcmp(get(hObject, 'Visible'), 'on')
        cb = get(hObject, 'Callback');
        feval(cb{1}, hObject, [], [], cb{3});
    end

end