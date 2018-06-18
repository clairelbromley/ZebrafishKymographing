function run_linked_callback(hObject)

    if strcmp(get(hObject, 'Enable'), 'on') && ...
                    strcmp(get(hObject, 'Visible'), 'on')
            cb = get(hObject, 'Callback');
            feval(cb{1}, hObject, [], [], cb{3});
    end
    
end