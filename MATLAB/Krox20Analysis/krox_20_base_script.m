function krox_20_base_script()

    %% Function to process krox20 data for tissue morphology
    curr_dir = fileparts(mfilename('fullpath'));
    addpath(genpath(fileparts(curr_dir)));
    
    %% Parameters
    z_offsets = [35, 40, 45];

    %% Choose base folder
    folder = uigetdir([], ...
        'Choose a folder containing a timecourse of CZI files...');

    if (folder == 0) 
        return;
    end
    
    %% Choose output file
    out_file = uiputfile('.xls', ...
        'Choose a location and filename to save the output to', ...
        [folder filesep 'ncad krox stack output.xls']);
    
    if (out_file == 0)
        return;
    end
    
    %% Loop over timepoints
    files = dir([folder filesep '*.czi']);

    data.filename = files(1).name;
    data.czi_reader = bfGetReader([folder filesep files(1).name]);
    data.current_z_ind = 1;
    data.current_c_ind = 1;
    data.im = bfGetPlane(data.czi_reader, ...
        data.czi_reader.getIndex(data.current_z_ind - 1, data.current_c_ind - 1, 0) + 1);
    data.ome_meta = data.czi_reader.getMetadataStore();
    data.z_offsets = z_offsets;
    controls = setup_ui(data);
    initialise_sliders(controls, data);
    attach_callbacks(controls, data)
    imagesc(data.im, 'Parent', controls.hax);
    colormap gray;
    set(gca, 'XTick', []);
    set(gca, 'YTick', []);
    axis equal tight;
    
%     for ind = 1:length(files)
% 
% 
% 
%     end

end



