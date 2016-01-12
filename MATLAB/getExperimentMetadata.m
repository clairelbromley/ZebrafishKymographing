function experimentMetadata = getExperimentMetadata(filepath)

    headerLines = 12;
    [~, sheets] = xlsfinfo(filepath);
    xma = [];

    for shind = 1:length(sheets)

        dt = sheets{shind};
               
        [~, ~, raw] = xlsread(filepath, dt);
        flds = raw(headerLines,2:end);
        raw = raw(headerLines+1:end,:);
        lbl = raw(:,1);
        
        rowsToKeep = cellfun(@ischar,lbl);
        raw = raw(rowsToKeep,:);
        lbl = lbl(rowsToKeep);
        
        for cutind = 1:length(lbl)
            xm.date = dt;
            A=regexp(lbl{cutind}, '[C-E\s]', 'split');
            xm.embryoNumber = A{2};
            xm.cutNumber = str2double(A{3});
            
%             %DEBUG
%             disp(xm.date);
%             disp(xm.embryoNumber);
%             disp(xm.cutNumber);
            
            for fInd = 1:length(flds)
               
               disp(shind/length(sheets)*100);
                
               a = parseFieldNames(flds{fInd});
               if strcmp(a, 'depthActual')
                   disp('break')
               end
               if ~strcmp(a, 'coordinatesxStartYstartxstopYstop')
                    xm.(a) = raw{cutind,fInd+1};
               end
            end
                
            xma = [xma; xm];
            clear xm;
        end
    end
    
    experimentMetadata = xma;

end


function outStr = parseFieldNames(inStr)

    ignoreChars = ''',.:;!%/()';

    fs = regexp(inStr, ' ', 'split');
    fs{1}(1) = lower(fs{1}(1));
    fs{1}(ismember(fs{1}, ignoreChars)) = [];
    
    if ~strcmp(fs{1},'line')
        if ~isempty(str2num(fs{1}))
            fs{1} = ['x' fs{1}];
        end
    end
    
    for ind = 2:length(fs)
       fs{ind}(1) = upper(fs{ind}(1));
       fs{ind}(ismember(fs{ind}, ignoreChars)) = [];
       fs{1} = [fs{1} fs{ind}];
    end
    
    outStr = fs{1};
end