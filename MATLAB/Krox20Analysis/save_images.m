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
        for chidx = 1:length(data.channel_names)
            z_fldr = sprintf('z = %0.2f um', z_pos);
            of = [data.out_folder filesep z_fldr];
            mkdir(of);

            im = bfGetPlane(data.czi_reader, ...
                data.czi_reader.getIndex((z_planes(data.z_offsets == z_pos)) - 1, chidx - 1, 0) + 1);

            % save tiffs, for now without edges
            imwrite(im, [of filesep sprintf('%s, t = %0.2f.tif', ...
                data.channel_names{chidx}, data.timepoint)]);

            % save png with edges and scale bar
            hfig_temp = figure('Visible', 'off');
            hax_temp = axes;
            imagesc(im);
            edges = data.edges((ts == data.timepoint) & (zs == z_pos));
            edgstr = {'L', 'M', 'R'};
            colormap gray;
            set(gca, 'XTick', []);
            set(gca, 'YTick', []);
            axis equal tight;

            print(hfig_temp, [of filesep sprintf('%s, t = %0.2f no edges.png', ...
                data.channel_names{chidx}, data.timepoint)], '-dpng', '-r300');
            
            % loop through and draw edges
            hls = [];
            for edg = edgstr
                hls = [hls line(edges.(edg{1})(:,1), ...
                    edges.(edg{1})(:,2), ...
                    'Color', 'r', ...
                    'Parent', hax_temp)];
            end

            % add scale bar
            hscl = line([0.95 * size(im, 2) - scale_bar_length_pix, 0.95 * size(im, 2)], ...
            [0.95 * size(im, 1), 0.95 * size(im, 1)], ...
            'Color', 'w', ...
            'LineWidth', 3, ...
            'Parent', hax_temp);

            print(hfig_temp, [of filesep sprintf('%s, t = %0.2f with edges.png', ...
                data.channel_names{chidx}, data.timepoint)], '-dpng', '-r300');
            
            savefig(hfig_temp, [of filesep sprintf('%s, t = %0.2f.fig', ...
                data.channel_names{chidx}, data.timepoint)]);
            
            if strcmp(data.channel_names{chidx}, 'Krox20')
                delete(hls);
                subplot(2,1,1);
                imagesc(im);
                colormap gray;
                set(gca, 'XTick', []);
                set(gca, 'YTick', []);
                axis equal tight;
                edgstr = {'Rh4', 'Rh6'};
                
                for edg = edgstr
                    patch(edges.(edg{1})(:,1), ...
                        edges.(edg{1})(:,2), ...
                        'r', ...
                        'EdgeColor', 'r', ...
                        'LineWidth', 2, ...
                        'FaceAlpha', 0.25, ...
                        'Visible', 'on');
                end
                
                subplot(2,1,2);
                imagesc(im);
                colormap gray;
                set(gca, 'XTick', []);
                set(gca, 'YTick', []);
                axis equal tight;
                
                for rlidx = 1:length(data.edges((zs == z) & (ts == t)).rhombomereLimits)
                    rlhtmp = line([-500 x_size+500], ...
                        [edges.rhombomereLimits(rlidx) edges.rhombomereLimits(rlidx)], ...
                        'Color', 'g', 'LineStyle', '--', 'LineWidth', 1, 'Visible', 'on');
                    direction = [0 0 1];
                    origin = [c(1) c(2) 0];
                    rotate(rlhtmp, direction, ...
                        data.edges((zs == z) & (ts == t)).tissueRotation, ...
                        origin);
                end
                
                 % add scale bar
                hscl = line([0.95 * size(im, 2) - scale_bar_length_pix, 0.95 * size(im, 2)], ...
                [0.95 * size(im, 1), 0.95 * size(im, 1)], ...
                'Color', 'w', ...
                'LineWidth', 3);
                
                print(hfig_temp, [of filesep sprintf('%s, t = %0.2f with rhombomeres.png', ...
                    data.channel_names{chidx}, data.timepoint)], '-dpng', '-r300');
                
                savefig(hfig_temp, [of filesep sprintf('%s, t = %0.2f with rhombomeres.png', ...
                    data.channel_names{chidx}, data.timepoint)]);
                
            end
                

            close(hfig_temp);

        end
    end
  
end