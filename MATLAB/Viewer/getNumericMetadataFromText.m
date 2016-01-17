function output = getNumericMetadataFromText(filename, variablename)

    output = [];
    fid = fopen(filename);
    str = fgets(fid);
    while ischar(str)
        a = regexp(str, '\t', 'split');
        
        if strcmp(a{1}, variablename)
            for ind = 2:length(a)
                output(ind-1) = str2num(a{ind});
            end
        end
        str = fgets(fid);
    end
    
    fclose(fid);
    
end