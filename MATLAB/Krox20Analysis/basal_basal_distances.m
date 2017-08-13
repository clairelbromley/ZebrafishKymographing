function basal_basal_distances = calc_bb_distances(data, edge)

    theta = -deg2rad(edge.tissueRotation);
    rotMatrix = [cos(theta) -sin(theta); sin(theta) cos(theta)];
    c = [double(data.ome_meta.getPixelsSizeY(0).getNumberValue()), ...
        double(data.ome_meta.getPixelsSizeX(0).getNumberValue())]/2;
    
    edgLs = {'L', 'M', 'R'};
    rhs = [4, 5, 6];
    
    for edg = edgLs
        cc = repmat(c, size(edge.(edg), 1), 1);
        rotated_e.(edg) = (rotMatrix * (edge.M - cc)')' + cc;        
    end
    
    for rh = rhs
        for edg = edgLs
            temp_e.(edg) = rotated_e.(edg);
            msk1 = rotated_e.(edg)(:, 2) > edge.rhombomereLimits(rh-min(rhs)+2);
            msk2 = rotated_e.(edg)(:, 2) < edge.rhombomereLimits(rh-min(rhs)+1);
            msk = msk1 | msk2;
            temp_e.(edg)(msk, :) = [];
            
        end
        
    end
    

end