function [files_out, timestamps] = order_files(folder)

    % get times from metadata
    files = dir([folder filesep '*.czi']);
    first_t = [];
    n_T_planes = [];
    ts = [];
    n_Z_planes = [];

    for fidx = 1:length(files)
        czi_reader = bfGetReader([folder filesep files(fidx).name]);
        ome_meta = czi_reader.getMetadataStore();
        n_Z_planes = [n_Z_planes; double(ome_meta.getPixelsSizeZ(0).getNumberValue())];
        first_t = [first_t; double(ome_meta.getPlaneDeltaT(0, czi_reader.getIndex(0, 0, 0)).value())/60];
        n_T_planes = [n_T_planes; double(ome_meta.getPixelsSizeT(0).getNumberValue())];
        t_temp = zeros(1,50);
        for tidx = 1:n_T_planes(end)
            t_temp(tidx) = double(ome_meta.getPlaneDeltaT(0, czi_reader.getIndex(0, 0, tidx - 1)).value())/60;
        end
        ts = [ts; t_temp];
        czi_reader.close();
    end
    
    filenames = {files.name}';

    % extract saved file indices from file names
    openb  = strfind(filenames, '(');
    closeb = strfind(filenames, ')');
    fls_with_idx = ~cellfun(@isempty, strfind(filenames, '('));

    findices = zeros(length(filenames),1);
    for fidx = 1:length(filenames)
        if fls_with_idx(fidx)
            findices(fidx) = str2num(filenames{fidx}((openb{fidx}+1):(closeb{fidx}-1)));
        end
    end
    
    % populate timestamps
    timestamps = zeros(length(fls_with_idx),1);
    timestamps(~fls_with_idx) = ts(~fls_with_idx);

    unq_ts = ts(~fls_with_idx);

    for tidx = 1:length(unq_ts)
        t = unq_ts(tidx);
        fs = (ts(:,1) == t);
        times = ts(((ts(:,1) == t ) & (~fls_with_idx)),...
            1:n_T_planes(((ts(:,1) == t ) & (~fls_with_idx))));
        timestamps((ts(:,1) == t )) = times(findices(ts(:,1) == t)+1);
    end

    timestamps = timestamps - min(timestamps);
    [timestamps, idx] = sort(timestamps);
    files_out = files(idx);
%     disp(n_Z_planes(idx));
    disp(timestamps);

end