function script_for_fixing_geom_midline(basepath, basefile, outfolder, cleaned_output_xlsx)

    %% import bioformats bits
    curr_dir = fileparts(mfilename('fullpath'));
    addpath(genpath(fileparts(curr_dir)));   
    
    cleaned_out = xlsread(cleaned_output_xlsx);
    cleaned_timepoint = cleaned_out(:,1);
    cleaned_timestamp = cleaned_out(:,2);
    cleaned_IS = cleaned_out(:, 4);
    cleaned_R4AP = cleaned_out(:,5);
    cleaned_R5AP = cleaned_out(:,6);
    cleaned_R6AP = cleaned_out(:,7);
    
    
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
                mkdir(outfolder);
            end

            

            ts = [data.edges.timepoint];
            for tind = min(ts(:)):max(ts(:))
                data.timepoint = tind;

                data.midline_definition_method = 'none';
                edges = calculate_output_stats(data);
                
                keep_edges = false(length(edges), 1);
                for edgidx = 1:length(edges)
                    edge = edges(edgidx);
                    ios = edge.midlineIndexOfStraightness;
                    r4apl = edge.ap_lengths.Rh4;
                    r5apl = edge.ap_lengths.Rh5;
                    r6apl = edge.ap_lengths.Rh6;
                    msk = (round(1E3 * ios) == round(1E3 * cleaned_IS)) & ...
                        (round(1E3 * r4apl) == round(1E3 * cleaned_R4AP)) & ...
                        (round(1E3 * r5apl) == round(1E3 * cleaned_R5AP)) & ...
                        (round(1E3 * r6apl) == round(1E3 * cleaned_R6AP));
                    keep_edges(edgidx) = logical(sum(msk));
                end
                edges(~keep_edges) = [];
                
                if ~isempty(edges)
                    data.midline_definition_method = 'mean';
                    saved_midline_location = [basepath filesep dirs(dind).name];
                    edges = recalculate_midline_definition(data, edges, saved_midline_location);
                    if ~isempty(edges)
                        edges(edgidx).timepoint = cleaned_timepoint(msk);
                        edges(edgidx).timestamp = cleaned_timestamp(msk);
                        hdr_string = save_results(data, edges);
                    end
                end
            end
        end
    end
    
    fid = fopen([data.out_folder filesep 'results.csv'],'a');
    fprintf(fid,hdr_string);
    fclose(fid);
    
    disp('Done corrections!');
    
end