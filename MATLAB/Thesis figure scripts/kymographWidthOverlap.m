% get processed data cmap
dumfig = open('D:\REDO FIG\out\Apical - width=5\240716, Embryo 6 downwards\Overlay showing kymograph coverage for cut 1 downwards.fig');
dumax = get(dumfig, 'Children');
dumhs = get(dumax, 'Children');
processedIm = get(dumhs(strcmp(get(dumhs, 'Type'), 'image')), 'CData');
close(dumfig);

kw = [9 5 1];
idx = 2;
patchToKeep = 4;
lineWidth = 3;

root = 'D:\REDO FIG\out';

fldr = '240716, Embryo 6 upwards';

for kwidx = 1:length(kw)
    % open figure with all overlap showing
    fname = [root filesep 'Apical - kw = ' num2str(kw(kwidx)) filesep fldr filesep 'Overlay showing kymograph coverage for cut 1 upwards.fig'];
    hfig = open(fname);
    hax = get(hfig, 'Children');

    % try first getting each graphics object and rotating each by 90 deg. 
    hs = get(hax, 'Children');
    imMask = strcmp(get(hs, 'Type'), 'image');
    hcmap = hs(imMask);
    hs(imMask) = [];


    direction = [0 0 1];
    rotate(hs(strcmp(get(hs, 'Type'), 'patch') | strcmp(get(hs, 'Type'), 'line')),...
        direction, 180+37.3667, [300, 210, 0]);
    txtMask = strcmp(get(hs, 'Type'), 'text');
    delete(hs(txtMask));
    hs(txtMask) = [];
    linMask = strcmp(get(hs, 'Type'), 'line');
    patchMask = strcmp(get(hs, 'Type'), 'patch');
    cutAxMask = strcmp(get(hs, 'LineStyle'), '--');
    set(hs(cutAxMask), 'Color', 'c');

    set(hs(linMask), 'LineWidth', lineWidth);

    % get minimum/maximum x/y pos
    if kwidx == 1
        xs = [];
        ys = [];
        for idx = 1:length(hs)

            x = get(hs(idx), 'XData');
            xs = [xs; x(:)];
            y = get(hs(idx), 'YData');
            ys = [ys; y(:)];

        end

        rx = max(xs) - min(xs);
        ry = max(ys) - min(ys);

        xlims = [(min(xs) - rx/10) (max(xs) + rx/10)];
        ylims = [(min(ys) - ry/10) (max(ys) + ry/10)];
    end
    
    im = imrotate(processedIm, -37.3667, 'bilinear', 'crop');
    set(hcmap, 'CData', im);

    xlim(xlims);
    ylim(ylims);
    
    title([num2str(kw(kwidx)) ' pixel - ' sprintf('%0.2f', 0.218 * kw(kwidx)) ' \mum'])

    % Save single kymograph width on data BG
    set(hs(patchMask), 'FaceAlpha', 0);
    set(hs(find(patchMask, 1) + patchToKeep - 1), 'FaceAlpha', 0.5);
    outname = [num2str(kw(kwidx)) ' pixel kymograph width illustration'];
    set(hfig, 'Name', outname);
    savefig(hfig, [root filesep outname])
    print(hfig, [root filesep outname], '-dpng', '-r300')

    % Save all kymographs widths with white BG, grey patches
    set(hs(patchMask), 'FaceAlpha', 0.5);
    if kw(kwidx) == 1
        set(hs(linMask), 'Color', [0.25 0.25 0.25]);
        set(hs(cutAxMask), 'Color', 'c');
    end
    set(hcmap, 'AlphaData', 0);
    set(hs(patchMask), 'FaceColor', [0.25 0.25 0.25]);
    outname = [num2str(kw(kwidx)) ' pixel kymograph width - overlap'];
    set(hfig, 'Name', outname);
    savefig(hfig, [root filesep outname])
    print(hfig, [root filesep outname], '-dpng', '-r300')
end