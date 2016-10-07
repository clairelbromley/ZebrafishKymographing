function [manualEdge, manualSpeed] = manualSpeedFreehand(handles, im)

% ADD OK BUTTON - definitely as can then just use the freehand drawing to
% show where the user chosen membrane front is rather than having to
% overlay anything - downside is lack of consistency with display later,
% but never mind. 
handles.manualSpeedFig = figure;
set(handles.manualSpeedFig, 'Position', get(0,'Screensize')); % Maximize figure.
imagesc(im);
colormap gray;

% get freehand selection:
M = imfreehand(gca, 'Closed', 0);
F = false(size(M.createMask));
P0 = M.getPosition;

% combine these three lines?
P = unique(round(P0), 'rows');
[~,ia,~] = unique(P, 'rows');
P1 = P(ia,:);

S = sub2ind(size(im),P1(:,2),P1(:,1));
F(S) = true;


% fit speed curves using the indices in P1, scaled appropriately for size
% and time AND add on offset - though this won't affect speed, it will
% affect the output edge which will be overlaid in the viewer and saved for
% subsequent retrieval. 
X = P(:,1) * handles.frameTime;
Y = P(:,2) * handles.umPerPixel;

manualSpeed = 1;
manualEdge = [X Y];

