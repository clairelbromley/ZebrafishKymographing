function update_image(controls)

    data = getappdata(controls.hfig, 'data');
    
    current_z_ind = round(get(controls.hzsl, 'Value'));
    current_c_ind = data.curr_c_plane;
    
    im = bfGetPlane(data.czi_reader, ...
        data.czi_reader.getIndex(current_z_ind - 1, current_c_ind - 1, 0) + 1);
    if get(controls.hhicontrast, 'Value')
        clims = [min(im(:)) max(im(:))/10];
    else
        clims = [min(im(:)) max(im(:))];
    end
    if (clims(1) == clims(2))
        clims(2) = clims(1) + 1;
    end
    imagesc(im, 'Parent', controls.hax);
    set(controls.hax, 'CLim', clims);
    colormap gray;
    set(gca, 'XTick', []);
    set(gca, 'YTick', []);
    
    if ~is_zoomed(controls.hax)
        axis equal tight;
    else
        axis normal tight; 
    end
    
    % add image click callback to all axis children:
    kids = get(controls.hax, 'Children');
    set(kids, 'ButtonDownFcn', {@on_image_click, [], controls});
    
    show_edges(controls, data);
    
    setappdata(controls.hfig, 'data', data);

end

