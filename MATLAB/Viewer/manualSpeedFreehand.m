function [figurePath, manualSpeed] = manualSpeedFreehand(handles, im)

% ADD OK BUTTON - definitely as can then just use the freehand drawing to
% show where the user chosen membrane front is rather than having to
% overlay anything - downside is lack of consistency with display later,
% but never mind. 
handles.manualSpeedFig = figure;
set(handles.manualSpeedFig, 'Position', get(0,'Screensize')); % Maximize figure.

cut_frame = round(handles.timeBeforeCut/handles.frameTime) + 1;
x = find(sum(squeeze(im(:,cut_frame-1:cut_frame+5)),1)==0);
first_frame = max(x) - 1 + cut_frame;
if isempty(x)
    first_frame = 2;
end
segment_len_frames = round(handles.quantAnalysisTime / handles.frameTime);
kym_segment = squeeze(im(:,first_frame:first_frame + segment_len_frames));

% title_txt = get(get(handles.axUpSelectedKym, 'Title'), 'String');
title_txt = sprintf('%s, Embryo %s, Cut %d, Kymograph position along cut %0.2f um, MANUAL LINEAR', handles.date, ...
            handles.embryoNumber, handles.cutNumber, handles.currentKymInd);
file_txt = [handles.date ', Embryo ' handles.embryoNumber ...
            ', Cut ' handles.cutNumber ', Kymograph index along cut = ' num2str(handles.currentKymInd)...
           ' - quantitative kymograph - MANUAL'];
baseFolder2 = [handles.baseFolder filesep handles.date ', Embryo ' handles.embryoNumber];

if strcmp(handles.currentDir, 'up')
    ax = 1;
    appendText = ' upwards';
    kym_ax = handles.axUpSelectedKym;
    direction = 'up';
else
    ax = 2;
    appendText = ' downwards';
    kym_ax = handles.axDownSelectedKym;
    direction = 'down';
end

folder = [baseFolder2 appendText];

imagesc(kym_segment, [min(im(:)) max(im(:))]);
colormap gray;
axis equal tight;

% get freehand selection:
M = imfreehand(gca, 'Closed', 0);
correct_membrane = false(size(M.createMask));
P0 = M.getPosition;
% get rid of points falling outwith axes...
out = (P0(:,1) < 1) | (P0(:,1) > segment_len_frames + 1);
P0(out,:) = [];

% combine these three lines?
[~,ia,ic] = unique(round(P0(:,1)));
P1 = round([P0(ia,1) P0(ia,2)]);
Y = round(spline(P1(:,1), P1(:,2), (min(P1(:,1)):max(P1(:,1)))));
X = min(P1(:,1)):max(P1(:,1));
% P = unique(round(P0), 'rows');
% [~,ia,~] = unique(P, 'rows');
% P1 = P(ia,:);

S = sub2ind(size(im),Y,X);
correct_membrane(S) = true;
close(handles.manualSpeedFig);

% fit speed curves using the indices in P1, scaled appropriately for size
% and time AND add on offset - though this won't affect speed, it will
% affect the output edge which will be overlaid in the viewer and saved for
% subsequent retrieval. 
h = figure('Name', title_txt,'NumberTitle','off');

X = X' * handles.frameTime;
Y = Y' * handles.umPerPixel;

[linf.res, linf.gof] = fit(X, Y, 'poly1');
manualSpeed = linf.res.p1;
manualEdge = [X Y];

subplot(1,3,1);
imagesc(handles.frameTime * (1:size(kym_segment, 2)), handles.umPerPixel * (1:size(kym_segment, 1)), kym_segment);
set(gca, 'XTick', [], 'YTick', []);
axis tight;
colormap gray;

subplot(1,3,2);
imagesc(handles.frameTime * (1:size(kym_segment, 2)), handles.umPerPixel * (1:size(kym_segment, 1)), correct_membrane);
set(gca, 'XTick', [], 'YTick', []);
axis tight;

subplot(1,3,3);
scatter(X,Y);
set(gca, 'YDir', 'reverse');
ylim([0 size(kym_segment,1) * handles.umPerPixel])
hold on
plot(X, linf.res.p1*X + linf.res.p2, 'r');
hold off
xlabel('Time after cut, s');
ylabel('Membrane position relative to cut, \mum');
hold on
plot(X, linf.res.p1*X + linf.res.p2, 'r');
hold off
xlabel('Time after cut, s');
ylabel('Membrane position relative to cut, \mum');
title([sprintf('Membrane speed = %0.2f ', manualSpeed) '\mum s^{-1}']);

out_file = [folder filesep file_txt];
print(h, [out_file '.png'], '-dpng', '-r300');
savefig(h, [out_file '.fig']);   

figurePath = out_file;

close(h);

