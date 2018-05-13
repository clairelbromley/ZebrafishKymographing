function krox_20_base_script()

    %% Function to process krox20 data for tissue morphology
    curr_dir = fileparts(mfilename('fullpath'));
    addpath(genpath(fileparts(curr_dir)));
    
    %% Parameters
    z_offsets = [35, 40, 45];
    midline_thickness_um = 4.75; % CHECK ORIGINAL VALUE IN THESIS?
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
    
    %% FOR NOW, FORCE MANUAL TIMESTAMPS!
    timestamps(1) = 0;
    timestamps(2) = 0;
    
    % check for incorrectly imported timestamps, typically seen when CZI
    % has been processed externally to perform 3d reorientations...
    if any(diff(timestamps) == 0)
        beep;
        answer = questdlg('Time stamps aren''t behaving as expected - is processed data being used?', ...
            'Problem timestamps...', ...
            'Get times from unprocessed data', ...
            'Enter times manually', ...
            'Get times from unprocessed data');
        % separate answer cases to allow for switching back to manual...
        if strcmp(answer, 'Get times from unprocessed data')
%             waitfor(msgbox('Time stamps aren''t behaving as expected - is processed data being used?'));
            raw_folder = uigetdir(folder, 'Please locate unprocessed data...');
            if ~(raw_folder == 0)
                [files_out, timestamps] = order_files(raw_folder);
                % in this case, default to setting rhombomere limits horizontal
                % rather than inferring from masks:
            else
                answer = 'Enter times manually';
            end
        end
        if strcmp(answer, 'Enter times manually')
            global man_ts_data; % ugh...
            controls = setup_ui_manual_timestamping(files_out, timestamps);
            waitfor(controls.hfig);
            timestamps = cell2mat(man_ts_data.timestamps);
            for idx = 1:length(files_out) % more ugh...
                files_out(idx).name = man_ts_data.files_out{idx};
            end
        end
        data.AP_axis_method = 'RotatedImage';
    else
        data.AP_axis_method = 'Rhombomeres';
    end
    
    data.files = files_out;
    data.timestamps = timestamps - min(timestamps);
    
    init_hpf_string = inputdlg('Please input the hpf at the start of imaging:', ...
        'Starting hpf', ...
        1, ...
        {'16'});
    init_hpf = str2double(init_hpf_string);
    if isnan(init_hpf) || isempty(init_hpf)
        error('krox_20_base_script:InvalidInput', ...
            'Please make sure that initial hpf value is numeric. Quitting...');
    end
    data.hpf = data.timestamps/60 + init_hpf;
    
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
    
    % set UI to show default values
    if strcmp(data.AP_axis_method, 'RotatedImage')
        set(controls.hAPaxradios(2), 'Value', true);
    else
        set(controls.hAPaxradios(1), 'Value', true);
    end
    
    data.controls = controls;
    data.midline_definition_method = midline_definition_method;
    data.midline_thickness_um = midline_thickness_um;
    
    setappdata(controls.hfig, 'data', data);
    
    initialise_sliders(controls, data);
    
    % check that data supports rhombomere-linked options
    cPlanes = double(data.ome_meta.getPixelsSizeC(0).getValue());
    if cPlanes < 2
       set(controls.hRDefRadios(1), 'Value', true);
       data.rh_definition_method = 'MorphologicalMarkers';
       set(controls.hRDefRadios(2), 'Enable', 'off');
       evd.NewValue = controls.hRDefRadios(1);
    else
        set(controls.hRDefRadios(2), 'Value', true);
        evd.NewValue = controls.hRDefRadios(2);
    end
    on_rhombomere_definition_method_selection_changed('dum', evd, 'dum', controls);
    data.curr_c_plane = 1;
    data.curr_z_plane = 1;
    
    attach_callbacks(controls);
    imagesc(data.im, 'Parent', controls.hax);
    colormap gray;
    set(gca, 'XTick', []);
    set(gca, 'YTick', []);
    axis equal tight;
    
    
%     busy_dlg(busyOutput);

end



