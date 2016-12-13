function kym_positioning = testCutPositioningSlow(stack, md, uO)
% firstFigure takes the first frame of a stack, the metadata pertaining to
% it and the pertinent user options and saves a figure with the cut and the
% kymograph lines overlaid, along with a scalebar. It returns the data
% pertaining to the positioning of the kymographs.


    %% easy setting: cross colour and size:
    crossSize = uO.crossSize;
    crossColor = 'w'; % set cross colour to white
%     crossColor = 'k'; % set cross colour to black

    %% work out where the cut and kymograph lines should go
    kym_positioning = placeKymographs(md, uO);
    kp = kym_positioning;

    if (uO.kymDownOrUp)
        direction = ' upwards';
    else
        direction = '';
    end

    if (uO.saveFirstFrameFigure)


        title_txt = sprintf('%s, Embryo %s, Cut %d', md.acquisitionDate, ...
            md.embryoNumber, md.cutNumber);
        title_txt = [title_txt uO.firstFigureTitleAppend];
        dir_txt = sprintf('%s, Embryo %s%s', md.acquisitionDate, md.embryoNumber, direction);

        if ~isfield(uO, 'figHandle')
            h = figure('Name', title_txt,'NumberTitle','off');
        else
            h = uO.figHandle;
            set(uO.figHandle, 'Name', title_txt,'NumberTitle','off');
            set(0, 'currentFigure', uO.figHandle)
        end

        for frameind = 1:size(stack, 3)

            imagesc(squeeze(stack(:,:,frameind)));
            axis equal tight;
            colormap gray;

            set(gca,'xtick',[])
            set(gca,'xticklabel',[])
            set(gca, 'ytick', [])
            set(gca,'yticklabel',[])
            title(title_txt);

            %% Add lines/crosses for cut
%             h_cutline = line(kp.xcut, kp.ycut, 'LineStyle', '--', 'Color', 'b', 'LineWidth', 2);
            h_cutline = line(kp.xcut, kp.ycut, 'MarkerEdgeColor', crossColor, 'LineWidth', (crossSize/5), 'MarkerSize', crossSize, 'LineStyle', 'none', 'Marker', '+');

            % Add scale bar
            if uO.basalMembraneKym
                offs = 50;
            else
                offs = 0;
            end
            scx = [0.95 * size(stack,1) - uO.scale_bar_length/md.umperpixel 0.95 * size(stack,1)] - offs;
            scy = [0.95 * size(stack,2) 0.95 * size(stack,2)] - offs;
            scline = line(scx, scy, 'Color', 'w', 'LineWidth', 6);
            scstr = [num2str(uO.scale_bar_length) ' \mum'];

            % these fields will likely need tweaking! - need to work out the extent
            % of the text box in order to do this properly
            nudgex = -25;
            nudgey = -16;
            sctxt = text(nudgex + scx(1) + (scx(2) - scx(1))/2, scy(1) + nudgey, scstr);
            set(sctxt, 'Color', 'w');
            set(sctxt, 'FontSize', 14);

            set(h, 'Units', 'normalized')
            set(h, 'Position', [0 0 1 1]);

            out_file = [uO.outputFolder filesep 'temp'];
            print(out_file, '-dpng', '-r300');

            overlaystackpage = imread([out_file '.png']);
            overlaystackpage = squeeze(overlaystackpage(:,:,1));

            if ~isdir([uO.outputFolder filesep dir_txt])
                mkdir([uO.outputFolder filesep dir_txt])
            end

            if (frameind == 1)
                %             overlaystack = overlaystackpage;
                imwrite(uint8(overlaystackpage), [uO.outputFolder filesep dir_txt filesep title_txt '.tif']);
            else
                %             overlaystack = cat(3,overlaystack,overlaystackpage);
                imwrite(uint8(overlaystackpage), [uO.outputFolder filesep dir_txt filesep title_txt '.tif'], 'writemode', 'append');
            end

        end

        if ~isfield(uO, 'figHandle')
            close(h);
        end

        delete([out_file '.png'])

    end
    
end
