function on_image_click(hObject, eventdata, handles, controls)

    data = getappdata(controls.hfig, 'data');
    
    kids = get(controls.hax, 'Children');
    delete(kids(strcmp(get(kids, 'Type'), 'hggroup')))

    M1 = imfreehand(controls.hax, 'Closed', false);
    data.current_edge = M1.getPosition;

    setappdata(controls.hfig, 'data', data);
    
end