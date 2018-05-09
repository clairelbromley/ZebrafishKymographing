% script to generate summary stats grouped by developmental stage

function [out, sht_names] =  dev_stage_wise_stats(embryos, data, input_stat_name, z_plane, out_folder, nanfilt)

    early = [14.5 16];
    late = [17 19.5];

    unq_embryos = unique(embryos);

    hpf = data.hpf;
        
    dev_stage = 1.0 * ( (hpf >= early(1)) & (hpf <= early(2)) ) + ...
        2.0 * ( (hpf >= late(1)) & (hpf <= late(2)) );
    
    early_mask = (dev_stage == 1);
    late_mask = (dev_stage == 2);
    dev_mask = [early_mask late_mask];
    
    z_mask = data.z == z_plane;
    
    sht_names = {};
    out = cell(2, length(unique(embryos)));

%     for stidx = 2:length(input_stat_name)
        
        sht_names = [sht_names ['Mean ' input_stat_name ]];
        sht_names = [sht_names ['Median ' input_stat_name]];
        sht_names = [sht_names ['Max ' input_stat_name]];
        sht_names = [sht_names ['N ' input_stat_name]];
        
        for eidx = 1:length(unq_embryos)
            
            emask = strcmp(embryos, unq_embryos{eidx})';
            
            for dstgidx = 1:2
                
                msk = emask & dev_mask(:, dstgidx) & z_mask & ~nanfilt;
                out{dstgidx, eidx, 1} = nanmean(data.(input_stat_name)(msk));
                out{dstgidx, eidx, 2} = nanmedian(data.(input_stat_name)(msk));
                out{dstgidx, eidx, 3} = nanmax(data.(input_stat_name)(msk));
                out{dstgidx, eidx, 4} = sum(~isnan(data.(input_stat_name)(msk)));
            end

        end
        
%     end
    
    %% handle export
    
    dstg_lbl = {'' 'early' 'late'};
    fname = [out_folder filesep sprintf('embryo-wise, dev stage-wise summary stats %s, z = %0.1f.xlsx', input_stat_name, z_plane)];
        
    for shtidx = 1:length(sht_names)
        disp(sht_names{shtidx})
        annotated_out = [unq_embryos; squeeze(out(:,:,shtidx))];
        annotated_out = [dstg_lbl' annotated_out];
        xlswrite(fname, annotated_out, sht_names{shtidx}(1:(min(30, length(sht_names{shtidx})))));
    end
    
end
        