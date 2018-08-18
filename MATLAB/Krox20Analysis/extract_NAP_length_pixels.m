function out = extract_NAP_length_pixels(data_root, start_hpf, pix_per_um)

    out.NAP_length_pixels = [];
    out.hpf = [];
    out.z = [];
    out.sinuosity = [];
    out.NAP_length_um = [];
    out.analysis_folder = cell(0);
    out.coordinates = cell(0);

    data_paths = dir([data_root filesep '*Ncad Krox Analysis']);
%     data_paths.name = '28-Aug-2017 17_42_04 Ncad Krox Analysis';
    
    for pidx = 1:length(data_paths)
        data_path = [data_root filesep data_paths(pidx).name filesep 'backup.mat'];
        load(data_path);
        edgs = data.edges;

        % get image dimensions...
        [p, ~, ~] = fileparts(data_path);
        tiffs = dir([p filesep 'z = 35.00 um' filesep 'NCad*.tif']);
        widths = [];
        heights = [];
        for idx = 1:length(tiffs)
            fp = [p filesep 'z = 35.00 um' filesep tiffs(idx).name];
            info = imfinfo(fp);
            widths = [widths; info.Width];
            heights = [heights; info.Height];
        end
        w = mean(widths);
        h = mean(heights);


        % loop over edges...
        for eidx = 1:length(edgs)
            disp(eidx);
%             if (eidx == 19)
%                 disp('pause');
%             end
            edg = edgs(eidx);
            if ~isempty(edg.M)
                % rotate midline:
                theta = -deg2rad(edg.tissueRotation);
                rotMatrix = [cos(theta) -sin(theta); sin(theta) cos(theta)];
                c = [h, w]/2;
                cc = repmat(c, size(edg.M, 1), 1);
                rotated_midline = (rotMatrix * (edg.M - cc)')' + cc;

                % apply mask - not sure of justification, but done
                % previously...
                msk1 = rotated_midline(:, 2) > edg.rhombomereLimits(4);
                msk2 = rotated_midline(:, 2) < edg.rhombomereLimits(1);
                msk = msk1 | msk2;
                rotated_midline(msk, :) = [];
                
                %ensure monotonic increasing...
                y = rotated_midline(:,2);
                x = rotated_midline(:,1);
                if (mean(diff(y)) < 0)
                    y = flipud(y);
                    x = flipud(x);
                end
                mi_msk = (diff(y) <= 0);
                while (any(mi_msk))
                    y(mi_msk) = [];
                    x(mi_msk) = [];
                    mi_msk = (diff(y) <= 0);
                end
                
                ymin = min(rotated_midline(:,2));
                ymax = max(rotated_midline(:,2));
                yinterp = (ymin:0.25:ymax);
                xinterp = interp1(y, x, yinterp, 'pchip');
                disp(['filling coords for edge' num2str(eidx) ', path ' num2str(pidx)]);
%                 out.coordinates{eidx} = [xinterp' yinterp']./pix_per_um;
                out.coordinates = [out.coordinates; [xinterp' yinterp']./pix_per_um];
                
                manual_length = 0;
                for idx = 2:length(rotated_midline)
                    manual_length = manual_length + ...
                        sqrt( (rotated_midline(idx, 1) - rotated_midline(idx - 1, 1))^2 + ...
                        (rotated_midline(idx, 2) - rotated_midline(idx - 1, 2))^2 );
                end

                straight_length = sqrt((rotated_midline(end, 1) - rotated_midline(1, 1))^2 + ...
                    (rotated_midline(end, 2) - rotated_midline(1, 2))^2 );
                sinuosity_index = manual_length/straight_length - 1; 

                disp(['filling other params for edge ' num2str(eidx) ', path ' num2str(pidx)]);
                out.NAP_length_pixels = [out.NAP_length_pixels; manual_length];
                out.NAP_length_um = [out.NAP_length_um; manual_length / pix_per_um];
                out.hpf = [out.hpf; edg.timestamp/60 + start_hpf];
                out.z = [out.z; edg.z];
                out.sinuosity = [out.sinuosity; sinuosity_index];
                out.analysis_folder = [out.analysis_folder; data_paths(pidx).name];
            end
        end
    end