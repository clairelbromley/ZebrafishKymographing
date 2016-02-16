% find kymoggraph edge based on maximum values

function edgeBasedOnMax(kym_segment, metadata)

    md = metadata;
    
    [mx,imx] = max(kym_segment, [], 1);
    t = (1:length(imx)) * md.acqMetadata.cycleTime;
    d = (size(kym_segment,1) - imx) * md.umperpixel;
    
    figure('Name', 'Alternative method - maxima');
    subplot(1,3,1);
    imagesc(kym_segment);
    colormap gray;
    axis equal tight;
    xlabel('Post-cut frames');
    ylabel('Pixels along kymograph axis');
%     
%     subplot(1,3,2);
%     scatter(t,d);
%     ylim([0 size(kym_segment,1) * md.umperpixel]);
%     xlabel('Time post-cut, s');
%     ylabel('Membrane edge distance from cut, \mum')
%     
%     [fres, goodness] = fit(t', d', 'poly1', 'Weights', (d' - min(d)));
%     hold on
%     plot(t, fres.p1*t + fres.p2, 'r');
%     hold off
%     lbl = text(t(end), fres.p1*t(end)+fres.p2, ...
%         {[sprintf('Speed = %0.2f', fres.p1) ' \mums^{-1}'], ...
%         ['R^{2} = ' sprintf('%0.2f', goodness.rsquare)]}, 'Color', 'r');
% 
    for indf = 1:size(kym_segment,2)
        
        s = squeeze(kym_segment(:,indf));
        [peaks, locs] = findpeaks(s);
        d(indf) = (size(kym_segment,1) - locs(1)) * md.umperpixel;
        
    end
    
    subplot(1,2,2)
    scatter(t,d);
    ylim([0 size(kym_segment,1) * md.umperpixel]);
    xlabel('Time post-cut, s');
    ylabel('Membrane edge distance from cut, \mum')
    
    [fres, goodness] = fit(t', d', 'poly1');
    hold on
    plot(t, fres.p1*t + fres.p2, 'r');
    hold off
    lbl = text(t(end), fres.p1*t(end)+fres.p2, ...
        {[sprintf('Speed = %0.2f', fres.p1) ' \mums^{-1}'], ...
        ['R^{2} = ' sprintf('%0.2f', goodness.rsquare)]}, 'Color', 'r');
    
    
end