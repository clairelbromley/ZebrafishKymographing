function addMidlineDistances(viewerOutputPath, processedDataRoot, sheetNumber)

    dates = xlsread(viewerOutputPath, sheetNumber, 'A:A');
%     dates = dates(2:end);
    
    embryoNumbers = xlsread(viewerOutputPath, sheetNumber, 'B:B');
%     embryoNumbers = embryoNumbers(2:end);
    
    cutNumbers = xlsread(viewerOutputPath, sheetNumber, 'C:C');
%     cutNumbers = cutNumbers(2:end);
    
    [a,directions,~] = xlsread(viewerOutputPath, sheetNumber, 'AE:AE');
    directions = directions(2:end);
    
%     [~,sheets] = xlsfinfo(viewerOutputPath);
    
    varn = 'metadata.distanceToApicalSurface';

    distances = [{'Distance cut-midline, um'}];
    for ind = 1:length(dates)
        
        fpath = [processedDataRoot filesep num2str(dates(ind)) ', Embryo ' num2str(embryoNumbers(ind))...
            ' ' directions{ind} filesep 'trimmed_cutinfo_cut_' num2str(cutNumbers(ind)) ...
            '.txt'];
        
        distances = [distances; num2cell(getNumericMetadataFromText(fpath, varn))]
        
    end
    
    xlwrite(viewerOutputPath, distances, 'AdditionalData');

end