function medianFilteringThesisFigure(input_image, output_path)

    im = imread(input_image);
    h1 = figure; 
    imagesc(im); 
    colormap gray; 
    axis equal tight;
    colorbar;
    savefig(h1, [output_path filesep 'raw data FIG']);
    print(h1, [output_path filesep 'raw data PNG'], '-dpng', '-r300');

    medfiltim = medfilt2(im, [50 50]);
    h2 = figure;
    imagesc(medfiltim); 
    colormap gray; 
    axis equal tight;
    colorbar;
    savefig(h2, [output_path filesep 'med filtered data 50 FIG']);
    print(h2, [output_path filesep 'med filtered data 50 PNG'], '-dpng', '-r300');
    
       medfiltim2 = medfilt2(im, [100 100]);
    h2a = figure;
    imagesc(medfiltim2); 
    colormap gray; 
    axis equal tight;
    colorbar;
    savefig(h2a, [output_path filesep 'med filtered data 100 FIG']);
    print(h2a, [output_path filesep 'med filtered data 100 PNG'], '-dpng', '-r300');
    
          medfiltim3 = medfilt2(im, [5 5]);
    h2b = figure;
    imagesc(medfiltim3); 
    colormap gray; 
    axis equal tight;
    colorbar;
    savefig(h2b, [output_path filesep 'med filtered data 100 FIG']);
    print(h2b, [output_path filesep 'med filtered data 100 PNG'], '-dpng', '-r300');
    
            medfiltim4 = medfilt2(im, [200 200]);
    h2c = figure;
    imagesc(medfiltim4); 
    colormap gray; 
    axis equal tight;
    colorbar;
    savefig(h2c, [output_path filesep 'med filtered data 200 FIG']);
    print(h2c, [output_path filesep 'med filtered data 200 PNG'], '-dpng', '-r300');
    
    threshim = im;
    threshim(im < medfiltim) = 0;
    h3 = figure;
    imagesc(threshim); 
    colormap gray; 
    axis equal tight;
    colorbar;
    savefig(h3, [output_path filesep 'med thresholded data FIG']);
    print(h3, [output_path filesep 'med thresholded data PNG'], '-dpng', '-r300');
    
    binary_im = (threshim > 0);
    se = strel('disk', 1);
    binary_im = imerode(binary_im, se);
    binary_im = imdilate(binary_im, se);
    denoisedim = threshim;
    denoisedim(binary_im == 0) = 0;
    h4 = figure;
    imagesc(denoisedim); 
    colormap gray; 
    axis equal tight;
    colorbar;
    savefig(h4, [output_path filesep 'denoised data FIG']);
    print(h4, [output_path filesep 'denoised data PNG'], '-dpng', '-r300');
    

