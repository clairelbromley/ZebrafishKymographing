function testScatterRemoval(root)
    %% User variables for setting up kymographs
    userOptions.forcedSpeedRange = [-1.5 1.5];          % speed [min max]
    userOptions.forcedPositionRange = [-5 20];      % position um [min max]
    
    userOptions.fixedNumberOrFixedSpacing = true;   % false = fixed number of kym; true = fixed spacing between kym in um.                      Default = true;
    userOptions.kymSpacingUm = 1;                   % Kymograph spacing in um.                                                                  Default = 1;
    userOptions.number_kym = 10;                    % Number of kymographs calculated per cut.                                                  Default = 10
    userOptions.kymDownOrUp = false;                % false = investigate movement below cut; true = investigate movement above cut.            Default = false;
    
    userOptions.timeBeforeCut = 5;                  % Time in seconds before cut for kymograph to start.                                        Default = 5
    userOptions.timeAfterCut = 10;                  % Time in seconds after cut for kymograph to end.                                           Default = 10
    
    userOptions.kym_width = 5;                      % Width of region kymograph calculated over, pix. Must be odd.                              Default = 9
    userOptions.kym_length = 50;                    % Length of region kymograph calculated over, pix.                                          Default = 50
    
    userOptions.loadPreprocessedImages = false;
    userOptions.scale_bar_length = 20;              % Length of scale bar in images, um.                                                        Default = 20
    userOptions.outputFolder = 'C:\Users\Doug\Desktop\test5\frames left in';
    userOptions.saveFirstFrameFigure = true;        % Save first figure?                                                                        Default = true
    userOptions.firstFigureTitleAppend = '' ;       % Text to append to the title of the first figure.                                          Default = ''
    userOptions.saveCutPositioningFigs = false;     % Toggle saving of helper images for checking cut positioning.                              Default = false
    userOptions.removeCutFrames = true;             % Toggle removal of frames with scattered light.                                            Default = true
    userOptions.savePreprocessed = true;            % Save stack of images following preprocessing with cut position information.               Default = true
    userOptions.avgOrMax = 1;                       % Choose between averaging (1) or taking max over (2) the kym_width per kym.                Default = 1
    userOptions.medianFiltKernelSize = 50;           % Size of median filter kernel in pixels - reduce for increased speed...                   Default = 50
    userOptions.preProcess = true;                  % Toggle pre-processing on or off                                                           Default = true
    userOptions.showKymographOverlapOverlay = true;
    
    userOptions.basalMembraneKym = false;
    userOptions.usePreviouslySavedBasalPos = false;  

    %% Find all directories in the root directory
    dirs = dir([root filesep '*_*']);
    dirs = dirs([dirs.isdir]);
    ds = {};
    cind = 0;
    flind = 0;
    
    %% make output directory
    outdir = [root filesep regexprep(datestr(now),':','-') ' scatter test output'];
    mkdir(outdir)
        

        for dind = 1:length(dirs)
            
           d = dirs(dind).name;
           ds = [ds; d];
           % Identify how many cuts were performed on this embryo
           curr_path = [root filesep d];
           num_cuts = length(dir([curr_path filesep '*.txt']))/2;
           
           hfig = figure('Name', d);

           for cut_ind = 0:num_cuts-1
               cind = cind+1;
               
               %% Get metadata for current cut
               curr_metadata = getMetadata(curr_path, cut_ind);
               txt = ['Date: ' curr_metadata.acquisitionDate...
                   ', Embryo: ' curr_metadata.embryoNumber...
                   ', cut: ' num2str(curr_metadata.cutNumber)]; 
               disp(txt)

               %% Get frames from  A seconds before cut to B seconds after cut
               A = userOptions.timeBeforeCut;
               B = userOptions.timeAfterCut;
               frames = floor(curr_metadata.cutFrame ...
                   - A/curr_metadata.acqMetadata.cycleTime) + 2 : ceil(curr_metadata.cutFrame ...
                   + B/curr_metadata.acqMetadata.cycleTime) + 2; 
               
               stack = zeros(512,512,length(frames));
              
               ind = 1;
               
               for frame_ind = frames(1):frames(end)  

                   try
                        stack(:,:,ind) = imread([curr_path filesep sprintf('%06d_mix.tif', frame_ind)]); 
                    catch ME
                        errString = ['Error: ' ME.identifier ': ' ME.message];
                        errorLog(userOptions.outputFolder, errString);
                   end

                   ind = ind+1;
               end
               
               %% Figure out best place to block from, show pre-blocked images
               clims = [mean(stack(:)) - std(stack(:)) mean(stack(:)) + 3*std(stack(:))];
               nomStart = curr_metadata.cutFrame + 2 - frames(1);
               
               for imind = 1:10
                   if imind == 6
                        t = title([txt ' pre-blocking']);
                        set(t, 'horizontalAlignment', 'center')
                        set(t, 'units', 'normalized')
                        h1 = get(t, 'position');
                        set(t, 'position', [1 h1(2) h1(3)])
                    end

                   subplot(2 * num_cuts, 10, (10 * 2 * cut_ind) + imind);
                   sz = size(stack,1)/4;
                   im = squeeze(stack(sz:3*sz,sz:3*sz,nomStart-2+imind));
                   imagesc(im, clims);
                   colormap gray; 
                   axis equal tight;
                   set(gca, 'XTick', []);
                   set(gca, 'YTick', []);
               end
               drawnow;
               
               %% Do blocking, show post-blocked images
               block_frames = ceil(curr_metadata.cutMetadata.time/(1000 * curr_metadata.acqMetadata.cycleTime))
               msk = intensityScatterFinderV2(stack, curr_metadata.cutFrame + 2 - frames(1), block_frames);
               if sum(msk) < block_frames
                   msk(find(msk, 1, 'last') + 1) = 1;
               end
               
               stack(:,:,msk) = 0;
               
               for imind = 1:10
                    if imind == 6
                        t = title([txt ' post-blocking']);
                        set(t, 'horizontalAlignment', 'center')
                        set(t, 'units', 'normalized')
                        h1 = get(t, 'position');
                        set(t, 'position', [1 h1(2) h1(3)])
                    end
                   subplot(2 * num_cuts, 10, (10 * 2 * cut_ind + 10) + imind);
                   sz = size(stack,1)/4;
                   im = squeeze(stack(sz:3*sz,sz:3*sz,nomStart-2+imind));
                   imagesc(im, clims); 
                   colormap gray; 
                   axis equal tight;
                   set(gca, 'XTick', []);
                   set(gca, 'YTick', []);
               end
               drawnow;
               
           end
           
           savefig(hfig, [outdir filesep d]);
           close(hfig);
        end
        
end