root = 'C:\Users\Doug\Google Drive\NcadKrox data';

curr_dir = fileparts(mfilename('fullpath'));
addpath(genpath(fileparts(curr_dir)));

proc_fldr = uigetdir(root, 'Choose folder containing PROCESSED data...');
if (proc_fldr == 0)
    return;
end
raw_fldr = uigetdir(root, 'Choose folder containing RAW data...');
if (raw_fldr == 0)
    return;
end

proc_files = dir([proc_fldr filesep '*.czi']);
raw_files = dir([raw_fldr filesep '*.czi']);


% for fidx = 1:1
for fidx = 1:length(proc_files)

    fprintf('Handling file %d of %d...\n', fidx, length(proc_files));
    
    if ~strcmp(proc_files(fidx).name, raw_files(fidx).name)
        error('FileError:filesDontMatch', ...
             'The processed and raw filenames do not match. Please check file naming!');
    end
    
	raw_czi_reader = bfGetReader([raw_fldr filesep raw_files(fidx).name]);
    raw_ome_meta = raw_czi_reader.getMetadataStore(); 
    N_t_planes = double(raw_ome_meta.getPixelsSizeT(0).getNumberValue());
    t = javaArray('ome.units.quantity.Time', 1, N_t_planes);
    for tidx = 1:N_t_planes
        t(1, tidx) = raw_ome_meta.getPlaneDeltaT(0, raw_czi_reader.getIndex(0, 0, tidx - 1));
        fprintf('Target t = %0.2f\n', double(t(1, tidx).value()));
    end
    raw_czi_reader.close();
    
    proc_czi_reader = bfGetReader([proc_fldr filesep proc_files(fidx).name]);
    proc_ome_meta = proc_czi_reader.getMetadataStore(); 
    for tidx = 1:N_t_planes
       fprintf('Previous processed t = %0.2f\n', double(proc_ome_meta.getPlaneDeltaT(0, proc_czi_reader.getIndex(0, 0, tidx - 1)).value()));
       proc_ome_meta.setPlaneDeltaT(t(1, tidx), 0, proc_czi_reader.getIndex(0, 0, tidx - 1));
       fprintf('New processed t = %0.2f\n', double(proc_ome_meta.getPlaneDeltaT(0, proc_czi_reader.getIndex(0, 0, tidx - 1)).value()));
    end
    proc_czi_reader.close();
    proc_czi_reader.setMetadataStore(proc_ome_meta);
    
end