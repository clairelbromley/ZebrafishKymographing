root = 'C:\Users\Doug\Desktop\For log-log analysis\For log-log analysis';
dirs = dir([root filesep '*.fig']);

outdir = [root filesep 'log-log test output'];
mkdir(outdir);

for fidx = 1:numel(dirs)

    % load each plot in turn
    open([root filesep dirs(fidx).name]);
    
    % get kymograph data from existing plot
    hf = gcf;
    set(hf, 'Units', 'normalized', 'Position', [0 0 1 1]);
    hfkids = get(hf, 'Children');
    hax = hfkids(2);
    haxkids = get(hax, 'Children');
    him = haxkids(strcmp(get(haxkids, 'Type'), 'image'));
    cdata = get(him, 'CData');
    xl = get(hax, 'XLim');
    yl = get(hax, 'YLim');
    imsz = size(cdata);
    xs = linspace(xl(1), xl(2), imsz(2));
    ys = linspace(yl(1), yl(2), imsz(1));
    ttl = get(get(hax, 'Title'), 'String');
    xlbl = get(get(hax, 'XLabel'), 'String');
    ylbl = get(get(hax, 'YLabel'), 'String');

    % manually draw lines on the previous kymograph
    M = imfreehand(gca, 'Closed', 0);
    correct_membrane = false(size(M.createMask));
    P0 = M.getPosition;
    msk = (P0(:,1) < 0) | (P0(:,1) > xl(2));
    P0(msk, :) = [];

    % generate points
    xunit = (xl(2) - xl(1))/imsz(2);
    yunit = (yl(2) - yl(1))/imsz(1);
    [~,ia,ic] = unique(round(P0(:,1)/xunit));
    P1 = P0(ia, :);
    Y = pchip(P1(:,1), P1(:,2), xs(xs > 0));
    X = xs(xs > 0);

    close(hf);

    % generate figure for comparisons
    hf2 = figure;
    set(hf2, 'Units', 'normalized', 'Position', [0 0 1 1]);

    % original kymograph
    subplot(3, 1, 1);
    imagesc(xs(xs > 0), ys, cdata(:, (xs > 0)));
    colormap gray;
    title(ttl);
    xlabel(xlbl);
    ylabel(ylbl);

    % generate figure showing kymograph on log-log plot
    subplot(3, 1, 2);
    hp = pcolor(xs(xs > 0), ys, cdata(:, (xs > 0)));
    colormap gray;
    set(hp, 'EdgeColor', 'none')
    hax2 = gca;
    set(hax2, 'YScale', 'log', ...
        'YDir', 'Reverse', ...
        'Xscale', 'log');
    set(get(hax2, 'Title'), 'String', [ttl ', log-log kymograph']);
    set(get(hax2, 'XLabel'), 'String', xlbl);
    set(get(hax2, 'YLabel'), 'String', ylbl);

    % generate figure showing edge points on a log-log plot
    subplot(3, 1, 3);
    hpl = plot(X, Y);
    hax_pl = gca;
    set(hax_pl, 'YDir', 'reverse', ...
        'XScale', 'log', ...
        'YScale', 'log');
    xlabel(xlbl);
    ylabel(ylbl);
    title([ttl ', log-log showing edge only']);
   
    savefig(hf2, [outdir filesep dirs(fidx).name ' log-log comparison.fig']);
    print(hf2, [outdir filesep dirs(fidx).name ' log-log comparison.png'],...
        '-dpng', '-r300');
    
end
