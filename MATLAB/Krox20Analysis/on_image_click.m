function on_image_click(hObject, eventdata, handles, controls)

    data = getappdata(controls.hfig, 'data');
    
    kids = get(controls.hax, 'Children');
    delete(kids(strcmp(get(kids, 'Type'), 'hggroup')))

    closed = strcmp(data.channel_names{data.curr_c_plane}, 'Krox20');
    use_line = (strcmp(data.rh_definition_method, 'MorphologicalMarkers') && ...
                (get(controls.hcsl, 'Value') > 1) && (data.curr_c_plane == 1));
    try
        if use_line
            if strcmp(char(data.AP_axis_method), 'RotatedImage')
                fcn = @(pos) force_line_horizontal(pos);
            else
               fcn = @(pos) pos; 
            end
            data.current_edge = imline(controls.hax, 'PositionConstraintFcn', fcn);
        else
            data.current_edge = imfreehand(controls.hax, 'Closed', closed);
        end
    end

    setappdata(controls.hfig, 'data', data);
    
end