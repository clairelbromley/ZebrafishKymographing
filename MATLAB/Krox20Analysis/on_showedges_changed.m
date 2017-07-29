function on_showedges_changed(hObject, eventdata, handles, controls)

    data = getappdata(controls.hfig, 'data');

%     if get(hObject, 'Value')
        show_edges(controls, data);
%     end
    
    setappdata(controls.hfig, 'data', data);
    
end