% get kymograph data from existing plot
hf = gcf;
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
ylbl = get(get(hax, 'YLabel'), 'String');;

% generate figure showing kymograph on log-log plot
hf2 = figure;
hp = pcolor(xs, ys, cdata);
colormap gray;
set(hp, 'EdgeColor', 'none')
hax2 = gca;
set(hax2, 'YScale', 'log', ...
    'YDir', 'Reverse', ...
    'Xscale', 'log');
set(get(hax2, 'Title'), 'String', {[ttl ', '] 'log-log kymograph'});
set(get(hax2, 'XLabel'), 'String', xlbl)
    'YLabel', ylbl);