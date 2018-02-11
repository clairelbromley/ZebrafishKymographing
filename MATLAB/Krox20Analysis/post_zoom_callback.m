function post_zoom_callback(hObj, eventdata)

    isZoomed = is_zoomed(gca);
    
    if ~isZoomed
        axis equal tight;
    else
        axis normal; 
    end
    
end