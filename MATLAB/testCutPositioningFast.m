function kym_positioning = testCutPositioningFast(stack, md, uO)
% firstFigure takes the first frame of a stack, the metadata pertaining to
% it and the pertinent user options and saves a figure with the cut and the
% kymograph lines overlaid, along with a scalebar. It returns the data
% pertaining to the positioning of the kymographs. 


%% set cross size - force to odd
crossSize = uO.crossSize;
crossSize = 2*floor(crossSize /2) + 1;
if crossSize < 3
    crossSize = 3;
end
L = [0 1 0];
L = imresize(L,[1 crossSize]);
L = L > 0.5;
X = repmat(L,length(L),1);
X = X | X';


%% work out where the cut and kymograph lines should go
kym_positioning = placeKymographs(md, uO);
kp = kym_positioning;

if (uO.kymDownOrUp)
    direction = ' upwards';
else
    direction = '';
end

% if (uO.saveFirstFrameFigure)


title_txt = sprintf('%s, Embryo %s, Cut %d', md.acquisitionDate, ...
    md.embryoNumber, md.cutNumber);
title_txt = [title_txt uO.firstFigureTitleAppend];
dir_txt = sprintf('%s, Embryo %s%s', md.acquisitionDate, md.embryoNumber, direction);    

for frameind = 1:size(stack, 3)

    offset = ceil(crossSize/2);
    for cutend = 1:2
        stack((kp.xcut(cutend) - offset):(kp.xcut(cutend) - offset + size(X,1)-1),...
            (kp.ycut(cutend) - offset):(kp.ycut(cutend) - offset + size(X,2)-1), ...
            frameind) = ...
            stack((kp.xcut(cutend) - offset):(kp.xcut(cutend) - offset + size(X,1)-1), ...
            (kp.ycut(cutend) - offset):(kp.ycut(cutend) - offset + size(X,2)-1), ...
            frameind).*~X;
    end
%         %% Add crosses for kymograph
%         for x = -crossSize/2:crossSize/2
%             for y = -crossSize/2:crossSize/2
%                 stack(kp.ycut(1)+y, kp.xcut(1), frameind) = 0;
%                 stack(kp.ycut(1), kp.xcut(1)+x, frameind) = 0;
%                 stack(kp.ycut(2)+y, kp.xcut(2), frameind) = 0;
%                 stack(kp.ycut(2), kp.xcut(2)+x, frameind) = 0;
%             end
%         end

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

% end
