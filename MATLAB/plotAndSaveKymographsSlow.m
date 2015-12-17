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
                    a = improfile(squeeze(stack(:,:,ind)), subk_x, subk_y);
                    l = length(a);
                    subk(1:l, subkpos+1) = a;

                end

                if uO.avgOrMax == 1
                    avg_kym = mean(subk, 2);
                    kymographs(ind, :, kpos) = avg_kym(1:uO.kym_length-5);
                else                               
                    max_kym = max(subk, 2);
                    kymographs(ind, :, kpos) = max_kym(1:uO.kym_length-5);
                end

        end

    end
    t = toc;
    timeStr = sprintf('Plotting kymographs for E%s C%d took %f seconds', md.embryoNumber, md.cutNumber, t);
    errorLog(uO.outputFolder, timeStr);

    for kpos = 1:numel(kp.kym_startx)

        title_txt = sprintf('%s, Embryo %s, Cut %d, Kymograph position along cut: %0.2f um', md.acquisitionDate, ...
        md.embryoNumber, md.cutNumber, (kpos-2)*(kp.kym_startx(2) - kp.kym_startx(1))*md.umperpixel);
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
        imagesc(xt, yt, squeeze(kymographs(:,:,kpos))');
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

end