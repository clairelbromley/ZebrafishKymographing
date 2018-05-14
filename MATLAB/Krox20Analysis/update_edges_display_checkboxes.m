function update_edges_display_checkboxes(data, controls)
% update the checkboxes in the lower left of the GUI that show which edges
% have been found for the current timepoint

    % get edges and filter by timepoint
    edgs = data.edges([data.edges.timepoint] == data.timepoint);
    zs = data.z_offsets;
    
    edg_let = {'L', 'R', 'M', 'Rh4', 'Rh6'};
    for edgidx = 1:length(edgs)
        edg = edgs(edgidx);
        z = edg.z;
        for edgl = edg_let
            if ~isempty(edg.(char(edgl)))
                set(controls.hffchecks((data.z_offsets == z), (strcmp(edg_let, edgl))), ...
                    'Value', 1);
            end
        end
    end
end