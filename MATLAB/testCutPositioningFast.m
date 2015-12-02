function kym_positioning = testCutPositioningFast(stack, md, uO)
% firstFigure takes the first frame of a stack, the metadata pertaining to
% it and the pertinent user options and saves a figure with the cut and the
% kymograph lines overlaid, along with a scalebar. It returns the data
% pertaining to the positioning of the kymographs. 


%% work out where the cut and kymograph lines should go
kym_positioning = placeKymographs(md, uO);
kp = kym_positioning;

if (uO.saveFirstFrameFigure)
    
    
    title_txt = sprintf('%d, Embryo %d, Cut %d', md.acquisitionDate, ...
        md.embryoNumber, md.cutNumber);
    title_txt = [title_txt uO.firstFigureTitleAppend];
    dir_txt = sprintf('%d, Embryo %d', md.acquisitionDate, md.embryoNumber);    
            
    for frameind = 1:size(stack, 3)

        %% Add crosses for kymograph
        for x = -5:5
            for y = -5:5
                stack(kp.ycut(1)+y, kp.xcut(1), frameind) = 0;
                stack(kp.ycut(1), kp.xcut(1)+x, frameind) = 0;
                stack(kp.ycut(2)+y, kp.xcut(2), frameind) = 0;
                stack(kp.ycut(2), kp.xcut(2)+x, frameind) = 0;
            end
        end
        
%         imagesc(squeeze(stack(:,:,frameind)));
%         axis equal tight;
%         colormap gray;
% 
%         set(gca,'xtick',[])
%         set(gca,'xticklabel',[])
%         set(gca, 'ytick', [])
%         set(gca,'yticklabel',[])
%         title(title_txt);
% 
%         set(h, 'Units', 'normalized')
%         set(h, 'Position', [0 0 1 1]);

        if ~isdir([uO.outputFolder filesep dir_txt])
            mkdir([uO.outputFolder filesep dir_txt])
        end
        out_file = [uO.outputFolder filesep dir_txt filesep title_txt '.tif'];
        
        if (frameind == 1)
            imwrite(uint16(squeeze(stack(:,:,frameind))), out_file);
        else
            % IF THIS STEP FAILS, CLOSE THE EXPLORER/FINDER WINDOW THAT IS
            % OPEN TO THE CONTAINING FOLDER!!!
            imwrite(uint16(squeeze(stack(:,:,frameind))), out_file, 'writemode', 'append');
        end
    
    end
    
end
