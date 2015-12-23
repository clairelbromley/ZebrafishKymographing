function kym_positioning = firstFigure(frame, md, uO)
% firstFigure takes the first frame of a stack, the metadata pertaining to
% it and the pertinent user options and saves a figure with the cut and the
% kymograph lines overlaid, along with a scalebar. It returns the data
% pertaining to the positioning of the kymographs. 


%% work out where the cut and kymograph lines should go
kym_positioning = placeKymographs(md, uO);
kp = kym_positioning;

if (uO.kymDownOrUp)
    direction = ' upwards';
else
    direction = ' downwards';
end

if (uO.saveFirstFrameFigure)
    
    %% Plot figure with first frame
    title_txt = sprintf('%s, Embryo %s, Cut %d', md.acquisitionDate, ...
        md.embryoNumber, md.cutNumber);
    dir_txt = sprintf('%s, Embryo %s%s', md.acquisitionDate, md.embryoNumber, direction);
    title_txt = [title_txt uO.firstFigureTitleAppend direction];
    if md.isCropped
        title_txt = [title_txt ' cropped'];
    end
        
    if ~isfield(uO, 'figHandle')
        h = figure('Name', title_txt,'NumberTitle','off');
    else
        h = uO.figHandle;
        set(uO.figHandle, 'Name', title_txt,'NumberTitle','off');
        set(0, 'currentFigure', uO.figHandle)
    end
    
    subplot(1,1,1); % To deal with potential for last loop of figures having subplots and messing things up
    imagesc(frame);
    axis equal tight;
    colormap gray;
    
    set(gca,'xtick',[])
    set(gca,'xticklabel',[])
    set(gca, 'ytick', [])
    set(gca,'yticklabel',[])
    title(title_txt);
    
    %% Add lines for cut and kymograph
    if md.isCropped
        h_cutline = line(kp.cropped_xcut, kp.cropped_ycut, 'LineStyle', '--', 'Color', 'b', 'LineWidth', 2);
        h_kymline = line([kp.cropped_kym_startx; kp.cropped_kym_endx], [kp.cropped_kym_starty; kp.cropped_kym_endy], 'Color', 'r');
        pos_txt = zeros(length(kp.cropped_kym_startx),1);
        for ind = 1:length(kp.cropped_kym_startx)
            pos_txt(ind) = text(kp.cropped_kym_startx(ind), kp.cropped_kym_starty(ind), sprintf('%0.2f', kp.pos_along_cut(ind)));
            set(pos_txt(ind), 'Color', 'r');
            set(pos_txt(ind), 'FontSize', 12);
        end
    else
        h_cutline = line(kp.xcut, kp.ycut, 'LineStyle', '--', 'Color', 'b', 'LineWidth', 2);
        h_kymline = line([kp.kym_startx; kp.kym_endx], [kp.kym_starty; kp.kym_endy], 'Color', 'r');
        
        %% Handle placement of the scale bar
        scx = [0.95 * size(frame,1) - uO.scale_bar_length/md.umperpixel 0.95 * size(frame,1)];
        scy = [0.95 * size(frame,2) 0.95 * size(frame,2)];
        scline = line(scx, scy, 'Color', 'w', 'LineWidth', 6);
        scstr = [num2str(uO.scale_bar_length) ' \mum'];

        % these fields will likely need tweaking! - need to work out the extent
        % of the text box in order to do this properly
        nudgex = -25;
        nudgey = 470;
        sctxt = text(nudgex + scx(1) + (scx(2) - scx(1))/2, nudgey, scstr);
        set(sctxt, 'Color', 'w');
        set(sctxt, 'FontSize', 14);
    end
      
    set(h, 'Units', 'normalized')
    set(h, 'Position', [0 0 1 1]);
    
    title(title_txt);
    
    if ~isdir([uO.outputFolder filesep dir_txt])
        mkdir([uO.outputFolder filesep dir_txt])
    end
    out_file = [uO.outputFolder filesep dir_txt filesep title_txt];
    print(out_file, '-dpng', '-r300');
    savefig(h, [out_file '.fig']);

    if ~isfield(uO, 'figHandle')
        close(h);
    end
    
end
