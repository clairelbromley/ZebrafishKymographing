function movieFrames = makeMovieOfProcessedData(imfname, metafname, movfname)
% generate video from processed data frames, overlaying kymograph lines.
% These will be labelled with positions once debug is complete. 
% movieFrames = makeMovieOfProcessedData(imfname, metafname) generates and
% shows frames from the image file imfname and overlays kymographs
% extracted from metadata file metafname. 
% movieFrames = makeMovieOfProcessedData(imfname, metafname, movfname)
% saves the same frames to an avi file with name movfname. 

% DEBUG
% imfname = 'C:\Users\Doug\Desktop\test\280815, Embryo 14 upwards\trimmed_stack_cut_1.tif';
% metafname = 'C:\Users\Doug\Desktop\test\280815, Embryo 14 upwards\trimmed_cutinfo_cut_1.txt';

info = imfinfo(imfname);

im = zeros(info(1).Height, info(1).Width, length(info));

for ind = 1:length(info)
    im(:,:,ind) = imread(imfname, ind);
end

cutx = getNumericMetadataFromText(metafname, 'metadata.kym_region.cropped_xcut');
cuty = getNumericMetadataFromText(metafname, 'metadata.kym_region.cropped_ycut');
kymstartx = getNumericMetadataFromText(metafname, 'metadata.kym_region.cropped_kym_startx');
kymstarty = getNumericMetadataFromText(metafname, 'metadata.kym_region.cropped_kym_starty');
kymendx = getNumericMetadataFromText(metafname, 'metadata.kym_region.cropped_kym_endx');
kymendy = getNumericMetadataFromText(metafname, 'metadata.kym_region.cropped_kym_endy');

figH = figure;
image(squeeze(im(:,:,1)));
colormap gray;
axis equal tight;
ax = gca;
set(ax, 'NextPlot', 'replaceChildren');

F(length(info)) = struct('cdata',[],'colormap',[]);
% Scale gray levels to maximum value across all frames. 
imScale = 64/max(im(:));
for ind = 1:length(info)
    
    im1 = squeeze(im(:,:,ind))*imScale;
    image(im1, 'Parent', ax);
    colormap gray
    axis equal tight;
    axis off;
    ax = gca;

    cutLineH  = line(cutx, cuty, 'Color', 'c', 'LineStyle', '-');
    kymLinesH = line([kymstartx; kymendx], [kymstarty; kymendy], 'Color', 'r', 'LineStyle', '--');
    
    drawnow
    
    F(ind) = getframe(ax);
     
end

close(figH);

if nargin == 3
    % force save as avi for now...
    [pname, fname, ext] = fileparts(movfname);
    if ~strcmp(ext, 'avi')
        ext = 'avi';
    end

    movfname = [pname filesep fname '.' ext];
    v = VideoWriter(movfname);
    set(v, 'FrameRate', 2);
    open(v);
    writeVideo(v,F);
    close(v);
end

movieFrames = F;