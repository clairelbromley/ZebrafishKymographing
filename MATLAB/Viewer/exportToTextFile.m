function exportToTextFile(outputFile, headerLine, data, fieldDelimiter, recordDelimiter)

    %% establish the formatSpec string...
    formatSpec = '';
    headerFormatSpec = '';

    % establish the delimiters
    if isempty(fieldDelimiter)
        fdlm = ',';
    else
        fdlm = fieldDelimiter;
    end

    if isempty(recordDelimiter)
        rdlm = '\n';
    else
        rdlm = recordDelimiter;
    end

    for fld = 1:size(data, 2);
        
        if fld == 1
            dlm = '';
        else
            dlm = fdlm;
        end
        
        var = data{1, fld};
        varType = class(var);

        switch varType
            case 'char'
                formatSpec = [formatSpec dlm '%s'];
            case 'double'
                formatSpec = [formatSpec dlm '%0.5f'];
            otherwise
                formatSpec = [formatSpec dlm '%d'];
        end
        
        headerFormatSpec = [headerFormatSpec dlm '%s'];

    end
    formatSpec = [formatSpec rdlm];
    
%     disp(formatSpec);
    
    %% write file
    fid = fopen(outputFile, 'a');
    fprintf(fid, headerFormatSpec, headerLine{:});
    fprintf(fid, '%s\n', '');
    
    for rcrd = 1:size(data, 1)
        
        inCell = data(rcrd, :);
        outCell = replaceCommas(inCell, ';');
        fprintf(fid, formatSpec, outCell{:});
        
    end
    
    fclose(fid);
    
end


function outCell = replaceCommas(inCell, repChar)
    
    outCell = inCell;
    for ind = 1:length(inCell)
        if ischar(inCell{ind})
            outCell{ind} = strrep(inCell{ind}, ',', repChar);
        end
    end
    
end
        

        