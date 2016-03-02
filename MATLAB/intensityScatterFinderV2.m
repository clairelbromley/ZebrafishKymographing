function toMask = intensityScatterFinderV2(stack, nominalCutStart, noFramesToBlock)

    %% simply remove nominal number of frames to block (ceil(cut_duration/frame_duration)), then check following frame
    %% to see if a late starting cut has caused spillover of scatter
    
    toMask = zeros(1, size(stack,3));
    toMask(nominalCutStart:(nominalCutStart + noFramesToBlock - 1)) = 1;
    
    mInt = squeeze(mean(mean(stack(:,:,(nominalCutStart + noFramesToBlock):(nominalCutStart + noFramesToBlock + 3)),2),1));
    if mInt(1) > (mean(mInt(2:end)) + 3 * std(mInt(2:end)))
        toMask(nominalCutStart + noFramesToBlock) = 1;
    end
    
    toMask = logical(toMask);

end