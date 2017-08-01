function save_images(controls, data)

    % get z positions
    z_ind_to_micron_depth = double(data.ome_meta.getPixelsPhysicalSizeZ(0).value(ome.units.UNITS.MICROM));
    slices_relative_to_top = round(data.z_offsets ./ z_ind_to_micron_depth);
    z_planes = data.top_slice_index - slices_relative_to_top;
    
    % get edges data
    ts = [data.edges.timepoint];
    zs = [data.edges.z];
    
    % get XY scaling
    pix2micron = double(data.ome_meta.getPixelsPhysicalSizeX(0).value(ome.units.UNITS.MICROM));
    scale_bar_length_pix = round(data.scale_bar_length_um / pix2micron);
    
    for z_pos = data.z_offsets
        z_fldr = sprintf('z = %0.2f um', z_pos);
        of = [data.out_folder filesep z_fldr];
        mkdir(of);

        ch1im = bfGetPlane(data.czi_reader, ...
            data.czi_reader.getIndex((z_planes(data.z_offsets == z_pos)) - 1, 0, 0) + 1);
        ch2im = bfGetPlane(data.czi_reader, ...
            data.czi_reader.getIndex((z_planes(data.z_offsets == z_pos)) - 1, 1, 0) + 1);
        
        % save tiffs, for now without edges
        imwrite(ch1im, [of filesep sprintf('%s, t = %0.2f.tif', ...
            data.channel_names{1}, data.timepoint)]);
        imwrite(ch2im, [of filesep sprintf('%s, t = %0.2f.tif', ...
            data.channel_names{2}, data.timepoint)]);
        
        % save png with edges and scale bar
        hfig_temp = figure('Visible', 'off');
        imagesc(ch1im);
        edges = data.edges((ts == data.timepoint) & (zs == z_pos));
        % loop through and draw edges
        colormap gray;
        set(gca, 'XTick', []);
        set(gca, 'YTick', []);
        axis equal tight;
        
        close(hfig_temp);
        
    end
  
end