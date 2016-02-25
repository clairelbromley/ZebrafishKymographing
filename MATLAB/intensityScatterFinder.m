function toMask = intensityScatterFinder(stack, nominalCutStart)

    mInt = squeeze(mean(mean(stack,2),1));
    
    searchStart = nominalCutStart - 1;
    
    toMask = zeros(size(mInt));
    
    for ind = searchStart:searchStart+9
        
        mmInt = mean(mInt(ind + 4:ind+7));
        sdmInt = std(mInt(ind+4:ind+7));
        
        if mInt(ind) > (mmInt + 3 * sdmInt)
            toMask(ind) = 1;
        end
        
    end
    
    % choose longest contiguous area, just in case...
    bw = bwlabel(toMask);
    rp = regionprops(bw);
    [~, idx] = sort([rp.Area]);
    toMask = bw==idx(end);
    
    numFrames = sum(toMask);
    % should we impose a minimum number (3?) of masked frames?
    % or indeed a maximum number?
     
    
end