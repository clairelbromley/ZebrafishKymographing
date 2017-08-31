% script to generate summary stats grouped by developmental stage

function [out, sht_names] =  dev_stage_wise_stats(embryos, data, input_headers, z_plane, out_folder)

    early = [14.5 16];
    late = [17 19.5];
    if strcmp(input_headers{1}, 'Embryo number')
        input_headers = input_headers(2:end);
    end
    unq_embryos = unique(embryos);

    hpf = data(:,1);
%     med_devfromg = data(:,2);
%     max_devfromg = data(:,3);
%     med_bb_dist = data(:,4);
%     max_bb_dist = data(:,5);
%     ios = data(:,6);
        
    dev_stage = 1.0 * ( (hpf >= early(1)) & (hpf <= early(2)) ) + ...
        2.0 * ( (hpf >= late(1)) & (hpf <= late(2)) );
    
    early_mask = (dev_stage == 1);
    late_mask = (dev_stage == 2);
    dev_mask = [early_mask late_mask];
    
    sht_names = {};
    out = cell(2, length(unique(embryos)), 5 * 3);

    for stidx = 2:6
        
        sht_names = [sht_names [input_headers{stidx} ' mean']];
        sht_names = [sht_names [input_headers{stidx} ' median']];
        sht_names = [sht_names [input_headers{stidx} ' max']];
        sht_names = [sht_names [input_headers{stidx} ' N']];
        
        for eidx = 1:length(unq_embryos)
            
            emask = strcmp(embryos, unq_embryos{eidx});
            
            for dstgidx = 1:2
                
                msk = emask & dev_mask(:, dstgidx);
                out{dstgidx, eidx, ((stidx - 2) * 4 + 1)} = mean(data(msk, stidx));
                out{dstgidx, eidx, ((stidx - 2) * 4 + 2)} = median(data(msk, stidx));
                out{dstgidx, eidx, ((stidx - 2) * 4 + 3)} = max(data(msk, stidx));
                out{dstgidx, eidx, ((stidx - 2) * 4 + 4)} = sum(msk);
            end

        end
        
    end
    
    %% handle export
    
    dstg_lbl = {'' 'early' 'late'};
    fname = [out_folder filesep sprintf('embryo-wise, dev stage-wise summary stats WITH NS, z = %0.1f.xlsx', z_plane)];
        
    for shtidx = 1:length(sht_names)
        disp(sht_names{shtidx})
        annotated_out = [unq_embryos'; squeeze(out(:,:,shtidx))];
        annotated_out = [dstg_lbl' annotated_out];
        xlswrite(fname, annotated_out, sht_names{shtidx});
    end
    
end
        