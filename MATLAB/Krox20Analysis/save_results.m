function hdr_string = save_results(data, edges)

    results = [[edges.timepoint]' [edges.timestamp]' [edges.hpf]' [edges.z]' [edges.midlineIndexOfStraightness]' [edges.midlineLength]'];
    hdr_string = 'Timepoint,time stamp,hpf,z,midline index of straightness,midline length (um)';
    
    rhs = fields(edges(1).basal_basal_distances);
    stats_strs = fields(edges(1).basal_basal_distances.(rhs{1}));
    
    for rhidx = 1:length(rhs)
        tmp_res = [];
        for eidx = 1:length(edges)
            if ~isempty(edges(eidx).ap_lengths)
                tmp_res = [tmp_res; ...
                    edges(eidx).ap_lengths.(rhs{rhidx})];
            else
                tmp_res = [tmp_res; NaN];
            end
        end
        results = [results tmp_res];
        hdr_string = [hdr_string ',' rhs{rhidx} ' - AP length'];
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
        stats_strs = fields(edges(1).midlineDefinition.(rhs{1}));
        for rhidx = 1:length(rhs)
            for stat_idx = 1:length(stats_strs)
                tmp_res = [];
                for eidx = 1:length(edges)
                    if ~isempty(edges(eidx).midlineDefinition)
                        tmp_res = [tmp_res; ...
                            edges(eidx).midlineDefinition.(rhs{rhidx}).(stats_strs{stat_idx})];
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
    hdr_string = strrep(hdr_string, 'Rh6', 'Rh4');
    hdr_string = [hdr_string '\r\n'];
    dlmwrite([data.out_folder filesep 'results.csv'], results, '-append', 'delimiter', ',');
    
end


