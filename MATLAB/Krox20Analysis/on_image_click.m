function on_image_click(hObject, eventdata, handles, controls)

    data = getappdata(controls.hfig, 'data');
    
    kids = get(controls.hax, 'Children');
    delete(kids(strcmp(get(kids, 'Type'), 'hggroup')))

    closed = strcmp(data.channel_names{data.curr_c_plane}, 'Krox20');
    try
        data.current_edge = imfreehand(controls.hax, 'Closed', closed);
    end
%     data.current_edge = M1.getPosition;

    setappdata(controls.hfig, 'data', data);
    
end