function md = getKymographPositionMetadata(uO, md, curr_path)

    indOut = double(uO.kymDownOrUp)+1;
    pat = [curr_path filesep sprintf('basal_kymograph_positioning_cut_%d.csv', md.cutNumber)];
    fid = fopen(pat);
    
    while ~feof(fid)
        l = fgetl(fid);
        % parse text to structure
        A = regexp(l, '\t', 'split');
        B = regexp(A{1},'\.', 'split');
        newInd = str2num(B{1}(end));
        if newInd == indOut
            fld = B{2};
            vals = [];
            for ind = 2:(length(A))
                vals = [vals str2num(A{ind})];
            end
            
            kp.(fld) = vals;
            
        end
    end
    
    md.kym_region = kp; 
    
end