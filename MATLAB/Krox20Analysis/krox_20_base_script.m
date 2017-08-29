function krox_20_base_script()

    %% Function to process krox20 data for tissue morphology
    curr_dir = fileparts(mfilename('fullpath'));
    addpath(genpath(fileparts(curr_dir)));
    
    %% Parameters
    z_offsets = [35, 40, 45];
    channel_names = {'Ncad', 'Krox20'};
    scale_bar_length_um = 20;
    midline_definition_method = 'max';  %'none', 'max' or 'mean'

    %% Choose base folder
    folder = uigetdir([], ...
        'Choose a folder containing a timecourse of CZI files...');

    if (folder == 0) 
        return;
    end
    
    %% Choose and setup output folder
    out_folder = uigetdir(folder, ...
        'Choose a location to save the output to');
    
    if (out_folder == 0)
        return;
    end
    
    tstamp = strrep(datestr(now), ':', '_');
    out_folder = [out_folder filesep tstamp ' Ncad Krox Analysis'];
    mkdir(out_folder)
    data.out_folder = out_folder;
    dlmwrite([data.out_folder filesep 'results.csv'], []);
    data.in_folder = folder;
    
    % get files, order by timestamp and display first plane of first timepoint
%     busyOutput = busy_dlg();
    disp('Loading files...');
    [files_out, timestamps] = order_files(folder);
    data.files = files_out;
    data.timestamps = timestamps;
    
    data.edges = [];
    data.top_slice_index = [];
    data.filename = files_out(1).name;
    data.timepoint = 1; 
    data.czi_reader = bfGetReader([folder filesep files_out(1).name]);
    data.im = bfGetPlane(data.czi_reader, ...
        data.czi_reader.getIndex(0, 0, 0) + 1);
    data.ome_meta = data.czi_reader.getMetadataStore();
    data.z_offsets = z_offsets;
    data.channel_names = channel_names;
    data.scale_bar_length_um = scale_bar_length_um;
    controls = setup_ui(data);
    data.controls = controls;
    data.midline_definition_method = midline_definition_method;
    setappdata(controls.hfig, 'data', data);
    
    initialise_sliders(controls, data);
    attach_callbacks(controls)
    imagesc(data.im, 'Parent', controls.hax);
    colormap gray;
    set(gca, 'XTick', []);
    set(gca, 'YTick', []);
    axis equal tight;
    
    
%     busy_dlg(busyOutput);

end



