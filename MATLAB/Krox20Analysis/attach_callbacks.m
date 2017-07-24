function attach_callbacks(controls)

    set(controls.hsettopbut, 'Callback', @pop);
    set(controls.hzsl, 'Callback', {@on_z_pos_changed, [], controls});
    set(controls.hcsl, 'Callback', {@on_c_pos_changed, [], controls});
    set(controls.hsettopbut, 'Callback', {@on_top_but_press, [], controls});
    set(controls.hradiogroup, 'SelectionChangeFcn', ...
        {@on_z_slice_selection_changed, [], controls});
    
end
