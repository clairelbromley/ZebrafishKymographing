function output = kymographBase(root)
% kymographBase takes a directory containing data directories as an
% argument and performs all steps for generation of quantitative kymograph
% data. 

    %% User variables for setting up kymographs
    userOptions.number_kym = 10;                 % Number of kymographs calculated per cut
    userOptions.cut_size_multiplier = 1.5;      % Multiplier to set how far beyond length of cut
                                                % kymographs should be spaced
    userOptions.kym_width = 9;                  % Width of region kymograph calculated over, pix
    userOptions.kym_length = 50;                % Length of region kymograph calculated over, pix
    userOptions.scale_bar_length = 20;          % Length of scale bar in images, um
    userOptions.outputFolder = 'C:\Users\Doug\Desktop\test';
    userOptions.saveFirstFrameFigure = true;    % Save first figure?

    output.userOptions = userOptions;
    
    %%
    output.metadata = [];
    output.stack = [];

    % Find all directories in the root directory
    dirs = dir([root filesep '*_*']);
    dirs = dirs([dirs.isdir]);
    
    % Loop through these (tiff-containing) data directories
    for dind = 1:length(dirs)
        
       d = dirs(dind).name;
       % Identify how many cuts were performed on this embryo
       curr_path = [root filesep d];
       num_cuts = length(dir([curr_path filesep '*.txt']))/2;
       
       for cut_ind = 0:num_cuts-1
          
           %% Get metadata for current cut
           curr_metadata = getMetadata(curr_path, cut_ind);
           output.metadata = [output.metadata; curr_metadata];
           
           %% Get frames from  A seconds before cut to B seconds after cut
           A = 5;
           B = 10;
           frames = floor(curr_metadata.cutFrame ...
               - A/curr_metadata.acqMetadata.cycleTime) : ceil(curr_metadata.cutFrame ...
               + B/curr_metadata.acqMetadata.cycleTime); 
           stack = zeros(512,512,length(frames));
           
           %% Block out frames with scattered light from cut
           block_frames = ceil(curr_metadata.cutMetadata.time/(1000 * curr_metadata.acqMetadata.cycleTime));
           ind = 1;
           for frame_ind = frames(1):frames(end)               
               test = frame_ind - curr_metadata.cutFrame;
               cond1 = test < block_frames+1;
               cond2 = frame_ind - curr_metadata.cutFrame > 0;
               if ~(cond1 && cond2)
                    stack(:,:,ind) = imread([curr_path filesep sprintf('%06d_mix.tif', frame_ind)]);
               end
               ind = ind+1;
           end

            %output.stack = [output.stack; stack];
           
            %% Find position of cut, and generate first output figure: 
            %   the first frame of the stack with cut line and kymograph
            %   lines overlaid, along with a scale bar. 
            kym_region = firstFigure(squeeze(stack(:,:,1)), curr_metadata, userOptions);
            
           %% Pre-process images in stack
           %stack = kymographPreprocessing(stack, curr_metadata);
           
       end
        
    end

end