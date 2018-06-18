function move_radio_sel(rdios_arr, direction)

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
            
    for ridx = 1:length(dum)
        dum(ridx).Value = val_arr(ridx); 
    end

end