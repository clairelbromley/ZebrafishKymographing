function toMask = intensityScatterFinderV2(stack, nominalCutStart, noFramesToBlock)

    %% simply remove nominal number of frames to block (ceil(cut_duration/frame_duration)), then check following frame
    %% to see if a late starting cut has caused spillover of scatter
    
    toMask = zeros(1, size(stack,3));
%     toMask(nominalCutStart:(nominalCutStart + noFramesToBlock - 1)) = 1;
    
    %% first, check whether cut starts earlier than expected
    delta = 0;
    mInt = squeeze(mean(mean(stack(:,:,(nominalCutStart - 4):(nominalCutStart-1)),2),1));
    if mInt(end) > (mean(mInt(1:end-1)) + 2 * std(mInt(1:end-1)))
        toMask(nominalCutStart-1) = 1;
        delta = -1;
    end
    
    toMask(nominalCutStart:(nominalCutStart + noFramesToBlock - 1 + delta)) = 1;
    
    %% then check whether cut extends for longer than expected
    mInt = squeeze(mean(mean(stack(:,:,(nominalCutStart + noFramesToBlock + delta):(nominalCutStart + noFramesToBlock + 3 + delta)),2),1));
    if mInt(1) > (mean(mInt(2:end)) + 2 * std(mInt(2:end)))
        toMask(nominalCutStart + noFramesToBlock + delta) = 1;
    end
    
    toMask = logical(toMask);

end