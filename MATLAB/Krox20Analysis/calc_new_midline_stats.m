function new_midline_def = calc_new_midline_stats(data, xedge, old_analysis_dt_folder)

    new_midline_def.AllRh.mean_midline_def = NaN;
    new_midline_def.AllRh.median_midline_def = NaN;
    new_midline_def.AllRh.std_midline_def = NaN;
    new_midline_def.AllRh.min_midline_def = NaN;
    new_midline_def.AllRh.max_midline_def = NaN;

    new_midline_def.AllRh.mean_midline_intensity = NaN;
    new_midline_def.AllRh.median_midline_intensity = NaN;
    new_midline_def.AllRh.std_midline_intensity = NaN;
    new_midline_def.AllRh.min_midline_intensity = NaN;
    new_midline_def.AllRh.max_midline_intensity = NaN;
    
    new_midline_def.AllRh.mean_NOTmidline_intensity = NaN;
    new_midline_def.AllRh.median_NOTmidline_intensity = NaN;
    new_midline_def.AllRh.std_NOTmidline_intensity = NaN;
    new_midline_def.AllRh.min_NOTmidline_intensity = NaN;
    new_midline_def.AllRh.max_NOTmidline_intensity = NaN;

    new_midline_def.AllRh.mean_bg_region_intensity = NaN;
    new_midline_def.AllRh.median_bg_region_intensity = NaN;
    new_midline_def.AllRh.std_bg_region_intensity = NaN;
    new_midline_def.AllRh.min_bg_region_intensity = NaN;
    new_midline_def.AllRh.max_bg_region_intensity = NaN;

    new_midline_def.AllRh.sum_total = NaN;
    new_midline_def.AllRh.sum_midline = NaN;
    new_midline_def.AllRh.sum_bg_region = NaN;
    new_midline_def.AllRh.sum_NOT_midline = NaN;

    if ~isempty(xedge.M)
        midline_thickness_pix = 20;
        
        % get raw data from old_analysis_out_folder
        im = imread([old_analysis_dt_folder filesep ... 
            sprintf('z = %0.2f um', xedge.z) filesep ...
            sprintf('Ncad, t = %0.2f.tif', xedge.timestamp)]);
        
        rotim = imrotate(im, xedge.tissueRotation, 'bilinear', 'crop');
        theta = -deg2rad(xedge.tissueRotation);
        rotMatrix = [cos(theta) -sin(theta); sin(theta) cos(theta)];
        c = [double(data.ome_meta.getPixelsSizeY(0).getNumberValue()), ...
            double(data.ome_meta.getPixelsSizeX(0).getNumberValue())]/2;

        edgLs = {'L', 'R', 'M'};
        for edg = edgLs
            cc = repmat(c, size(xedge.(edg{1}), 1), 1);
            rotated_e.(edg{1}) = (rotMatrix * (xedge.(edg{1}) - cc)')' + cc; 
            x = rotated_e.(edg{1})(:,1);
            y = rotated_e.(edg{1})(:,2);
    %         [y, I] = sort(y);
            [y, I, ~] = unique(y, 'sorted');
            x = x(I);
            x = interp1(y, x, ...
                xedge.rhombomereLimits(1):xedge.rhombomereLimits(4), 'pchip');
            rotated_e.(edg{1}) = [x' (xedge.rhombomereLimits(1):xedge.rhombomereLimits(4))'];

        end
        
        midline_im = zeros(size(rotim));
        midline_col = [];
        denominator_im = zeros(size(rotim));
        denominator_col = [];
        for yind = min(rotated_e.M(:,2)):max(rotated_e.M(:,2))
            myind = yind - min(rotated_e.M(:,2)) + 1;
            midline_im(yind, round(rotated_e.M(myind, 1) - midline_thickness_pix/2):round(rotated_e.M(myind, 1) + midline_thickness_pix/2)) =...
                rotim(yind, round(rotated_e.M(myind, 1) - midline_thickness_pix/2):round(rotated_e.M(myind, 1) + midline_thickness_pix/2));
            midline_col = [midline_col; rotim(yind, round(rotated_e.M(myind, 1) - midline_thickness_pix/2):round(rotated_e.M(myind, 1) + midline_thickness_pix/2))];
            denominator_im(yind, round(rotated_e.M(myind, 1) - 11 * midline_thickness_pix/2):round(rotated_e.M(myind, 1) - 9 * midline_thickness_pix/2)) =...
                rotim(yind, round(rotated_e.M(myind, 1) - 11 * midline_thickness_pix/2):round(rotated_e.M(myind, 1) - 9 * midline_thickness_pix/2));
            denominator_col = [denominator_col; rotim(yind, round(rotated_e.M(myind, 1) - 11 * midline_thickness_pix/2):round(rotated_e.M(myind, 1) - 9 * midline_thickness_pix/2))];
        end
    
        if strcmp(data.midline_definition_method, 'max')
            midline_definition_array = double(max(midline_col, [], 2)) ./  double(mean(denominator_col, 2));
        else
            midline_definition_array = double(mean(midline_col, 2)) ./  double(mean(denominator_col, 2));
        end

        new_midline_def.AllRh.mean_midline_def = mean(midline_definition_array);
        new_midline_def.AllRh.median_midline_def = median(midline_definition_array);
        new_midline_def.AllRh.std_midline_def = std(midline_definition_array);
        new_midline_def.AllRh.min_midline_def = min(midline_definition_array);
        new_midline_def.AllRh.max_midline_def = max(midline_definition_array);

        % output raw data; that is, not ratiod
        new_midline_def.AllRh.mean_midline_intensity = mean(midline_col(:));
        new_midline_def.AllRh.median_midline_intensity = median(midline_col(:));
        new_midline_def.AllRh.std_midline_intensity = std(double(midline_col(:)));
        new_midline_def.AllRh.min_midline_intensity = min(midline_col(:));
        new_midline_def.AllRh.max_midline_intensity = max(midline_col(:));

        new_midline_def.AllRh.mean_bg_region_intensity = mean(denominator_col(:));
        new_midline_def.AllRh.median_bg_region_intensity = median(denominator_col(:));
        new_midline_def.AllRh.std_bg_region_intensity = std(double(denominator_col(:)));
        new_midline_def.AllRh.min_bg_region_intensity = min(denominator_col(:));
        new_midline_def.AllRh.max_bg_region_intensity = max(denominator_col(:));

        % output sums: total between basal edges, midline, and total between
        % basal edges that ISN'T midline. For completeness, also sum region
        % that was previously used to normalise the midline definition
        xs = [rotated_e.L(:,1); flipud(rotated_e.R(:, 1))];
        ys = [rotated_e.L(:,2); flipud(rotated_e.R(:, 2))];
        msk = poly2mask(xs, ys, size(im,1), size(im,2));

        new_midline_def.AllRh.sum_total = sum(im(msk));
        new_midline_def.AllRh.sum_midline = sum(midline_col(:));
        new_midline_def.AllRh.sum_bg_region = sum(denominator_col(:));
        new_midline_def.AllRh.sum_NOT_midline = new_midline_def.AllRh.sum_total - ...
            new_midline_def.AllRh.sum_midline;
        
        new_midline_def.AllRh.mean_NOTmidline_intensity = mean(im(msk));
        new_midline_def.AllRh.median_NOTmidline_intensity = median(im(msk));
        new_midline_def.AllRh.std_NOTmidline_intensity = std(double(im(msk)));
        new_midline_def.AllRh.min_NOTmidline_intensity = min(im(msk));
        new_midline_def.AllRh.max_NOTmidline_intensity = max(im(msk));

    end
end        