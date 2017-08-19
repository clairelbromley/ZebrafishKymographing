function ap_lengths = calc_ap_lengths(data, edge)

    rhs = [4, 5, 6];
    
    for rh = rhs
        ap_lengths.(['Rh' num2str(rh)]) = abs(edge.rhombomereLimits(rh-min(rhs)+2) - ...
            edge.rhombomereLimits(rh-min(rhs)+1));
    end
    
    ap_lengths.AllRh = abs(edge.rhombomereLimits(end) - edge.rhombomereLimits(1));
    
end