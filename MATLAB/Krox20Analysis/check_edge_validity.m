function edge_valid = check_edge_validity(data, edge)

    % check that the drawn edge spans rhombomeres 4-6
    
    if isempty(edge.rhombomereLimits)
        % for now, allow edges to be drawn if no rhombomeres have been
        % identified. 
        edge_valid = true;
        return;
    end
    
    theta = -deg2rad(edge.tissueRotation);
    rotMatrix = [cos(theta) -sin(theta); sin(theta) cos(theta)];
    c = [double(data.ome_meta.getPixelsSizeY(0).getNumberValue()), ...
        double(data.ome_meta.getPixelsSizeX(0).getNumberValue())]/2;
    
    cc = repmat(c, size(data.current_edge, 1), 1);
    rotated_e = (rotMatrix * (data.current_edge - cc)')' + cc; 
    y = rotated_e(:,2);
    
    edge_valid = (max(y) > max(edge.rhombomereLimits)) && ...
        (min(y) < min(edge.rhombomereLimits));

end