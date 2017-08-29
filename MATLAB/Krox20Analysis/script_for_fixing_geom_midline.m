function script_for_fixing_geom_midline(basepath, basefile, outfolder)

    %% import bioformats bits
    curr_dir = fileparts(mfilename('fullpath'));
    addpath(genpath(fileparts(curr_dir)));
    
    %% Loop over all output and recalculate stats (apart from midline definition)
    dirs = dir([basepath filesep '*Ncad Krox Analysis']);    
    
    for dind = 1:length(dirs)
        
        % rename .m to .mat
        ems = dir([basepath filesep dirs(dind).name filesep '*.m']);
        for emsind = 1:length(ems)
            [~, f, e] = fileparts(ems(emsind).name);
            movefile([basepath filesep dirs(dind).name filesep ems(emsind).name], ...
                [basepath filesep dirs(dind).name filesep f '.mat']);
        end
       
        nfs = dir([basepath filesep dirs(dind).name filesep '*.mat']);
        fs = {nfs.name};
        
        for effind = 1:length(fs)
            load([basepath filesep dirs(dind).name filesep fs{effind}], 'data');

            if isempty(basefile)
                data.czi_reader = bfGetReader([data.in_folder filesep data.filename]);
            else
                data.czi_reader = bfGetReader(basefile);
            end
            data.ome_meta = data.czi_reader.getMetadataStore();

            if ~isempty(outfolder)
                data.out_folder = outfolder;
            end

            data.midline_definition_method = 'none';

            ts = [data.edges.timepoint];
            for tind = min(ts(:)):max(ts(:))
                data.timepoint = tind;

                edges = calculate_output_stats(data);
                if ~isempty(edges)
                    hdr_string = save_results(data, edges);
                end


            end
        end
        
    end
    
    fid = fopen([data.out_folder filesep 'results.csv'],'a');
    fprintf(fid,hdr_string);
    fclose(fid);
    
    disp('Done corrections!');
    
end