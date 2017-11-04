function [sinuosity_index, manual_length] = calc_sinuosity_index(data, edge) 

    % use "index of straightness" as defined in Moniar 2010
    if ~isempty(edge.M)
        pix_to_micron = double(data.ome_meta.getPixelsPhysicalSizeX(0).value(ome.units.UNITS.MICROM));
        theta = -deg2rad(edge.tissueRotation);
        rotMatrix = [cos(theta) -sin(theta); sin(theta) cos(theta)];
        c = [double(data.ome_meta.getPixelsSizeY(0).getNumberValue()), ...
            double(data.ome_meta.getPixelsSizeX(0).getNumberValue())]/2;
        cc = repmat(c, size(edge.M, 1), 1);
        rotated_midline = (rotMatrix * (edge.M - cc)')' + cc;
        msk1 = rotated_midline(:, 2) > edge.rhombomereLimits(4);
        msk2 = rotated_midline(:, 2) < edge.rhombomereLimits(1);
        msk = msk1 | msk2;
        rotated_midline(msk, :) = [];
        straight_length = sqrt((rotated_midline(end, 1) - rotated_midline(1, 1))^2 + ...
            (rotated_midline(end, 2) - rotated_midline(1, 2))^2 ) * pix_to_micron;
        manual_length = 0;
        for idx = 2:length(rotated_midline)
            manual_length = manual_length + ...
                sqrt( (rotated_midline(idx, 1) - rotated_midline(idx - 1, 1))^2 + ...
                (rotated_midline(idx, 2) - rotated_midline(idx - 1, 2))^2 );
        end
        
        manual_length = manual_length * pix_to_micron;
        
        sinuosity_index = manual_length/straight_length - 1;
    else
        sinuosity_index = NaN;
        manual_length = NaN;
    end
    
end