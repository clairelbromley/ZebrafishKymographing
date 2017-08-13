function hdr_string = save_results(data, edges)

    results = [[edges.timepoint]' [edges.z]' [edges.midlineSinuosity]'];
    hdr_string = 'Timepoint,z,midline sinuoisity index';
    
    rhs = fields(edges(1).basal_basal_distances);
    stats_strs = fields(edges(1).basal_basal_distances.(rhs{1}));
    
    for rhidx = 1:length(rhs)
        for stat_idx = 1:length(stats_strs)
            tmp_res = [];
            for eidx = 1:length(edges)
                tmp_res = [tmp_res; ...
                    edges(eidx).basal_basal_distances.(rhs{rhidx}).(stats_strs{stat_idx})];
            end
            results = [results tmp_res];
            hdr_string = [hdr_string ',' rhs{rhidx} ' - ' stats_strs{stat_idx}];
        end
    end
    
    hdr_string = [hdr_string '\r\n'];
    dlmwrite([data.out_folder filesep 'results.csv'], results, '-append', 'delimiter', ',');
    
end


