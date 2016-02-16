function kymographs = plotAndSaveKymographsSlow(stack, metadata, userOptions)

    md = metadata;
    uO = userOptions;
    kp = md.kym_region;
    
    if (uO.kymDownOrUp)
        direction = ' upwards';
    else
        direction = ' downwards';
    end
    
    dir_txt = sprintf('%s, Embryo %s%s', md.acquisitionDate, md.embryoNumber, direction);

    tic
    disp(['Building kymographs for ' dir_txt ', cut ' num2str(md.cutNumber)]);
    for ind = 1:size(stack, 3)
        for kpos = 1:numel(kp.kym_startx)

                subk = zeros(uO.kym_length, uO.kym_width);            

                for subkpos = 0:uO.kym_width-1

                    shift = -(uO.kym_width-1)/2 + subkpos;
                    xshift = shift*cos(md.cutTheta);
                    yshift = shift*sin(md.cutTheta);
                    if md.isCropped
                        subk_x = round([kp.cropped_kym_startx(kpos); kp.cropped_kym_endx(kpos)] + xshift);
                        subk_y = round([kp.cropped_kym_starty(kpos); kp.cropped_kym_endy(kpos)] + yshift);   
                    else
                        subk_x = round([kp.kym_startx(kpos); kp.kym_endx(kpos)] + xshift);
                        subk_y = round([kp.kym_starty(kpos); kp.kym_endy(kpos)] + yshift);   
                    end
                    a = improfile(squeeze(stack(:,:,ind)), subk_x, subk_y, uO.kym_length);
                    l = length(a);
                    subk(1:l, subkpos+1) = a;

                end

                if uO.avgOrMax == 1
                    avg_kym = mean(subk, 2);
                    kymographs(ind, :, kpos) = avg_kym(1:uO.kym_length);
                else                               
                    max_kym = max(subk, 2);
                    kymographs(ind, :, kpos) = max_kym(1:uO.kym_length);
                end             

        end

    end
    
    %% remove extraneous scattered light
    final_mask = zeros(numel(kp.kym_startx), length(kymographs));
    for kpos = 1:numel(kp.kym_startx)
        kmean = squeeze(mean(kymographs(:,:,kpos),2));
        nzeros = sum(kmean==0);
        cut_start_frame = find(kmean==0, 1, 'first');
        cut_end_frame = cut_start_frame + ceil(md.cutMetadata.time/(1000 * md.acqMetadata.cycleTime));
        kmeanTrim = kmean(kmean~=0);
        % for each time point along kmean, get the average and standard
        % deviation of the following 3 time points and compare to kmean
        for nind = 1:length(kmeanTrim)
            
            bind = nind+1;
            tind = nind+3;
            
            if bind > length(kmeanTrim)
                bind = length(kmeanTrim);
            end
            
            if tind > length(kmeanTrim)
                tind = length(kmeanTrim);
            end
            
            if nind < cut_start_frame 
                int_thresh(nind) = mean(kmeanTrim(bind:tind)) + 1 * std(kmeanTrim(bind:tind));
                intensity_mask(nind) = kmeanTrim(nind) > int_thresh(nind);
            else
                int_thresh(nind) = mean(kmeanTrim(bind:tind)) + 1 * std(kmeanTrim(bind:tind));
                intensity_mask(nind + nzeros) = kmeanTrim(nind) > int_thresh(nind);
            end
                
        end

        % we're only interested in anomalously high values of kmean
        % immediately around the actual cut (+/- 3 frames?)...
        nr_cut = zeros(size(kmean));
        nr_cut(cut_start_frame : cut_end_frame + 1) = 1;
        
        final_mask(kpos, :) = intensity_mask & nr_cut';
        
    end
    
    final_mask = logical(sum(final_mask,1));
    
    for kpos = 1:numel(kp.kym_startx)
        kymographs(final_mask, :, kpos) = 0;
        
        title_txt = sprintf('%s, Embryo %s, Cut %d, Kymograph position along cut: %0.2f um', md.acquisitionDate, ...
        md.embryoNumber, md.cutNumber, kp.pos_along_cut(kpos));
        file_title_txt = sprintf('%s, Embryo %s, Cut %d, Kymograph index along cut = %d', md.acquisitionDate, ...
        md.embryoNumber, md.cutNumber, (kpos-2));
        
        if ~isfield(uO, 'figHandle')
            h = figure('Name', title_txt,'NumberTitle','off');
        else
            h = uO.figHandle;
            set(uO.figHandle, 'Name', title_txt,'NumberTitle','off');
            set(0, 'currentFigure', uO.figHandle)
        end
        
        a = -round(uO.timeBeforeCut/md.acqMetadata.cycleTime);
        b = size(kymographs,1)-round(uO.timeBeforeCut/md.acqMetadata.cycleTime)-1;
        xt = md.acqMetadata.cycleTime*(a:b);
        yt = md.umperpixel*(1:size(kymographs,2));
        temp_for_scale = squeeze(kymographs(:,:,kpos));
        temp_for_scale(temp_for_scale == 0) = [];
        clims = [min(temp_for_scale) max(temp_for_scale)];
        imagesc(xt, yt, squeeze(kymographs(:,:,kpos))', clims);
        axis equal tight;
        xlabel('Time relative to cut, s')
        ylabel('Position relative to cut, \mum')
        title([title_txt direction]);

        out_file = [uO.outputFolder filesep dir_txt filesep file_title_txt direction];
        print(out_file, '-dpng', '-r300');
        savefig(h, [out_file '.fig']);
        
        if ~isfield(uO, 'figHandle')
            close(h);
        end
    
    end
    
    t = toc;
    timeStr = sprintf('Plotting kymographs for E%s C%d took %f seconds', md.embryoNumber, md.cutNumber, t);
    errorLog(uO.outputFolder, timeStr);

end