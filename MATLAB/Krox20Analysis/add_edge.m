function data = add_edge(edg, controls, data, auto)

    % auto = true when edges have been automatically detected
    if ~exist('auto','var')
        auto = false;
    end	

    z = round((data.top_slice_index -  round(get(controls.hzsl, 'Value'))) * ...
        double(data.ome_meta.getPixelsPhysicalSizeZ(0).value(ome.units.UNITS.MICROM)));
    t = data.timepoint;
    
    vis = 'off';
    if get(controls.hshowchk, 'Value')
        vis = 'on';
    end
    
    if isa(data.current_edge, 'imfreehand')
        data.current_edge = data.current_edge.getPosition;
    end
    
    if isa(data.current_edge, 'imline')
        data.current_edge = data.current_edge.getPosition;
    end
    
    % check whether current z plane exists in array of stored edges...
    edg_str = {'L', 'R', 'M'};
    rhs = {'Rh4', 'Rh6'};
    if ~isempty(data.edges)
        ts = [data.edges.timepoint];
        zs = [data.edges.z];
        if any(ts == t)
            if any(zs(ts == t) == z)
                 data.edges((ts == t) & (zs == z)).timestamp = data.timestamps(t);
                 data.edges((ts == t) & (zs == z)).hpf = data.hpf(t);
                if any(strcmp(edg, edg_str))
                    data.edges((ts == t) & (zs == z)).(edg) = data.current_edge;
                    data.edges((ts == t) & (zs == z)).top_slice_index = data.top_slice_index;
                    data.edges((ts == t) & (zs == z)).edgeValidity(strcmp(edg_str, edg),:) = ...
                        check_edge_validity(data, data.edges((ts == t) & (zs == z)));
                    if any(data.edges((ts == t) & (zs == z)).edgeValidity(strcmp(edg_str, edg),:))
                        data.edges((ts == t) & (zs == z)).(edg) = data.current_edge;
                    end
                elseif any(strcmp(edg, rhs))
                    % check for whether rhombomeres have been drawn
                    % overlapping! 
                    % catch_overlapping_rhs(data, edg, rhs);
                    data.edges((ts == t) & (zs == z)).(edg) = data.current_edge;
                    data.edges((ts == t) & (zs == z)).top_slice_index = data.top_slice_index;
                    if ~auto
                        data = calculate_rhombomere_extents(data, controls);
                    end
                else
                    data.edges((ts == t) & (zs == z)).(edg) = data.current_edge;
                    data.edges((ts == t) & (zs == z)).top_slice_index = data.top_slice_index;
                end
                if any(strcmp(edg, [edg_str rhs]))
                    if isgraphics(data.edges(end).(['hl' edg]))
                        delete(data.edges(end).(['hl' edg]));
                    end
                end
                if any(strcmp(edg, edg_str))
                    if any(data.edges((ts == t) & (zs == z)).edgeValidity(strcmp(edg_str, edg),:))
                        data.edges((ts == t) & (zs == z)).(['hl' edg]) = line(data.current_edge(:,1), ...
                            data.current_edge(:,2), ...
                            'Color', 'r', ...
                            'Visible', vis);
                    end
                elseif any(strcmp(edg, rhs))
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
                data.edges(end).hpf = data.hpf(t);
                data.edges(end).z = z;
                data.edges(end).(edg) = data.current_edge;
                if any(strcmp(edg, [edg_str rhs]))
                    data.edges(end).(['hl' edg]) = line(data.current_edge(:,1), ...
                        data.current_edge(:,2), ...
                        'Color', 'r', ...
                        'Visible', vis);
                end
            end
        else
            data.edges = [data.edges; Edges()];
            data.edges(end).timepoint = t;
            data.edges(end).timestamp = data.timestamps(t);
            data.edges(end).hpf = data.hpf(t);
            data.edges(end).z = z;
            data.edges(end).(edg) = data.current_edge;
            data.edges(end).top_slice_index = data.top_slice_index;
            if any(strcmp(edg, [edg_str rhs]))
                data.edges(end).(['hl' edg]) = line(data.current_edge(:,1), ...
                        data.current_edge(:,2), ...
                        'Color', 'r', ...
                        'Visible', vis);
            end
        end
    else
        data.edges = [data.edges; Edges()];
        data.edges(end).timepoint = t;
        data.edges(end).timestamp = data.timestamps(t);
        data.edges(end).hpf = data.hpf(t);
        data.edges(end).z = z;
        data.edges(end).(edg) = data.current_edge;
        data.edges(end).top_slice_index = data.top_slice_index;
        if any(strcmp(edg, edg_str))
            data.edges(end).(['hl' edg]) = line(data.current_edge(:,1), ...
                        data.current_edge(:,2), ...
                        'Color', 'r', ...
                        'Visible', vis);
        elseif any(strcmp(edg, rhs))
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
    update_edges_display_checkboxes(data, controls);
        
    show_edges(controls, data);
    kids = get(controls.hax, 'Children');
    delete(kids(strcmp(get(kids, 'Type'), 'hggroup')));
    
    % check if all edges are saved - if so, allow moving on to the next
    % timepoint
%     if all(cell2mat(get(controls.hffchecks, 'Value')))
%         set(controls.hnextbut, 'Enable', 'on');
%     end
    
end