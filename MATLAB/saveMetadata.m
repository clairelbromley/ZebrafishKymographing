function saveMetadata(filepath, metadata, userOptions)

    md = metadata;
    uO = userOptions;
 
    cutDataPath = [filepath filesep sprintf('trimmed_cutinfo_cut_%d.txt', md.cutNumber)];
    fid = fopen(cutDataPath, 'wt');
    structOut(md, fid, 'metadata');
    structOut(uO, fid, 'userOptions');
    fclose(fid);

end

function structOut(inStruct, fid, parentName)
    
    cStruct = struct2cell(inStruct);
    fStruct = fields(inStruct);

    for ind = 1:length(fStruct)
        nc = cStruct{ind};
        
        if (~isstruct(nc))
            fprintf(fid, '%s.%s', parentName, fStruct{ind});
        end
        
        if ischar(nc)
            fprintf(fid, '\t%s', nc);
        else
            for jind = 1:length(nc)
                if isfloat(nc(jind))
                    fprintf(fid, '\t%f', nc(jind));
                elseif isstruct(nc(jind))
                    newParentName = sprintf('%s.%s', parentName, fStruct{ind});
                    structOut(nc(jind), fid, newParentName);
                else
                    fprintf(fid, '\t%d', nc(jind));
                end
            end
        end
        
        if (~isstruct(nc))
            fprintf(fid, '\r\n');
        end
    end
    
end