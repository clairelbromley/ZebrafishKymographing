function ap_lengths = calc_ap_lengths(data, xedge)


    ap_lengths = [];
    rhs = [4, 5, 6];
    pix_to_micron = double(data.ome_meta.getPixelsPhysicalSizeX(0).value(ome.units.UNITS.MICROM));
    
    if sum(xedge.rhombomereLimits) > 0
        if strcmp(data.AP_axis_method, 'Rhombomeres')
            for rh = rhs
                ap_lengths.(['Rh' num2str(rh)]).ap_lengths_max = abs(xedge.rhombomereLimits(rh-min(rhs)+2) - ...
                    xedge.rhombomereLimits(rh-min(rhs)+1)) * pix_to_micron;
                ap_lengths.AllRh.ap_lengths_max = abs(xedge.rhombomereLimits(end) - xedge.rhombomereLimits(1)) * pix_to_micron;
            end
        else
            disp('nonsense');
            % first, generate a binary mask of rhombomeres
            rh4msk = poly2mask(xedge.Rh4(:,1), xedge.Rh4(:,2), ...
                double(data.ome_meta.getPixelsSizeY(0).getValue()), ...
                double(data.ome_meta.getPixelsSizeX(0).getValue()));
            rh6msk = poly2mask(xedge.Rh6(:,1), xedge.Rh6(:,2), ...
                double(data.ome_meta.getPixelsSizeY(0).getValue()), ...
                double(data.ome_meta.getPixelsSizeX(0).getValue()));
            binim = rh4msk | rh6msk;

            % then work out where the central 50% of the width of the
            % narrower of the two rhombomeres lies
            rh_mat = [find(max(rh4msk, [], 1), 1, 'first') find(max(rh4msk, [], 1), 1, 'last');
                find(max(rh6msk, [], 1), 1, 'first') find(max(rh6msk, [], 1), 1, 'last')];
            w = min(diff(rh_mat, [], 2));
            tmp = rh_mat(diff(rh_mat, [], 2) == w, :);
            rnge = [round(tmp(1) + w/4) round(tmp(2) - w/4)];

            % then calculate the AP lengths in um across this range
            rh4_AP_arr = sum(rh4msk, 1) * pix_to_micron;
            rh4_AP_arr = rh4_AP_arr(rnge(1):rnge(2));
            rh6_AP_arr = sum(rh6msk, 1) * pix_to_micron;
            rh6_AP_arr = rh6_AP_arr(rnge(1):rnge(2));
            
            % (use for loop until can think of a nice vectorised way...)
            allrh_AP_arr = zeros(size(rh4_AP_arr));
            rh5_AP_arr = allrh_AP_arr;
            for colidx = rnge(1):rnge(2)
                allrh_AP_arr(colidx - rnge(1)+1) = (find(binim(:,colidx), 1, 'last') - ...
                    find(binim(:, colidx), 1, 'first')) * pix_to_micron;
                rh5_AP_arr(colidx - rnge(1)+1) = allrh_AP_arr(colidx - rnge(1)+1) - ...
                    rh4_AP_arr(colidx - rnge(1)+1) - ...
                    rh6_AP_arr(colidx - rnge(1)+1);
            end
                
            % and generate stats
            stats = {'mean', 'median', 'std', 'min', 'max'};
            individual_rhombomeres = {4, 5, 6, 'AllRh'};
            ap_lengths = generate_stats_struct(ap_lengths, ...
                            'ap_lengths', ...
                            stats, ...
                            individual_rhombomeres);
            ap_lengths = generate_stats(ap_lengths, ...
                'ap_lengths', ...
                stats, ...
                {4}, ...
                rh4_AP_arr);
            ap_lengths = generate_stats(ap_lengths, ...
                'ap_lengths', ...
                stats, ...
                {5}, ...
                rh5_AP_arr);
            ap_lengths = generate_stats(ap_lengths, ...
                'ap_lengths', ...
                stats, ...
                {6}, ...
                rh6_AP_arr);
            ap_lengths = generate_stats(ap_lengths, ...
                'ap_lengths', ...
                stats, ...
                {'AllRh'}, ...
                allrh_AP_arr);

        end
        
    else
        for rh = rhs
            ap_lengths.(['Rh' num2str(rh)]).ap_lengths_max = NaN;
        end
        ap_lengths.AllRh.ap_lengths_max = NaN;
    end
    
%     ap_lengths.AllRh = abs(edge.rhombomereLimits(end) - edge.rhombomereLimits(1)) * pix_to_micron;
    
end