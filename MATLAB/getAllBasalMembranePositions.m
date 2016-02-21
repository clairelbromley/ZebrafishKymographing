function uO = getAllBasalMembranePositions(dirs, root, userOptions)

    uO = userOptions;

   if uO.basalMembraneKym

       temp = uO.kymDownOrUp;     

        % Loop through these (tiff-containing) data directories
        for dind = 1:length(dirs)

           d = dirs(dind).name;
           % Identify how many cuts were performed on this embryo
           curr_path = [root filesep d];

           if ~uO.usePreviouslySavedBasalPos
               % check if positions already defined...
               if exist([curr_path filesep 'basal_kymograph_positioning_cut_1.csv'], 'file') == 2
                   beep;
                   choice = questdlg('Previous basal position data found. Re-assign basal positions?', 'Re-assign basal positions?', 'Yes', 'No', 'Yes');
                   if strcmp(choice, 'Yes')
                       uO.usePreviouslySavedBasalPos = false;
                   else
                       uO.usePreviouslySavedBasalPos = true;
                   end
               else
                   uO.usePreviouslySavedBasalPos = false;
               end
           end

           if ~uO.usePreviouslySavedBasalPos
               num_cuts = length(dir([curr_path filesep '*.txt']))/2;

               for cut_ind = 0:num_cuts-1

                   %% Get metadata for current cut
                   curr_metadata = getMetadata(curr_path, cut_ind);
                   disp(['Date: ' curr_metadata.acquisitionDate...
                           ', Embryo: ' curr_metadata.embryoNumber...
                           ', cut: ' num2str(curr_metadata.cutNumber)])


                   frame_ind = floor(curr_metadata.cutFrame - uO.timeBeforeCut/curr_metadata.acqMetadata.cycleTime);

                   im = imread([curr_path filesep sprintf('%06d_mix.tif', frame_ind)]);
                   basalKymPositioning = []

                   for basalSurfNumber = 1:2
                       uO.kymDownOrUp = (basalSurfNumber == 2);
                       curr_metadata.kym_region = placeKymographs(curr_metadata, uO);
                       curr_metadata = manualBasalMembraneKymographPositioning(im, uO, curr_metadata);
                       basalKymPositioning = [basalKymPositioning; curr_metadata.kym_region];
                       % save positions to a csv metadata file so as not to mess up
                       % simplistic way in which # cuts is originally assessed.
                       saveMetadata(curr_path, curr_metadata, uO, curr_metadata.kym_region, basalSurfNumber);
                   end


               end

            end

            uO.kymDownOrUp = temp;

        end

   end
   
end
