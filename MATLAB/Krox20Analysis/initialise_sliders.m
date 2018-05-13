function initialise_sliders(controls, data)
%% set range for sliders based on contents of metadata
    data = getappdata(controls.hfig, 'data');

    zPlanes = double(data.ome_meta.getPixelsSizeZ(0).getValue());
    cPlanes = double(data.ome_meta.getPixelsSizeC(0).getValue());

    set(controls.hzsl, 'Max', zPlanes);
    set(controls.hzsl, 'Min', 1);
    set(controls.hzsl, 'Value', 1);
    if zPlanes > 1
        sstep = zPlanes - 1;
    else
        sstep = 1;
    end
    set(controls.hzsl, 'SliderStep', [(1/sstep) (1/sstep)]);
    
    if isfield(data, 'rh_definition_method')
        if strcmp(data.rh_definition_method, 'MorphologicalMarkers')
            cPlanes = cPlanes+1;
        end
    end
    set(controls.hcsl, 'Max', cPlanes);
    set(controls.hcsl, 'Min', 1);
    set(controls.hcsl, 'Value', 1);
    if cPlanes > 1
        sstep = cPlanes - 1;
        set(controls.hcsl, 'Enable', 'on');
    else
        sstep = 1;
        set(controls.hcsl, 'Enable', 'off');
    end
    set(controls.hcsl, 'SliderStep', [(1/sstep) (1/sstep)]);

    setappdata(controls.hfig, 'data', data);

end