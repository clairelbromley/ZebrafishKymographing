curr_dir = fileparts(mfilename('fullpath'));
addpath(genpath(fileparts(curr_dir)));   

root = 'C:\Users\Doug\Desktop\analysis';
depths = [35 40 45];
starttimestr = strrep(datestr(now()), ':', '_'); 

dirs = dir([root filesep 'Exp*']);
dirs = dirs([dirs.isdir]);

for expidx = 1:length(dirs)
%     if expidx ~= 7
%         continue;
%     end
    dtfldrs = dir([root filesep dirs(expidx).name filesep '*Aug*']);
    results_xls_fpath = [root filesep dirs(expidx).name ' results fixed geoMid.xlsx'];
    [~,~,result_data] = xlsread(results_xls_fpath);
    prev_tp = cell2mat(result_data(2:end, 1));
    prev_ts = cell2mat(result_data(2:end, 2));
    dlmwrite([root filesep dirs(expidx).name filesep starttimestr ' results_newMidlineStuff.csv'], []);
    
     for dtfldidx = 1:length(dtfldrs)
         
         % rename .m to .mat
        ems = dir([root filesep dirs(expidx).name filesep dtfldrs(dtfldidx).name filesep '*.m']);
        for emsind = 1:length(ems)
            [~, f, e] = fileparts(ems(emsind).name);
            movefile([root filesep dirs(expidx).name filesep dtfldrs(dtfldidx).name filesep ems(emsind).name], ...
                [root filesep dirs(expidx).name filesep dtfldrs(dtfldidx).name filesep f '.mat']);
        end
        
        d = dir([root filesep dirs(expidx).name filesep ...
            dtfldrs(dtfldidx).name filesep 'backup.mat']);
        
        if isempty(d)
            continue;
        else
            
            dt_pth = [root filesep dirs(expidx).name filesep ...
                dtfldrs(dtfldidx).name];
            load([dt_pth filesep 'backup.mat']);
        end
        
        disp(dirs(expidx).name);
        
        if ~isempty(data.edges)
            results = [[data.edges.timepoint]' [data.edges.timestamp]' [data.edges.z]' ];

            data.czi_reader = bfGetReader([data.in_folder filesep data.filename]);
            data.ome_meta = data.czi_reader.getMetadataStore();
            data.midline_definition_method = 'max';

            for edgidx = 1:length(data.edges)

                if sum(prev_tp == data.edges(edgidx).timepoint) > 0
                    tstmp = prev_ts(prev_tp == data.edges(edgidx).timepoint);
                    data.edges(edgidx).timestamp = tstmp(1);
                end
                    curr_edge = data.edges(edgidx);
    %                 old_midline_def = recalc_old_midline_def(data, curr_edge, ...
    %                     dt_pth);
                   % PERFORM CHECKING FOR OLD MIDLINE STUFFS
                   data.edges(edgidx).midlineDefinition.new_midline_definition = calc_new_midline_stats(data, curr_edge, ...
                        dt_pth);
            end

            rhs = {'AllRh'};
            if ~strcmp(data.midline_definition_method, 'none')
                stats_strs = fields(data.edges(1).midlineDefinition.new_midline_definition.(rhs{1}));
                for rhidx = 1:length(rhs)
                    hdr_string = 'Timepoint,time stamp,z';
                    for stat_idx = 1:length(stats_strs)
                        tmp_res = [];
                        for eidx = 1:length(data.edges)
                            if ~isempty(data.edges(eidx).midlineDefinition)
                                tmp_res = [tmp_res; ...
                                    double(data.edges(eidx).midlineDefinition.new_midline_definition.(rhs{rhidx}).(stats_strs{stat_idx}))];
                            else
                                tmp_res = [tmp_res; NaN];
                            end
                        end
                        results = [results tmp_res];
                        hdr_string = [hdr_string ',' rhs{rhidx} ' - ' stats_strs{stat_idx}];
                    end
                end
            end

            dlmwrite([root filesep dirs(expidx).name filesep starttimestr ' results_newMidlineStuff.csv'], results, '-append', 'delimiter', ',');

         end
     end
     
     hdr_string = [hdr_string '\r\n'];
     fid = fopen([root filesep dirs(expidx).name filesep starttimestr ' results_newMidlineStuff.csv'],'a');
     fprintf(fid,hdr_string);
     fclose(fid);
    
    
end
                
        
        
        