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
    hps = [];
    
    for ind = 1:size(stack, 3)
        
        for kpos = 1:numel(kp.kym_startx)

                subk = zeros(uO.kym_length, uO.kym_width);  
                patchX = [];
                patchY = [];

                for subkpos = 0:uO.kym_width-1

                    shift = -(uO.kym_width-1)/2 + subkpos;
                    xshift = shift*cos(md.cutTheta);
                    yshift = shift*sin(md.cutTheta);
                    if md.isCropped
                        subk_x = ([kp.cropped_kym_startx(kpos); kp.cropped_kym_endx(kpos)] + xshift);
                        subk_y = ([kp.cropped_kym_starty(kpos); kp.cropped_kym_endy(kpos)] + yshift);   
                    else
                        subk_x = ([kp.kym_startx(kpos); kp.kym_endx(kpos)] + xshift);
                        subk_y = ([kp.kym_starty(kpos); kp.kym_endy(kpos)] + yshift);   
                    end
                    
                    if ind == 1
                        if (subkpos == 0)
                            patchX = [patchX; subk_x - xshift/(2 * shift)];
                            patchY = [patchY; subk_y - yshift/(2 * shift)];
                        elseif (subkpos == (uO.kym_width - 1))
                            patchX = [patchX; flipud(subk_x) + xshift/(2 * shift)];
                            patchY = [patchY; flipud(subk_y) + yshift/(2 * shift)];
                        end
                    end
                    
                    subk_x = round(subk_x);
                    subk_y = round(subk_y);
                    
                    a = improfile(squeeze(stack(:,:,ind)), subk_x, subk_y, uO.kym_length, 'bilinear');
                    l = length(a);
                    subk(1:l, subkpos+1) = a;
                    
                end

                if uO.showKymographOverlapOverlay
                    hp = patch(patchX, patchY, 'green', 'FaceAlpha', 0.5, 'EdgeAlpha', 0);
                    hps = [hps; hp];
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
    
    if uO.showKymographOverlapOverlay
        disp('Saving overlay images...')
        out_file = [uO.outputFolder filesep dir_txt filesep ...
            'Overlay showing kymograph coverage for cut ' num2str(md.cutNumber)...
            direction];
        print(uO.figHandle, out_file, '-dpng', '-r300');
        savefig(uO.figHandle, [out_file '.fig']);
        
        for kpos = 1:numel(kp.kym_startx)
            set(hps, 'FaceAlpha', 0);
            set(hps(kpos), 'FaceAlpha', 0.5);
            
            out_file = [uO.outputFolder filesep dir_txt filesep ...
            'Overlay showing kymograph coverage for cut ' num2str(md.cutNumber)...
            ', Kymograph index along cut = ' num2str(kpos-2) ' ' direction];
        
            print(uO.figHandle, out_file, '-dpng', '-r300');
            savefig(uO.figHandle, [out_file '.fig']);
        end
        
    end
    
    
    
    for kpos = 1:numel(kp.kym_startx)
        
        kymim = squeeze(kymographs(:,:,kpos))';
        
        if sum(kymim(:)) > 0

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
            if isfield(md, 'isBleach')
                if md.isBleach
                    [~, midx] = min(abs(xt));
                    if midx > 1
                        temp_kymim = kymim;
                        temp_kymim(:,midx-1) = 0;
                        kymographs(:,:,kpos) = temp_kymim'; % for saving tiffs
                    end
                end
            end
            yt = md.umperpixel*(1:size(kymographs,2));
            temp_for_scale = squeeze(kymographs(:,:,kpos));
            temp_for_scale(temp_for_scale == 0) = [];
            colormap gray;
            clims = [min(temp_for_scale(:)) max(temp_for_scale(:))];
                        
            if isfield(md, 'isBleach')
                if md.isBleach
                    hax1 = subplot(1,2,1);
                    xtt1 = md.acqMetadata.cycleTime * (a:0);
                    imagesc(xtt1, yt, kymim(:, 1:length(xtt1)), clims);
                    xlabel('Time relative to bleach start, s')
                    ylabel('Position relative to cut, \mum')
                    hax2 = subplot(1,2,2);
                    xtt2 = md.acqMetadata.cycleTime * (1:b);
                    imagesc(xtt2, yt, kymim(:, (length(xtt1)+1):length(xtt2)), clims);
                    xlabel('Time relative to bleach end, s')
                    set(gca, 'YTick', []);
                    % fix x axis lengths...
                    ax1pos = get(hax1, 'Position');
                    ax2pos = get(hax2, 'Position');
                    x_ll = ax1pos(1);
                    x_ul = ax2pos(1) + ax2pos(3);
                    s = 0.5 * (x_ul-x_ll-ax1pos(3)-ax2pos(3));
                    l = x_ul - x_ll;
                    r = -a/b;
                    w2 = (l-s)/(1+r);
                    w1 = r * w2;
                    new_ax1pos = [x_ll ax1pos(2) w1 ax1pos(4)];
                    new_ax2pos = [(x_ul - w2) ax2pos(2) w2 ax2pos(4)];
                    set(hax1, 'Position', new_ax1pos);
                    set(hax2, 'Position', new_ax2pos);
                    
                    out_file = [uO.outputFolder filesep dir_txt filesep file_title_txt direction ' separate axes'];
                    print(h, out_file, '-dpng', '-r300');
                    savefig(h, [out_file '.fig']);
                    
                end
            
            end
 
            kids = get(h, 'Children');
            delete(kids);
            if isfield(md, 'isBleach')
                if md.isBleach
                    [~, midx] = min(abs(xt));
                    if midx > 1
                        kymim = temp_kymim;
                    end
                end
            end
            imagesc(xt, yt, kymim, clims);
            axis tight;
            xlabel('Time relative to cut, s')
            ylabel('Position relative to cut, \mum')
            title([title_txt direction]);
            
            out_file = [uO.outputFolder filesep dir_txt filesep file_title_txt direction];
            print(h, out_file, '-dpng', '-r300');
            savefig(h, [out_file '.fig']);
            if uO.lumenOpening
                imwrite(uint16(kymim), [out_file '_timePerPixel=' num2str(md.acqMetadata.cycleTime) '_umPerPixel=' num2str(md.umperpixel) '.tif']); 
            end
            if ~isfield(uO, 'figHandle')
                close(h);
            end
            
        end
    
    end
    
    t = toc;
    timeStr = sprintf('Plotting kymographs for E%s C%d took %f seconds', md.embryoNumber, md.cutNumber, t);
    errorLog(uO.outputFolder, timeStr);

end