function [files_out, timestamps] = manual_timestamping(files_out, timestamps)

    % generate ui
    controls.hfig = figure('Name', 'Manually assign timestamps', ...
        'Units', 'normalized', ...
        'Position', [0.25, 0.25, 0.25, 0.5], ...
        'Toolbar', 'none', ...
        'Menubar', 'none');
%     , ...
%         'WindowStyle', 'modal');
    
    controls.hOKbut = uicontrol('Style', 'pushbutton', 'Parent', controls.hfig, ...
        'Units', 'normalized', ...
        'Position', [0.25, 0.05, 0.5, 0.1], ...
        'String', 'OK', ...
        'Callback', {@on_manual_ts_OK, [], controls});
    
    % order files as a for loop for now...
    tmp = struct2cell(files_out);
    nms = tmp(1,:)';
    tps = [];
    ex = 'Exp(?<Experiment>\d+)E(?<embryoNumber>\d+)_T(?<timepoint>\d+).czi';
    for idx = 1:length(nms)
        nm = nms{idx};
        tmp = regexp(nm, ex, 'names'); 
        tps = [tps; str2double(tmp.timepoint)];
    end
    
    [~, sidx] = sort(tps);
    nms = nms(sidx);
    timestamps = timestamps(sidx);
        
    data = [nms num2cell(timestamps)];
    
    controls.hTStbl = uitable('Parent', controls.hfig, ...
        'Units', 'normalized', ...
        'Position', [0.125, 0.2, 0.75, 0.75], ...
        'ColumnName', {'File name', 'Time in seconds'}, ...
        'ColumnEditable', [false, true], ...
        'ColumnFormat', {'char', 'numeric'}, ...
        'CellEditCallback', {@on_cell_edit, [], files_out, timestamps);
    
    % configure column widths
    set(controls.hTStbl, 'Units', 'pixels');
    pos = get(controls.hTStbl, 'Position');
    set(controls.hTStbl, 'Units', 'normalized');
    set(controls.hTStbl, 'ColumnWidth', {round((pos(3) - 30)/2) round((pos(3) - 30)/2)});
    
end
    
function on_manual_ts_OK(hObject, eventdata, handles, controls, files_out, timestamps)
    close(controls.hfig);
    
end
    
function on_cell_edit(src, eventData, files_out, timestamps)

    
    
    