function calculate_output_stats(data)

    % filter edges structure for the correct timepoint
    edges = data.edges([data.edges.timepoint] == data.timepoint);
    
    % cycle through z positions
    for z = [edges.z]

        edge = edges([edges.z] == z);
        
        % midline sinuoisity
        theta = edge.tissueRotation;
        rotMatrix = [cos(theta) -sin(theta); sin(theta) cos(theta)];
        c = [double(data.ome_meta.getPixelsSizeY(0).getNumberValue()), ...
            double(data.ome_meta.getPixelsSizeX(0).getNumberValue())]/2;
        cc = repmat(c, size(edge.M, 1), 1);
        rotated_midline = (rotMatrix * (edge.M - cc)')' + cc;
        msk1 = rotated_midline(:, 2) > edge.rhombomereLimits(2);
        msk2 = rotated_midline(:, 2) < edge.rhombomereLimits(1);
        msk = msk1 | msk2;
        rotated_midline(msk, :) = [];
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