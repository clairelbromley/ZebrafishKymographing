function toMask = intensityScatterFinder(stack, nominalCutStart, noFramesToBlock)

    mInt = squeeze(mean(mean(stack,2),1));
    
    searchStart = nominalCutStart - 1;
    
    toMask = zeros(size(mInt));
    
    for ind = searchStart:searchStart+9
        
        mmInt = mean(mInt(ind + 1:ind+3));
        sdmInt = std(mInt(ind+1:ind+3));
        
        if mInt(ind) > (mmInt + 2 * sdmInt)
            toMask(ind) = 1;
        end
        
    end
    
    % choose longest contiguous area, just in case...
    bw = bwlabel(toMask);
    rp = regionprops(bw);
    [~, idx] = sort([rp.Area]);
    toMask = bw==idx(end);
    
    % last frame is:
    lastFrame = find(toMask, 1, 'last');
    toMask = zeros(size(mInt));
    toMask((lastFrame - noFramesToBlock + 1):lastFrame) = 1;
    toMask = logical(toMask);
    
    numFrames = sum(toMask);
    % should we impose a minimum number (3?) of masked frames?
    % or indeed a maximum number?
     
    
end