function update_image(controls)

    data = getappdata(controls.hfig, 'data');
    
    current_z_ind = round(get(controls.hzsl, 'Value'));
    current_c_ind = round(get(controls.hcsl, 'Value'));
    
    im = bfGetPlane(data.czi_reader, ...
        data.czi_reader.getIndex(current_z_ind - 1, current_c_ind - 1, 0) + 1);
    imagesc(im, 'Parent', controls.hax);
    colormap gray;
    set(gca, 'XTick', []);
    set(gca, 'YTick', []);
    axis equal tight;
    
    % add image click callback to all axis children:
    kids = get(controls.hax, 'Children');
    set(kids, 'ButtonDownFcn', {@on_image_click, [], controls});
    
    % enable edge selection only if a relevant frame is imaged
    edge_buts = [controls.hmidlbut, controls.hledgebut, controls.hredgebut];
    if isfield(data, 'top_slice_index')
        z_ind_to_micron_depth = double(data.ome_meta.getPixelsPhysicalSizeZ(0).value(ome.units.UNITS.MICROM));
        slices_relative_to_top = round(data.z_offsets/ z_ind_to_micron_depth);
        
        if any(current_z_ind == (data.top_slice_index - slices_relative_to_top))
            set(edge_buts, 'Enable', 'on');
        else
            set(edge_buts, 'Enable', 'off');
        end
    else
        set(edge_buts, 'Enable', 'off');
    end
    
    setappdata(controls.hfig, 'data', data);

end

