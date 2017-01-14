% Script to generate cut movies from z stack data

function generateZStackCutMovies(inputFolder, outputFolder)

% single channel

% get dirs from input folder
dirs = dir([inputFolder filesep '*_E*']);

hfig = figure;
set(hfig, 'Position', [148    65   792   674]);
crossSize = 11;
scale_bar_length = 20;

for dind = 1:length(dirs)
    
    cPath = [inputFolder filesep dirs(dind).name];
    
    md = getMetadata(cPath, 0);
    title_txt = sprintf('%s, Embryo %s, Cut %d', md.acquisitionDate, ...
            md.embryoNumber, md.cutNumber);
    set(hfig, 'Name', title_txt, 'NumberTitle','off');
    
    % Loop through images, superimpose crosses and save to RBG tiffs in
    % output path
    
    imdirs = dir([cPath filesep 'Green*.tif']);
    a = cellfun(@(s)sscanf(s, 'Green_T%d_Z%d.tif'), {imdirs.name}, 'UniformOutput', false);
    a = [a{:}];
    zs = a(2,:)';
    ts = a(1,:)';
    centreZ = max(zs(:))/2 + 1;
     
    for ind = 1:length(imdirs)
        
        im = imread([cPath filesep imdirs(ind).name]);
        A = sscanf(imdirs(ind).name, 'Green_T%d_Z%d.tif');
        t = A(1);
        z = A(2);
        
        if z == centreZ
            crossColor = 'g';
        else
            crossColor = 'b';
        end
        
        if t == md.cutFrame + centreZ
            crossColor = 'r';
        end
            
        
        imagesc(im);
        axis equal tight;
        colormap gray;

        set(gca,'xtick',[], 'xticklabel',[], 'ytick', [],'yticklabel',[]);
        h_cutline = line([md.cutMetadata.startPositionX md.cutMetadata.stopPositionX],...
            [md.cutMetadata.startPositionY md.cutMetadata.stopPositionY],....
            'MarkerEdgeColor', crossColor, 'LineWidth', (crossSize/5),...
            'MarkerSize', crossSize, 'LineStyle', 'none', 'Marker', '+');
        
        scx = [0.95 * size(im,1) - scale_bar_length/md.umperpixel 0.95 * size(im,1)];
        scy = [0.95 * size(im,2) 0.95 * size(im,2)];
        scline = line(scx, scy, 'Color', 'w', 'LineWidth', 6);
        scstr = [num2str(scale_bar_length) ' \mum'];
        
        nudgex = -25;
        nudgey = -16;
        sctxt = text(nudgex + scx(1) + (scx(2) - scx(1))/2, scy(1) + nudgey, scstr);
        set(sctxt, 'Color', 'w');
        set(sctxt, 'FontSize', 14);
        
        out_file = [outputFolder filesep imdirs(ind).name];
        print(out_file, '-dtiff', '-r300');
        
    end
end