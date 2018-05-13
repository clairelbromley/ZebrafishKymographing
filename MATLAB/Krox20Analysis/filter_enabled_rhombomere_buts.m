function filter_enabled_rhombomere_buts(data, controls)
% if morphological markers are being used for rhombomere definition, which
% buttons should be enabled depends on which elements have been drawn so
% far...

    rhl_buts = [controls.hrh4topbut, ...
                controls.hrh4botbut, ...
                controls.hrh6topbut, ...
                controls.hrh6botbut];
            
    set(rhl_buts, 'Enable', 'off');
    set([rhl_buts(1) rhl_buts(3)], 'Enable', 'on');
    
    z = round((data.top_slice_index -  round(get(controls.hzsl, 'Value'))) * ...
        double(data.ome_meta.getPixelsPhysicalSizeZ(0).value(ome.units.UNITS.MICROM)));
    t = data.timepoint;

    if ~isempty(data.edges)
        ts = [data.edges.timepoint];
        zs = [data.edges.z];
        if any(ts == t)
            if any(zs(ts == t) == z)
                 if ~isempty(data.edges((ts == t) & (zs == z)).Rh4Top)
                     set(controls.hrh4botbut, 'Enable', 'on');
                 end
                 if ~isempty(data.edges((ts == t) & (zs == z)).Rh6Top)
                     set(controls.hrh6botbut, 'Enable', 'on');
                 end
            end
        end          
    end
                
    setappdata(controls.hfig, 'data', data);

end