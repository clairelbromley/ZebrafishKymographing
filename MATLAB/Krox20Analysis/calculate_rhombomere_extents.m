function data = calculate_rhombomere_extents(data)

    % get edges of rhombomeres
    z = round((data.top_slice_index -  round(get(controls.hzsl, 'Value'))) * ...
    double(data.ome_meta.getPixelsPhysicalSizeZ(0).value(ome.units.UNITS.MICROM)));
    t = data.timepoint;

    ts = [data.edges.timepoint];
    zs = [data.edges.z];
    
    rh4 = data.edges((ts == t) & (zs == z)).Rh4;
    rh6 = data.edges((ts == t) & (zs == z)).Rh6;
    
    

end