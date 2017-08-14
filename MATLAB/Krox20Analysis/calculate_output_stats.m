function edges = calculate_output_stats(data)

    % filter edges structure for the correct timepoint
    edges = data.edges([data.edges.timepoint] == data.timepoint);
    
    % cycle through z positions
    for z = [edges.z]

        edge = edges([edges.z] == z);
        
        % midline sinuosity
        sinuosity_index = calc_sinuosity_index(data, edge);
        edges([edges.z] == z).midlineSinuosity = sinuosity_index;
        
        % basal-basal distance and deviation from geometrical midline
        % broken down by rhombomere
        basal_basal_distances = calc_bb_distances(data, edge);
        edges([edges.z] == z).basal_basal_distances = basal_basal_distances;
        
        % midline definition - defined as relative intensity of a (thick)
        % line following the midline versus a parallel line drawn midway
        % between the midline and the basal surface
        midline_definition = calc_midline_definition(data, edge);
        edges([edges.z] == z).midlineDefinition = midline_definition;
        
    end
end