function calculate_output_stats(data)

    % filter edges structure for the correct timepoint
    edges = data.edges(data.edges.timepoint == data.timepoint);
    
    % cycle through z positions
    for z = [edges.z]

        edge = edges(edges.z == z);
        
        % midline sinuoisity
        theta = edge.tissueRotation;
        rotMatrix = [cos(theta) -sin(theta); sin(theta) cos(theta)];
        rotated_midline = rotMatrix * edge.M;
        rotated_midline(:, rotated_midline(:, 2) > edge.rhombomereLimits(2)) = [];
        rotated_midline(:, rotated_midline(:, 2) < edge.rhombomereLimits(1)) = [];
        straight_length = sqrt((rotated_midline(end, 1) - rotated_midline(1, 1))^2 + ...
            (rotated_midline(end, 2) - rotated_midline(1, 2))^2 );
        manual_length = 0;
        for idx = 2:length(rotated_midline)
            manual_length = manual_length + ...
                sqrt( (rotated_midline(idx, 1) - rotated_midline(idx - 1, 1))^2 + ...
                (rotated_midline(idx, 2) - rotated_midline(idx - 1, 2))^2 );
        end
        sinuosity_index = manual_length/straight_length;
            
        
        
        
    end

end