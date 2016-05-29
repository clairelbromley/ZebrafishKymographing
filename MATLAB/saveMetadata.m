function saveMetadata(filepath, metadata, userOptions, varargin)


    md = metadata;
    uO = userOptions;
 
    if isempty(varargin)
        cutDataPath = [filepath filesep sprintf('trimmed_cutinfo_cut_%d.txt', md.cutNumber)];
        fid = fopen(cutDataPath, 'wt');
        structOut(md, fid, 'metadata');
        structOut(uO, fid, 'userOptions');
    elseif length(varargin) == 2
        cutDataPath = [filepath filesep sprintf('basal_kymograph_positioning_cut_%d.csv', md.cutNumber)];
        kp = varargin{1};
        ind = varargin{2};
        fid = fopen(cutDataPath, 'a');
        structOut(kp, fid, ['kym_region_' num2str(ind)])
    end
    fclose(fid);

end

function structOut(inStruct, fid, parentName)

    if ~isstruct(inStruct)
        inStruct = struct(inStruct);
    end
    
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
                elseif isa(nc(jind), 'matlab.ui.figure')
                    % FIX ISSUE IN R2015 WHERE WHAT IS RETURNED BY FIGURE
                    % IS AN OBJECT RATHER THAN A HANDLE. 
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