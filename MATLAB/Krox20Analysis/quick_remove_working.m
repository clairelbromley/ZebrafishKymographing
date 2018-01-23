function quick_remove_working()
% call this function to get rid of the "working" java widget if things get
% out of sync. 

    kids = get(gcf, 'Children');
    delete(kids(strcmp(get(kids, 'Type'), 'hgjavacomponent')));
    
end
    
