function medianFilteringThesisFigure_subplot(input_image, output_path)
    
    plotSize = 0.485;
    spacer = 0.01;
    % plotsize and spacer need to add to one 1-(3*0.01)/2 gives plot size

    
    im = imread(input_image);
    h = figure;
    subplot('Position',[spacer,(spacer*2)+plotSize,plotSize,plotSize])
    imagesc(im); 
    colormap gray; 
    set(gca,'CLim',[0,16000])
    axis equal tight;
    set(gca,'TickLength',[0,0])
    set(gca,'XTickLabel',[])
    set(gca,'YTickLabel',[])

    medfiltim = medfilt2(im, [50 50]);
    subplot('Position',[(spacer*2)+plotSize,(spacer*2)+plotSize,...
        plotSize,plotSize])
    imagesc(medfiltim); 
    colormap gray; 
    set(gca,'CLim',[0,16000])
    axis equal tight;
    set(gca,'TickLength',[0,0])
    set(gca,'XTickLabel',[])
    set(gca,'YTickLabel',[])
    
    threshim = im;
    threshim(im < medfiltim) = 0;
    subplot('Position',[spacer,spacer,plotSize,plotSize])
    imagesc(threshim); 
    colormap gray; 
    set(gca,'CLim',[0,16000])
    axis equal tight
    set(gca,'TickLength',[0,0])
    set(gca,'XTickLabel',[])
    set(gca,'YTickLabel',[])
    
    binary_im = (threshim > 0);
    se = strel('disk', 1);
    binary_im = imerode(binary_im, se);
    binary_im = imdilate(binary_im, se);
    denoisedim = threshim;
    denoisedim(binary_im == 0) = 0;
    subplot('Position',[(spacer*2)+plotSize,spacer,plotSize,plotSize])
    imagesc(denoisedim); 
    colormap gray; 
    set(gca,'CLim',[0,16000])
    axis equal tight;
    set(gca,'TickLength',[0,0])
    set(gca,'XTickLabel',[])
    set(gca,'YTickLabel',[])
    

    savefig(h, [output_path filesep 'subplot FIG']);