function uO = userOptionsUI()

% generate a user interface automatically from UserOptions class, returning
% an instance of the class with the user-defined values. 

uO = UserOptions();

flds = flipud(fields(uO));

hFig = figure('Units', 'normalized');

hPanel1 = uipanel('Parent', hFig, 'Position', [0 0 0.95 1], ...
    'Units', 'normalized');
hPanel2 = uipanel('Parent', hPanel1, 'Position', [0 0 1 0.1 * length(flds)], ...
    'Units', 'normalized');
hScroll = uicontrol('Style', 'slider', 'Units', 'normalized', ...
    'Parent', hFig, 'Position', [0.95 0 0.05 1], 'Value', 1, ...
    'Callback', {@vertScroll, hPanel2});

for fldind = 1:length(flds)
    
    h = get(hPanel2, 'Position');
    h = h(4);
    ypos = 0.5 * fldind * h/length(flds);
    
    uicontrol('Style', 'text', 'Parent', hPanel2, 'Units', 'normalized', ...
        'String', flds{fldind}, 'Position', [0.2 ypos 0.5 0.05]);
    
end

set(hPanel2, 'Position', [0 1 1 0.1 * length(flds)]);
    

function vertScroll(hObject, eventdata, arg1)

% handles = guidata(hObject);

ypos = get(hObject, 'Value');

set(arg1, 'Position', [0 -ypos 1 3.5]);

disp('pause');

