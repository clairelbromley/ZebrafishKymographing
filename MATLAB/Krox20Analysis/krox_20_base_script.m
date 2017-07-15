function krox_20_base_script()

    %% Function to process krox20 data for tissue morphology
    curr_dir = fileparts(mfilename('fullpath'));
    addpath(genpath([curr_dir filesep '..']));
    
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

    in.filename = files(1).name;
    in.z_offsets = z_offsets;
    controls = displayCzi(in);
    attachCallbacks(controls)
%     for ind = 1:length(files)
% 
% 
% 
%     end

end



