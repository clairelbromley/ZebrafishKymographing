function data = add_edge(edg, controls, data)

    z = round((data.top_slice_index -  round(get(controls.hzsl, 'Value'))) * ...
        double(data.ome_meta.getPixelsPhysicalSizeZ(0).value(ome.units.UNITS.MICROM)));
    t = data.timepoint;
    
    vis = 'off';
    if get(controls.hshowchk, 'Value')
        vis = 'on';
    end
    
    % check whether current z plane exists in array of stored edges...
    edg_str = {'L', 'R', 'M'};
    if ~isempty(data.edges)
        ts = [data.edges.timepoint];
        zs = [data.edges.z];
        if any(ts == t)
            if any(zs(ts == t) == z)
                 data.edges((ts == t) & (zs == z)).timestamp = data.timestamps(t);
                if ~( strcmp(edg, 'Rh4') || strcmp(edg, 'Rh6') )
                    if isa(data.current_edge, 'imfreehand')
                        data.current_edge = data.current_edge.getPosition;
                    end
                    data.edges((ts == t) & (zs == z)).(edg) = data.current_edge;
                    data.edges((ts == t) & (zs == z)).edgeValidity(strcmp(edg_str, edg),:) = ...
                        check_edge_validity(data, data.edges((ts == t) & (zs == z)));
                    if any(data.edges((ts == t) & (zs == z)).edgeValidity(strcmp(edg_str, edg),:))
                        data.edges((ts == t) & (zs == z)).(edg) = data.current_edge;
                    end
                else
                    if isa(data.current_edge, 'imfreehand')
                        data.current_edge = data.current_edge.getPosition;
                    end
                    data.edges((ts == t) & (zs == z)).(edg) = data.current_edge;
%                     data = calculate_rhombomere_extents(data, controls);
                end
                if isgraphics(data.edges(end).(['hl' edg]))
                    delete(data.edges(end).(['hl' edg]));
                end
                if ~( strcmp(edg, 'Rh4') || strcmp(edg, 'Rh6') )
                    if any(data.edges((ts == t) & (zs == z)).edgeValidity(strcmp(edg_str, edg),:))
                        data.edges((ts == t) & (zs == z)).(['hl' edg]) = line(data.current_edge(:,1), ...
                            data.current_edge(:,2), ...
                            'Color', 'r', ...
                            'Visible', vis);
                    end
                else
                    data.edges((ts == t) & (zs == z)).(['hl' edg]) = patch(data.current_edge(:,1), ...
                        data.current_edge(:,2), ...
                        'r', ...
                        'EdgeColor', 'r', ...
                        'LineWidth', 2, ...
                        'FaceAlpha', 0.25, ...
                        'Visible', vis);
%                     data.edges(end).(['hl' edg]) = % create overlay patch from binary mask
                end
            else
                data.edges = [data.edges; Edges()];
                data.edges(end).timepoint = t;
                data.edges(end).timestamp = data.timestamps(t);
                data.edges(end).z = z;
                if isa(data.current_edge, 'imfreehand')
                    data.current_edge = data.current_edge.getPosition;
                end
                data.edges(end).(edg) = data.current_edge;
                data.edges(end).(['hl' edg]) = line(data.current_edge(:,1), ...
                    data.current_edge(:,2), ...
                    'Color', 'r', ...
                    'Visible', vis);
            end
        else
            data.edges = [data.edges; Edges()];
            data.edges(end).timepoint = t;
            data.edges(end).timestamp = data.timestamps(t);
            data.edges(end).z = z;
            if isa(data.current_edge, 'imfreehand')
                data.current_edge = data.current_edge.getPosition;
            end
            data.edges(end).(edg) = data.current_edge;
            data.edges(end).(['hl' edg]) = line(data.current_edge(:,1), ...
                    data.current_edge(:,2), ...
                    'Color', 'r', ...
                    'Visible', vis);
        end
    else
        data.edges = [data.edges; Edges()];
        data.edges(end).timepoint = t;
        data.edges(end).timestamp = data.timestamps(t);
        data.edges(end).z = z;
        data.edges(end).(edg) = data.current_edge;
        if ~( strcmp(edg, 'Rh4') || strcmp(edg, 'Rh6') )
            data.edges(end).(['hl' edg]) = line(data.current_edge(:,1), ...
                        data.current_edge(:,2), ...
                        'Color', 'r', ...
                        'Visible', vis);
        else
            data.edges(end).(['hl' edg]) = patch(data.current_edge(:,1), ...
                        data.current_edge(:,2), ...
                        'r', ...
                        'EdgeColor', 'r', ...
                        'LineWidth', 2, ...
                        'FaceAlpha', 0.25, ...
                        'Visible', vis);
        end
    end
    
    % update UI
    edg_let = {'L', 'R', 'M', 'Rh4', 'Rh6'};
    if strcmp(edg, 'Rh4') || strcmp(edg, 'Rh6')
        set(controls.hffchecks((data.z_offsets == z), (strcmp(edg_let, edg))), ...
        'Value', 1);
    else
        if any(data.edges((ts == t) & (zs == z)).edgeValidity(strcmp(edg_str, edg),:))
            set(controls.hffchecks((data.z_offsets == z), (strcmp(edg_let, edg))), ...
            'Value', 1);
        end
    end
    show_edges(controls, data);
    kids = get(controls.hax, 'Children');
    delete(kids(strcmp(get(kids, 'Type'), 'hggroup')));
    
    % check if all edges are saved - if so, allow moving on to the next
    % timepoint
%     if all(cell2mat(get(controls.hffchecks, 'Value')))
%         set(controls.hnextbut, 'Enable', 'on');
%     end
    
end