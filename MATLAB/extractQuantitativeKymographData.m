function results = extractQuantitativeKymographData(kymographs, metadata, userOptions)

    kyms = kymographs;
    md = metadata;
    uO = userOptions;
    kp = md.kym_region;
    
    if (uO.kymDownOrUp)
        direction = ' upwards';
    else
        direction = ' downwards';
    end
    
    dir_txt = sprintf('%s, Embryo %s%s', md.acquisitionDate, md.embryoNumber, direction);
    
    results = [];
    speeds = [];
    for kpos = 1:numel(kp.kym_startx)

        result.kym_number = kpos;
        % - trim kymograph - initially first 20 frames (=4 seconds)
        x = find(sum((squeeze(kyms(:,:,kpos))'),1)==0);
        if length(x) < 4
            first_frame = max(x)+1;
%             first_frame = (find(sum((squeeze(kyms(:,:,kpos))'),1)==0, 1, 'last'))+1;
            kym_segment = squeeze(kyms(first_frame:first_frame+20,:,kpos))';
            %     correct_membrane = zeros(size(kym_segment,1), size(kym_segment,2), num_kyms);
            % - use canny edge filter to get binary image of membrane front movement
            filt_kym = edge(kym_segment, 'canny');
            result.kym_segment = kym_segment;

%             pos_along_cut = (kpos-2)*(kp.kym_startx(2) - kp.kym_startx(1))*md.umperpixel;
            distanceOffset = sqrt((kp.kym_startx(1) - kp.xcut(1))^2 + (kp.kym_starty(1) - kp.ycut(1))^2)*md.umperpixel;
            pos_along_cut = (kpos-2)*uO.kymSpacingUm - distanceOffset;
            title_txt = sprintf('%s, Embryo %s, Cut %d, Kymograph position along cut: %0.2f um', md.acquisitionDate, ...
                md.embryoNumber, md.cutNumber, pos_along_cut);
            file_title_txt = sprintf('%s, Embryo %s, Cut %d, Kymograph index along cut = %d - quantitative kymograph', md.acquisitionDate, ...
            md.embryoNumber, md.cutNumber, (kpos-2));

            if ~isfield(uO, 'figHandle')
                h = figure('Name', title_txt,'NumberTitle','off');
            else
                h = uO.figHandle;
                set(uO.figHandle, 'Name', title_txt,'NumberTitle','off');
                set(0, 'currentFigure', uO.figHandle)
            end

            subplot(1,3,1);
            imagesc(kym_segment);
            axis equal tight;
        %     subplot(1,4,2);
        %     imagesc(filt_kym); 
        %     axis equal tight; 
            colormap gray;
        %     subplot(1,4,3);
            l = bwlabel(filt_kym);
        %     imagesc(l);
        %     axis equal tight;
            r = regionprops(filt_kym);
            % Sort regions by y position (centroid)
            dpos = [];
            for i = 1:length(r)
                dpos = [dpos; r(i).Centroid(2)];
            end
            [dpos, I] = sort(dpos);
            % Then check the time extent of the trace for each of these in order;
            % the first one that is found that extends more than 80% of the trace
            % is considered to be the right one
            % N.B. this may (will?) break down in case when we have more than the
            % first four seconds as the canny edge might be discontinuous. 
            found = false;
            i = 1;
            while (found == false)

                if (r(I(i)).BoundingBox(3) > size(filt_kym,2)*.8)
                    found = true;
                else
                    i=i+1;
                end
                % Break out of loop if a sensible edge hasn't been found
                if (i > length(dpos))
                    found = true;
                end
            end

            correct_membrane = zeros(size(l));
            if (i < length(dpos))
                % Identify only the highest edge - perform loop through each column
                % and choose the first pixel:
                % - choose the highest edge to represent the membrane front, extract t, d
                % co-ordinates for this edge...
                t = []; d = [];
                correct_membrane = (l == I(i));

                for tind = 1:size(correct_membrane,2)
                    point_sel = false;
                    for dind = 1:size(correct_membrane,1)
    %                     tind
    %                     dind
                        if (not(point_sel)) && ( correct_membrane(dind, tind) > 0 )
                                point_sel = true;
                                correct_membrane(dind, tind) = 1;
                                t = [t; (tind - 1)*md.acqMetadata.cycleTime];
                                d = [d; (dind - 1)*md.umperpixel];
                        else
                            correct_membrane(dind, tind) = 0;
                        end

                    end

                end
                result.t = t;
                result.d = d;
                result.correct_membrane = correct_membrane;
                subplot(1,3,2);
                imagesc(correct_membrane);
                axis equal tight;

        % - fit curve to this data (first order is a straight line, goodness of fit
        % tells us how linear motion actually is, discuss with supervisors what
        % alternative models to fit)
        % Probably want to fit (or at least mention) an overdamped oscillator: 
        % https://en.wikipedia.org/wiki/Damping
        %         linfit = fittype('poly1');
                fres = fit(t, d, 'poly1');
                result.fit_results = fres;
                subplot(1,3,3);
                scatter(t,d);
                hold on
                plot(t, fres.p1*t + fres.p2, 'r');
                hold off
                axis equal
                xlabel('Time after cut, s');
                ylabel('Membrane position relative to cut, \mum');
        % - convert to um/second
%                 result.speed = fres.p1 * md.umperpixel * (1/md.acqMetadata.cycleTime);
                result.speed = fres.p1;
                s = [result.speed; pos_along_cut];
                speeds = [speeds s];
                title([sprintf('Membrane speed = %0.2f ', result.speed) '\mum s^{-1}'])
                %TODO: overlay line automatically on kymographs
                out_file = [uO.outputFolder filesep dir_txt filesep file_title_txt];
                print(out_file, '-dpng', '-r300');
                savefig(h, [out_file '.fig']);

            end

%             results = [results; result];
            
        end
    end
    % TODO: plot speeds for all kymographs along cut in a scatter graph. 
    %% Plot speeds against kymograph position
    if numel(speeds)>0
            title_txt = sprintf('%s, Embryo %s, Cut %d, Speed against cut position', md.acquisitionDate, ...
                md.embryoNumber, md.cutNumber);

            if ~isfield(uO, 'figHandle')
                h = figure('Name', title_txt,'NumberTitle','off');
            else
                h = uO.figHandle;
                set(uO.figHandle, 'Name', title_txt,'NumberTitle','off');
                set(0, 'currentFigure', uO.figHandle)
            end
            
            subplot(1,1,1);
            plot(speeds(2,:), speeds(1,:), '-x');
            xlabel('Kymograph position along cut, \mum');
            ylabel('Membrane speed, \mum s^{-1}');
            title([title_txt direction]);
            
            out_file = [uO.outputFolder filesep dir_txt filesep title_txt direction];
            print(out_file, '-dpng', '-r300');
            savefig(h, [out_file '.fig']);            

            xlim([uO.forcedPositionRange]);
            ylim([uO.forcedSpeedRange]);
            
            out_file = [uO.outputFolder filesep dir_txt filesep title_txt direction ' fixed axes'];
            print(out_file, '-dpng', '-r300');
            savefig(h, [out_file '.fig']);

            if ~isfield(uO, 'figHandle')
                close(h);
            end
    end
            
    % TODO: reference to excel spreadsheet with development time

    
end