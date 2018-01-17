function on_manual_ts_OK(hObject, eventdata, handles, controls)
    
    global man_ts_data;
    tmp = get(controls.hTStbl, 'Data');
    man_ts_data.files_out = tmp(:,1);
    man_ts_data.timestamps = tmp(:,2);
    close(controls.hfig);