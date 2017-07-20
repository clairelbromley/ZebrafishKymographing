function update_image(data, controls)

    current_z_ind = get(controls.hzsl, 'Value');
    current_c_ind = get(controls.hcsl, 'Value');
    
    im = bfGetPlane(data.czi_reader, ...
        data.czi_reader.getIndex(current_z_ind - 1, current_c_ind - 1, 0) + 1);
    imagesc(im, 'Parent', controls.hax);
    colormap gray;
    set(gca, 'XTick', []);
    set(gca, 'YTick', []);
    axis equal tight;

end