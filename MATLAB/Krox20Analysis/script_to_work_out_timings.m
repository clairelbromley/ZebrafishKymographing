folder = 'D:\KroxNcad files\Exp63\E2';
files = dir([folder filesep '*.czi']);
first_t = [];
n_T_planes = [];
ts = [];

for fidx = 1:length(files)
    czi_reader = bfGetReader([folder filesep files(fidx).name]);
    ome_meta = czi_reader.getMetadataStore();
    first_t = [first_t; double(ome_meta.getPlaneDeltaT(0, czi_reader.getIndex(0, 0, 0)).value())/60];
    n_T_planes = [n_T_planes; double(ome_meta.getPixelsSizeT(0).getNumberValue())];
    t_temp = zeros(1,50);
    for tidx = 1:n_T_planes(end)
        t_temp(tidx) = double(ome_meta.getPlaneDeltaT(0, czi_reader.getIndex(0, 0, tidx - 1)).value())/60;
    end
    ts = [ts; t_temp];
    czi_reader.close();
end


