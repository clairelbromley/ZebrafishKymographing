function attach_callbacks(controls, data)

    set(controls.hsettopbut, 'Callback', @pop);
    set(controls.hzsl, 'Callback', {@on_z_pos_changed, [], data, controls});
    set(controls.hcsl, 'Callback', {@on_c_pos_changed, [], data, controls});
    set(controls.hsettopbut, 'Callback', {@on_top_but_press, [], data, controls});
    
end
