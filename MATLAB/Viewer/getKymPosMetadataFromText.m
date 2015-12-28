function output = getKymPosMetadataFromText(filename)

    output = [];
    fid = fopen(filename);
    str = fgets(fid);
    while ischar(str)
        a = regexp(str, '\t', 'split');
        
        if strcmp(a{1}, 'metadata.kym_region.pos_along_cut')
            for ind = 2:length(a)
                output(ind-1) = str2num(a{ind});
            end
        end
        str = fgets(fid);
    end
    
    fclose(fid);
    
end