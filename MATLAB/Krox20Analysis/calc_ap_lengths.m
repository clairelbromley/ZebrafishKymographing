function ap_lengths = calc_ap_lengths(data, xedge)


    rhs = [4, 5, 6];
    pix_to_micron = double(data.ome_meta.getPixelsPhysicalSizeX(0).value(ome.units.UNITS.MICROM));
    
    for rh = rhs
        if sum(xedge.rhombomereLimits) > 0
            if strcmp(data.AP_axis_method, 'Rhombomeres')
                ap_lengths.(['Rh' num2str(rh)]) = abs(xedge.rhombomereLimits(rh-min(rhs)+2) - ...
                    xedge.rhombomereLimits(rh-min(rhs)+1)) * pix_to_micron;
                ap_lengths.AllRh = abs(xedge.rhombomereLimits(end) - xedge.rhombomereLimits(1)) * pix_to_micron;
            else
                disp('nonsense');
                %CONSIDER WHETHER TO DO AP LENGTHS FOR ALL RH IN THIS CASE.
                %IF SO, NEED TO BE CAREFUL TO DIFFERENTIATE BETWEEN LOWER
                %AND UPPER EDGES OF RHOMBOMERES - SAY TAKE SEGMENT WITHIN X
                %PIXELS OF UPPER (HIGH Y) AND LOWER (LOW Y) EDGES
                %RESPECTIVELY. 
            end
        else
            ap_lengths.(['Rh' num2str(rh)]) = NaN;
            ap_lengths.AllRh = NaN;
        end
    end
    
%     ap_lengths.AllRh = abs(edge.rhombomereLimits(end) - edge.rhombomereLimits(1)) * pix_to_micron;
    
end