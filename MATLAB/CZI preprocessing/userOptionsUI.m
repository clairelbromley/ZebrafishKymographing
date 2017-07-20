function userOptionsOut = userOptionsUI(userOptionsIn)

    handles.uOFig = figure( 'Units', 'normalized');
    handles.uOFigScroll = uicontrol('Style', 'slider', 'Parent', handles.uOFig, 'Units', 'normalized');
    set(handles.uOFigScroll, 'Position', [0.95, 0, 0.05, 1], 'Value', 1);
    handles.uOMainPanel = uipanel('Position', [0, 0, 1, 1], 'BorderType', 'none');
    
%     if isempty(userOptionsIn)
        userOptionsIn = UserOptions();
%     end
    
    props = properties(userOptionsIn);
    for i = 1:length(props)
        pos = [0.1, (1 - 0.1 * i), 0.5, 0.1];
        handles.uilabels(i) = uicontrol('Style', 'text', 'String', props{i}, 'Position', pos, ...
            'Units', 'normalized', 'Parent', handles.uOMainPanel);
%             'Parent', handles.uOMainPanel);
        if islogical(userOptionsIn.(props{i}))
           handles.uicontrols(i) = uicontrol('Style', 'checkbox', 'Tag', [props{i} 'Check'], ...
               'Position', pos, 'Parent', handles.uOMainPanel);
        end
    end
    
    userOptionsOut = [];

