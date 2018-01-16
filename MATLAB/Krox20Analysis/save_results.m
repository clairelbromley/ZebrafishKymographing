function hdr_string = save_results(data, edges)

    results = [[edges.timepoint]' [edges.timestamp]' [edges.hpf]' [edges.z]' [edges.midlineIndexOfStraightness]' [edges.midlineLength]'];
    hdr_string = 'Timepoint,time stamp,hpf,z,NAS index of straightness,NAS length (um)';
    
    rhs = fields(edges(1).basal_basal_distances);
    stats_strs = fields(edges(1).basal_basal_distances.(rhs{1}));
    
    for rhidx = 1:length(rhs)
        tmp_res = [];
        tmp_hdr_str = '';
        for eidx = 1:length(edges)
            if ~isempty(edges(eidx).ap_lengths)
                tmp_tmp_res = zeros(1, length(thisrh_ststrs));
                thisrh_ststrs = fields(edges(eidx).ap_lengths.(rhs{rhidx}));
                for ststridx = 1:length(thisrh_ststrs)
                    if isempty(edges(eidx).ap_lengths.(rhs{rhidx}).(thisrh_ststrs{ststridx}))
                    	edges(eidx).ap_lengths.(rhs{rhidx}).(thisrh_ststrs{ststridx}) = NaN;
                    end
                    tmp_tmp_res(ststridx) = edges(eidx).ap_lengths.(rhs{rhidx}).(thisrh_ststrs{ststridx});
                end
                tmp_res = [tmp_res; tmp_tmp_res];
            else
                tmp_res = [tmp_res; NaN(tmp_tmp_res)];
            end
        end
        results = [results tmp_res];
        for ststridx = 1:length(thisrh_ststrs)
            hdr_string = [hdr_string ', AP length ' rhs{rhidx} ' - ' thisrh_ststrs{ststridx}];
        end
    end
    
    for rhidx = 1:length(rhs)
        for stat_idx = 1:length(stats_strs)
            tmp_res = [];
            for eidx = 1:length(edges)
                if ~isempty(edges(eidx).basal_basal_distances)
                    tmp_res = [tmp_res; ...
                        edges(eidx).basal_basal_distances.(rhs{rhidx}).(stats_strs{stat_idx})];
                else
                    tmp_res = [tmp_res; NaN];
                end
            end
            results = [results tmp_res];
            hdr_string = [hdr_string ',' rhs{rhidx} ' - ' stats_strs{stat_idx}];
        end
    end
    
    if ~strcmp(data.midline_definition_method, 'none')
        stats_strs = fields(edges(1).midlineDefinition.(rhs{4}));
        for rhidx = 1:length(rhs)
            for stat_idx = 1:length(stats_strs)
                tmp_res = [];
                for eidx = 1:length(edges)
                    if ~isempty(edges(eidx).midlineDefinition)
                        if isfield(edges(eidx).midlineDefinition.(rhs{rhidx}), (stats_strs{stat_idx}))
                            tmp_res = [tmp_res; ...
                                edges(eidx).midlineDefinition.(rhs{rhidx}).(stats_strs{stat_idx})];
                        else
                            tmp_res = [tmp_res; NaN];
                        end
                    else
                        tmp_res = [tmp_res; NaN];
                    end
                end
                results = [results tmp_res];
                hdr_string = [hdr_string ',' rhs{rhidx} ' - ' stats_strs{stat_idx}];
            end
        end
    end
    
    % ENSURE THAT CORRECT RHOMBOMERE NUMBERS ARE USED IN THE RESULTS OUTPUT
    % WITHOUT PROPAGATING CHANGE THROUGHOUT REST OF CODE:
    hdr_string = strrep(hdr_string, 'Rh4', 'Rh3');
    hdr_string = strrep(hdr_string, 'Rh5', 'Rh4');
    hdr_string = strrep(hdr_string, 'Rh6', 'Rh5');
    hdr_string = [hdr_string '\r\n'];
    dlmwrite([data.out_folder filesep 'results.csv'], results, '-append', 'delimiter', ',');
    
end


