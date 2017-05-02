function outStatses = apLengthCZIHandler(rootPath)
    
    outpath = 'C:\Users\d.kelly\Desktop\TestImagesOut';
    saveFigures = false;
    

    % ensure that bioformats functions are on search path
    dummy = [mfilename('fullpath') '.m'];
    currdir = fileparts(dummy);
    funcPath = [currdir filesep '..'];
    addpath(genpath(currdir));
    addpath(funcPath);

    [filename, pathname, ~] = uigetfile('*.czi', ...
        'Choose CZI file to work on', ...
        rootPath);
    
    % error checking - is file CZI? 
    [~,strpname,ext] = fileparts(filename);
    if ~strcmp(ext, '.czi')
        msgbox('File isn''t CZI!');
        return;
    end
    
    % get metadata, reader object for individual planes
    reader = bfGetReader([pathname filename]);
    omeMeta = reader.getMetadataStore();
    
    zPlaneDepth = double(omeMeta.getPixelsPhysicalSizeZ(0).value);
    pix2um = double(omeMeta.getPixelsPhysicalSizeX(0).value);
    nZPlanes = double(omeMeta.getPixelsSizeZ(0).getValue());
    nChannels = double(omeMeta.getPixelsSizeC(0).getValue());
    
    smallestAreas = [];
    outStatses = [];
    
    if saveFigures
        hfig = figure;
    else
        hfig = [];
    end
    
    for zidx = 1:nZPlanes
        
       % use krox20 channel
       fprintf('Current z plane = %d\n\n', zidx);
       C = 2;
       iPlane = reader.getIndex(zidx - 1, C - 1, 0) + 1;
       im = bfGetPlane(reader, iPlane);
       [imStats, outStats, lastBinIm] = apLength(im, pix2um, hfig, []);
       
       if saveFigures
            savefig(hfig, [outpath filesep sprintf('Zplane = %d', zidx)]);
            print(hfig, [outpath filesep sprintf('Zplane = %d', zidx)], '-dpng', '-r300');
       end
       
       
       % check whether sizes of "rhombomeres" are appropriate, and thus
       % whether z plane is suitable. Assume correct id of rhombomeres in
       % first (deepest) z plane
       smallestArea = imStats(2).Area;
       smallestAreas = [smallestAreas; smallestArea];
       if length(smallestAreas) > 5
           threshArea = 0.75 * mean(smallestAreas(1:5));
           if smallestArea < threshArea
               break;
           end
       end      
       outStatses = [outStatses; outStats];
    end
    
    % remove last 20 um (i.e. shallowest 20 um) from outstats
    idxToZeroDepth = length(outStatses);
    twentyMicronsIndex = round(20/zPlaneDepth);
    outStatses = outStatses(1: end - twentyMicronsIndex);
    
    close(hfig);
    
    % output data to excel
    zs = 1:length(outStatses);
    res = [zs' [(idxToZeroDepth - zs)*zPlaneDepth]' [outStatses.minD]' ...
        [outStatses.maxD]' [outStatses.meanD]' [outStatses.medianD]' ...
        [outStatses.q25D]' [outStatses.q75D]' ...
        [outStases.stainedR1Length]' [outStases.stainedR1Width]' ...
        [outStases.stainedR2Length]' [outStases.stainedR2Width]'];
    try
        xlsres = num2cell(res);
        hdr = {'Z index', 'Z depth, um', 'Minimum AP length, um', ...
            'Maximum AP length, um', 'Mean AP length, um', ...
            'Median AP length, um', ...
            '25th percentile AP length, um', '75th percentile AP length, um', ...
            'Mean AP length, stained rhombomere 1, um', ...
            'Mean AP width, stained rhombomere 1, um', ...
            'Mean AP length, stained rhombomere 2, um', ...
            'Mean AP width, stained rhombomere 2, um'};
        xlswrite([outpath filesep strpname ' results.xls'], [hdr; xlsres]);
    catch
        csvwrite([outpath filesep strpname ' results.csv'], res);
    end