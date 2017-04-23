% rotate figure showing mediolateral cut stuffs

hfig = gcf;
hax = gca;
hs = get(hax, 'Children');
imMask = strcmp(get(hs, 'Type'), 'image');
lMask = strcmp(get(hs, 'Type'), 'line');
hls = hs;
hls(~lMask) = [];
cutAxMask = strcmp(get(hls, 'LineStyle'), '--');
cutAxh = hls(cutAxMask);
X = get(cutAxh, 'XData');
Y = get(cutAxh, 'YData');
theta = rad2deg(atan( (Y(1) - Y(2))/(X(1) - X(2)) ));

im = get(hs(imMask), 'CData');
direction = [0 0 1];
rotate(hs(lMask), direction, -theta);
set(hs(imMask), 'CData', ...
    imcrop(imrotate(im, theta, 'bilinear', 'crop'), [2 2 (size(im,2) - 5) (size(im,1) - 5)]));
% set(hs(imMask), 'CData', imrotate(get(hs(imMask), 'CData'), theta-30, 'bilinear', 'crop'));
axis tight;