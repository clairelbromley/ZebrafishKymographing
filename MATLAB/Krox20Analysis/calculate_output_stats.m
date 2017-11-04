function edges = calculate_output_stats(data)

    if ~isempty(data.edges)

        % filter edges structure for the correct timepoint
        edges = data.edges([data.edges.timepoint] == data.timepoint);

        if ~isempty(edges)
            % cycle through z positions
            for z = [edges.z]

                edge = edges([edges.z] == z);

                % midline sinuosity
                [sinuosity_index, manual_length] = calc_sinuosity_index(data, edge);
                edges([edges.z] == z).midlineIndexOfStraightness = sinuosity_index;
                edges([edges.z] == z).midlineLength = manual_length;

                % anterior-posterior lengths of rhombomeres
                ap_lengths = calc_ap_lengths(data, edge);
                edges([edges.z] == z).ap_lengths = ap_lengths;

                % basal-basal distance and deviation from geometrical midline
                % broken down by rhombomere
                basal_basal_distances = calc_bb_distances(data, edge);
                edges([edges.z] == z).basal_basal_distances = basal_basal_distances;

                % midline definition - defined as relative intensity of a (thick)
                % line following the midline versus a parallel line drawn midway
                % between the midline and the basal surface
                if ~strcmp(data.midline_definition_method, 'none')
                    midline_definition = calc_midline_definition(data, edge);
                    edges([edges.z] == z).midlineDefinition = midline_definition;
                end

            end
        end
    else
        edges = [];
    end
end