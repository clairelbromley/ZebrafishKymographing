function on_next_button_press(hObject, eventdata, handles, controls)

    data = getappdata(controls.hfig, 'data');
    
    %% save .mat file containing all data for recovery, just in case
    save([data.output_folder filesep 'backup.m'], data);
    
    %% save .mat file containing Edges instance for this timepoint
    % implement as a method of the Edges class?
    
    %% save tiffs and pngs with identified edges - pngs should have scale
    % bars, tiffs (for import to ImageJ) shouldn't
    
    %% calculate output stats and append to a .csv (for Mac compatibility)
    
    
    setappdata(controls.hfig, 'data', data);

end