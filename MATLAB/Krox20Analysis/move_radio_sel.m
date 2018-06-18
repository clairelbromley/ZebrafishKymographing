function move_radio_sel(rdios_arr, direction, controls)

    if strcmp(get(rdios_arr(1), 'Enable'), 'on')
        dum = get(rdios_arr);
        val_arr = [dum.Value];

        k = -1;
        if strcmp(direction, 'up')
            if val_arr(1)
                return;
            end
        elseif strcmp(direction, 'down')
            if val_arr(end)
                return;
            else
                k = 1;
            end
        end

        val_arr = circshift(val_arr, k, 2);
        sel_idx = find(val_arr);
        
        set(rdios_arr(sel_idx), 'Value', 1);
        eventdata.NewValue = rdios_arr(sel_idx);
        on_z_slice_selection_changed([], eventdata, [], controls);
        
    end
end