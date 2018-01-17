function on_paste_but(hObject, eventdata, handles, controls)
    
    tmp = clipboard('paste');
    
    try
        if ~isempty(tmp)
            if ~isnan(tmp)
                data = get(controls.hTStbl, 'Data');

                if ~isnumeric(tmp)
                    tmp = str2double(regexp(tmp, '\n', 'split'));
                    tmptmp = [];
                    if iscell(tmp)
                        for idx = 1:length(tmp)
                        
                            if ~isempty(tmp{idx})
                                if ~isnan(tmp{idx}) && ~strcmp(tmp{idx}, 'NaN')
                                    tmptmp = [tmptmp tmp(idx)];
                                end
                            end
                        end
                        tmp = tmptmp;
                    else
                        tmp(isnan(tmp)) = [];
                    end
                    
                else
                    tmp(isnan(tmp)) = [];
                end

                copysize = min([size(data, 1), length(tmp)]);
                tmp = num2cell(tmp(1:copysize))';

                data(1:copysize,2) = tmp;

                set(controls.hTStbl, 'Data', data);
            end
        end
    catch e
        beep;
        msgbox([e.message ' in ' e.stack(1).name ' at line ' num2str(e.stack(1).line)]);
    end