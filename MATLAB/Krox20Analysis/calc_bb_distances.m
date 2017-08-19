function basal_basal_distances = calc_bb_distances(data, edge)

    theta = -deg2rad(edge.tissueRotation);
    rotMatrix = [cos(theta) -sin(theta); sin(theta) cos(theta)];
    c = [double(data.ome_meta.getPixelsSizeY(0).getNumberValue()), ...
        double(data.ome_meta.getPixelsSizeX(0).getNumberValue())]/2;
    pix_to_micron = double(data.ome_meta.getPixelsPhysicalSizeX(0).value(ome.units.UNITS.MICROM));
    
    edgLs = {'L', 'M', 'R'};
    rhs = [4, 5, 6];
    
    for edg = edgLs
        cc = repmat(c, size(edge.(edg{1}), 1), 1);
        rotated_e.(edg{1}) = (rotMatrix * (edge.(edg{1}) - cc)')' + cc; 
        x = rotated_e.(edg{1})(:,1);
        y = rotated_e.(edg{1})(:,2);
        [y, I] = sort(y);
        x = x(I);
        x = interp1(y, x, ...
            edge.rhombomereLimits(1):edge.rhombomereLimits(4), 'pchip');
        rotated_e.(edg{1}) = [x' (edge.rhombomereLimits(1):edge.rhombomereLimits(4))'];
            
%         msk1 = rotated_e.(edg{1})(:, 2) > edge.rhombomereLimits(4);
%         msk2 = rotated_e.(edg{1})(:, 2) < edge.rhombomereLimits(1);
%         msk = msk1 | msk2;
%         rotated_e.(edg{1})(msk, :) = [];
    end
    
    geometrical_midline(:,1) = rotated_e.L(:,1);
    geometrical_midline(:,2) = (rotated_e.R(:,2) - rotated_e.L(:,2)) ./ 2 + rotated_e.L(:,2);
    
    for rh = rhs
        temp_e.L = rotated_e.L;
        msk1 = rotated_e.L(:, 2) > edge.rhombomereLimits(rh-min(rhs)+2);
        msk2 = rotated_e.L(:, 2) < edge.rhombomereLimits(rh-min(rhs)+1);
        msk = msk1 | msk2;
        temp_e.L(msk, :) = [];
        
        temp_e.R = rotated_e.R;
        temp_e.R(msk, :) = [];
        
        temp_e.M = rotated_e.M;
        temp_e.M(msk, :) = [];
        
        tmp = abs(temp_e.R - temp_e.L);
        basal_basal_distances.(['Rh' num2str(rh)]).mean_bb_dist = mean(tmp(:,1)) * pix_to_micron;
        basal_basal_distances.(['Rh' num2str(rh)]).median_bb_dist = median(tmp(:,1)) * pix_to_micron;
        basal_basal_distances.(['Rh' num2str(rh)]).std_bb_dist = std(tmp(:,1)) * pix_to_micron;
        
        tmpgm = geometrical_midline;
        tmpgm(msk, :) = [];
        basal_basal_distances.(['Rh' num2str(rh)]).meanDeviationFromGeometricalMidline = ...
            mean(abs(tmpgm(:,1) - temp_e.M(:,1))) * pix_to_micron;
        basal_basal_distances.(['Rh' num2str(rh)]).medianDeviationFromGeometricalMidline = ...
            median(abs(tmpgm(:,1) - temp_e.M(:,1))) * pix_to_micron;
        basal_basal_distances.(['Rh' num2str(rh)]).stdDeviationFromGeometricalMidline = ...
            std(abs(tmpgm(:,1) - temp_e.M(:,1))) * pix_to_micron;
        basal_basal_distances.(['Rh' num2str(rh)]).minDeviationFromGeometricalMidline = ...
            min(abs(tmpgm(:,1) - temp_e.M(:,1))) * pix_to_micron;
        basal_basal_distances.(['Rh' num2str(rh)]).maxDeviationFromGeometricalMidline = ...
            max(abs(tmpgm(:,1) - temp_e.M(:,1))) * pix_to_micron;
        
    end
    
    
    tmp = abs(rotated_e.R - rotated_e.L);
    basal_basal_distances.AllRh.mean_bb_dist = mean(tmp(:,1)) * pix_to_micron;
    basal_basal_distances.AllRh.median_bb_dist = median(tmp(:,1)) * pix_to_micron;
    basal_basal_distances.AllRh.std_bb_dist = std(tmp(:,1)) * pix_to_micron;
    
    basal_basal_distances.AllRh.meanDeviationFromGeometricalMidline = ...
        mean(abs(geometrical_midline(:,1) - rotated_e.M(:,1))) * pix_to_micron;
    basal_basal_distances.AllRh.medianDeviationFromGeometricalMidline = ...
        median(abs(geometrical_midline(:,1) - rotated_e.M(:,1))) * pix_to_micron;
    basal_basal_distances.AllRh.stdDeviationFromGeometricalMidline = ...
        std(abs(geometrical_midline(:,1) - rotated_e.M(:,1))) * pix_to_micron;
    basal_basal_distances.AllRh.minDeviationFromGeometricalMidline = ...
        min(abs(geometrical_midline(:,1) - rotated_e.M(:,1))) * pix_to_micron;
    basal_basal_distances.AllRh.maxDeviationFromGeometricalMidline = ...
        max(abs(geometrical_midline(:,1) - rotated_e.M(:,1))) * pix_to_micron;



end