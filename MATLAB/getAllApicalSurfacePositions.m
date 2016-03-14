function getAllApicalSurfacePositions(dirs, root, userOptions)

    uO = userOptions;
    
    
    
    for dind = 1:length(dirs)

           d = dirs(dind).name;
           % Identify how many cuts were performed on this embryo
           curr_path = [root filesep d];

           if ~uO.usePreviouslySavedApicalSurfacePos
               % check if positions already defined...
               if exist([curr_path filesep 'apical_surface_positioning_cut_1.csv'], 'file') == 2
                   beep;
                   choice = questdlg('Previous midline position data found. Re-assign midline positions?', 'Re-assign midline positions?', 'Yes', 'No', 'Yes');
                   if strcmp(choice, 'Yes')
                       uO.usePreviouslySavedApicalSurfacePos = false;
                   else
                       uO.usePreviouslySavedApicalSurfacePos = true;
                   end
               else
                   uO.usePreviouslySavedApicalSurfacePos = false;
               end
           else
               if exist([curr_path filesep 'apical_surface_positioning_cut_1.csv'], 'file') ~= 2
                   beep;
                   msgbox('I was asked to use previously saved midline position data but couldn''t find any. You''ll have to re-assign midline positions...');
                   uO.usePreviouslySavedApicalSurfacePos = false;
               end
           end
           
           

           if ~uO.usePreviouslySavedApicalSurfacePos
               num_cuts = length(dir([curr_path filesep '*.txt']))/2;

               for cut_ind = 0:num_cuts-1

                   %% Get metadata for current cut
                   curr_metadata = getMetadata(curr_path, cut_ind);
                   disp(['Date: ' curr_metadata.acquisitionDate...
                           ', Embryo: ' curr_metadata.embryoNumber...
                           ', cut: ' num2str(curr_metadata.cutNumber)])


                   frame_ind = floor(curr_metadata.cutFrame - uO.timeBeforeCut/curr_metadata.acqMetadata.cycleTime);

                   im = imread([curr_path filesep sprintf('%06d_mix.tif', frame_ind)]);

                   % temporarily make sure that cut is angled correctly
                   temp = uO.flip90DegForShortCuts;
                   uO.flip90DegForShortCuts = false;
                   curr_metadata.kym_region = placeKymographs(curr_metadata, uO);
                   uO.flip90DegForShortCuts = temp;
                   
                   curr_metadata = findDistanceToMidline(im, curr_metadata, uO);
                   % save positions to a csv metadata file so as not to mess up
                   % simplistic way in which # cuts is originally assessed.
                   data_path = [curr_path filesep sprintf('apical_surface_distance_to_cut_%d.csv', curr_metadata.cutNumber)];
                   fid = fopen(data_path, 'wt');
                   fprintf(fid, '%s \t %f', 'distanceToApicalSurface', curr_metadata.distanceToApicalSurface);
                   fclose(fid);

               end

           end

    end

end

