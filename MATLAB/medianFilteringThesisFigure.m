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
    savefig(h2, [output_path filesep 'med filtered data FIG']);
    print(h2, [output_path filesep 'med filtered data PNG'], '-dpng', '-r300');
    
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
    

