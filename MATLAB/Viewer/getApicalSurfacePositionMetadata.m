function distanceToApicalSurface = getApicalSurfacePositionMetadata(uO, md, curr_path)

    pat = [curr_path filesep sprintf('apical_surface_distance_to_cut_%d.csv', md.cutNumber)];
    fid = fopen(pat);
    
    while ~feof(fid)
        l = fgetl(fid);
        % parse text to structure
        A = regexp(l, '\t', 'split');
        distanceToApicalSurface = str2double(A{2});
    end
    
    fclose(fid);
end