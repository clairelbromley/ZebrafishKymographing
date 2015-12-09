function output = kymographBase(root)
% kymographBase takes a directory containing data directories as an
% argument and performs all steps for generation of quantitative kymograph
% data. 

    %% User variables for setting up kymographs
    userOptions.timeBeforeCut = 5;                  % Time in seconds before cut for kymograph to start
    userOptions.timeAfterCut = 10;                  % Time in seconds after cut for kymograph to end
    userOptions.number_kym = 10;                    % Number of kymographs calculated per cut
%     userOptions.cut_size_multiplier = 1.5;          % Multiplier to set how far beyond length of cut
                                                    % kymographs should be spaced
    userOptions.kym_width = 9;                      % Width of region kymograph calculated over, pix
    userOptions.kym_length = 50;                    % Length of region kymograph calculated over, pix
    userOptions.scale_bar_length = 20;              % Length of scale bar in images, um
    userOptions.outputFolder = 'C:\Users\Doug\Desktop\test';
    userOptions.saveFirstFrameFigure = true;        % Save first figure?
    userOptions.firstFigureTitleAppend = '' ;       % Text to append to the title of the first figure
    userOptions.saveCutPositioningFigs = true;      % Toggle saving of helper images for checking cut positioning
    userOptions.removeCutFrames = false;            % Toggle removal of frames with scattered light
    userOptions.figHandle = figure;                     % Allow figures to be rendered in a single window
    userOptions.savePreprocessed = true;            % Save stack of images following preprocessing with cut position information

    output.userOptions = userOptions;
    
    %%
    output.metadata = [];
    output.stack = [];

    % Find all directories in the root directory
    dirs = dir([root filesep '*_*']);
    dirs = dirs([dirs.isdir]);
    
    try

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
               disp(['Date: ' curr_metadata.acquisitionDate...
                   ', Embryo: ' curr_metadata.embryoNumber...
                   ', cut: ' num2str(curr_metadata.cutNumber)])

               %% Get frames from  A seconds before cut to B seconds after cut
               A = userOptions.timeBeforeCut;
               B = userOptions.timeAfterCut;
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
                   if ~(cond1 && cond2) || ~(userOptions.removeCutFrames)
                       try
                            stack(:,:,ind) = imread([curr_path filesep sprintf('%06d_mix.tif', frame_ind)]);
                        catch ME
                            errString = ['Error: ' ME.identifier ': ' ME.message];
                            errorLog(userOptions.outputFolder, errString);
                       end
                   end
                   ind = ind+1;
               end

                %output.stack = [output.stack; stack];

                %% Find position of cut, and generate first output figure: 
                %   the first frame of the stack with cut line and kymograph
                %   lines overlaid, along with a scale bar. 

                % FOR NOW (01/12/2015) do this three times with start, end and
                % just after cut images
                isCropped = false;
                userOptions.firstFigureTitleAppend = sprintf(', %d s pre-cut', A);
                kym_region = firstFigure(squeeze(stack(:,:,1)), curr_metadata, userOptions, isCropped);
                if (userOptions.saveCutPositioningFigs)
                    userOptions.firstFigureTitleAppend = ', immediately post-cut';
                    kym_region = firstFigure(squeeze(stack(:,:,find(frames == curr_metadata.cutFrame)+4)), curr_metadata, userOptions, isCropped);
                    userOptions.firstFigureTitleAppend = sprintf(', %d s post-cut', B);
                    kym_region = firstFigure(squeeze(stack(:,:,end)), curr_metadata, userOptions, isCropped);
                    userOptions.firstFigureTitleAppend = sprintf(', multipage');
                    testCutPositioningSlow(stack, curr_metadata, userOptions);
                    userOptions.firstFigureTitleAppend = sprintf(', multipage fast');
                    testCutPositioningFast(stack, curr_metadata, userOptions);
                end
                
               %% Pre-process images in stack
               [stack, kym_region] = kymographPreprocessing(stack, curr_metadata, kym_region, userOptions);
               
           end

        end

        output.kym_region = kym_region;
        load handel;
        player = audioplayer(y, Fs);
        play(player)
        uiwait(msgbox('Hallelujah, I''m finished!x', 'Done!'));
        stop(player)

    catch ME
        beep;
        uiwait(msgbox(['Error on line ' num2str(ME.stack.line) ' of ' ME.stack(1).name ': ' ME.identifier ': ' ME.message], 'Argh!'));
%         rethrow(ME);
    end
    
    close all;
end