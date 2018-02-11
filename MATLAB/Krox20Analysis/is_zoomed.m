function iszoomed = is_zoomed(hax)

    origInfo = getappdata(hax, 'matlab_graphics_resetplotview');
    if isempty(origInfo)
       iszoomed = false;
    elseif isequal(get(hax,'XLim'), origInfo.XLim) && ...
           isequal(get(hax,'YLim'), origInfo.YLim)
       iszoomed = false;
    else
       iszoomed = true;
    end