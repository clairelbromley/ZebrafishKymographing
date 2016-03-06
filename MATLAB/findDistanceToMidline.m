function md = findDistanceToMidline(stack, md, uO)

    kp = md.kym_region;

    if strcmp(uO.manualOrAutoApicalSurfaceFinder, 'manual')
        
        frame = squeeze(stack(:,:,1));
        uifig = figure('Name', ['Choose apical membrane position']...
            ,'NumberTitle','off');
        set(uifig, 'Units', 'normalized')
        set(uifig, 'Position', [0 0 1 1]);
        handles = guidata(gcf);
        subplot(1,1,1); % To deal with potential for last loop of figures having subplots and messing things up
        imagesc(frame);
        axis equal tight;
        colormap gray;

        set(gca,'xtick',[]);
        set(gca,'xticklabel',[]);
        set(gca, 'ytick', []);
        set(gca,'yticklabel',[]);
        
        handles.hnewline = line(kp.xcut, kp.ycut, 'LineStyle', '--', 'Color', 'c', 'LineWidth', 3);
        handles.distance_cut_to_apical_surface = 0;

%         h_cutline = line(kp.xcut, kp.ycut, 'LineStyle', '--', 'Color', 'b', 'LineWidth', 2);
%         h_kymline = line([kp.kym_startx; kp.kym_endx], [kp.kym_starty; kp.kym_endy], 'Color', 'r');
        m_cut = (kp.ycut(2) - kp.ycut(1))/(kp.xcut(2) - kp.xcut(1));
        handles.kp = kp;

        set(gca, 'ButtonDownFcn', @getNewPosition)
        children = get(gca, 'Children');
        for ind = 1:length(children)
           set(children(ind), 'ButtonDownFcn', @getNewPosition) 
        end

        %%  set up button
        hButton = uicontrol('String', 'Proceed', 'Units', 'Normalized', 'Position', [0.85 0.5 0.1 0.1], 'Callback', {@proceedFcn, handles});
        
        guidata(gcf, handles);

        %% pause running using waitfor
%         waitfor(gcf);
        beep;
        handles.kp = kp;
        uiwait(gcf);

        % calculate distance to apical surface in um
        handles = guidata(gcf);
        md.distanceToApicalSurface = handles.distance_cut_to_apical_surface * md.umperpixel;
        
        close(uifig);
        
    else

        %% Extrapolate perpendicular bisector of the cut to edge of image
        num_kym = length(kp.kym_starty);
        centre_ind = ceil(num_kym/2);
        m = (kp.kym_endy(centre_ind) - kp.kym_starty(centre_ind))/(kp.kym_endx(centre_ind) - kp.kym_startx(centre_ind));
        b = kp.kym_starty(centre_ind);
        a = kp.kym_startx(centre_ind);

        angle_made_with_xaxis = atan(m);

        maxx = size(stack, 1);
        maxy = size(stack, 2);

        line_thru_centre_y = [[1; maxx] m*([1; maxx] - a) + b];
        line_thru_centre_x = [a + (1/m)*([1; maxy] - b) [1; maxy]];

        ltc = [line_thru_centre_x; line_thru_centre_y];
        ll = ltc > 512 | ltc < 1;
        ll = sum(ll,2);
        ltc = ltc(~logical(ll),:);

        ltc_len = ltc(1,:) - ltc(2,:);
        ltc_len = round(sqrt(ltc_len(1)^2  + ltc_len(2)^2));


        %% Generate image profiles along perpendicular bisector and several parallel 
        %% lines on either side, taking average to give smoothed profile

        ltc_base = ltc;
        p = ltc == 1 | ltc == maxx | ltc == maxy;
    %     if max(sum(p,1)) == 2
        for reps = 1:3
            ltc = [ltc; ltc_base + reps * ~p];
            ltc = [ltc; ltc_base - reps * ~p];
        end
    %     end

        for ind = 1:7
            profs(ind, :) = improfile(squeeze(stack(:,:,1)),...
                [ltc(2*ind - 1, 1) ltc(2*ind, 1)], [ltc(2*ind - 1, 2) ltc(2*ind, 2)], ...
                ltc_len);
        end

        prof = mean(profs, 1);

        %% Then from the image profile maximum, identify the distance of the cut
        %% from the apical surface
        [~, maxind] = max(prof);
        x_apical_point = ltc(1,1) + maxind * cos(angle_made_with_xaxis);
        y_apical_point = ltc(1,2) + maxind * sin(angle_made_with_xaxis);

        distance_cut_to_apical_surface = sqrt((x_apical_point - a)^2 + ...
            (y_apical_point - b)^2);
        
        md.distanceToApicalSurface = distance_cut_to_apical_surface * md.umperpixel;

    end
    
end

function proceedFcn(hObject, eventdata, handles)
% function copied from manualBasalMembraneKymographPositioning.m; break out
% to standalone function?

    uiresume(gcf);

end

function getNewPosition(hObject, eventdata, handles)
% function copied from manualBasalMembraneKymographPositioning.m; break out
% to standalone function?

    handles = guidata(gcf);
    
    if isfield(handles, 'hnewline')
        delete(handles.hnewline)
    end

    %% get position on axes
    a = get(gca, 'CurrentPoint');
    x = a(1,1);
    y = a(1,2);
    
    %% project onto cut line - cut line unit vector * (cut line unit vec)(dot)(hyp)
    cutcentrexy = [handles.kp.xcut(1) handles.kp.ycut(1)] + [(handles.kp.xcut(2) - handles.kp.xcut(1))/2 (handles.kp.ycut(2) - handles.kp.ycut(1))/2];
%     cline = line(cutcentrexy(1), cutcentrexy(2), 'LineStyle', 'none', 'Marker', 'o', 'MarkerEdgeColor', 'y', 'MarkerSize', 10)
    hyp = [x y] - cutcentrexy;
    vec_parallel_to_cut = [handles.kp.xcut(2) handles.kp.ycut(2)] - cutcentrexy;
    unit_vec_parallel_to_cut = vec_parallel_to_cut/norm(vec_parallel_to_cut);
    proj_on_cut = unit_vec_parallel_to_cut * dot(unit_vec_parallel_to_cut, hyp);
    proj_perp_to_cut = hyp - proj_on_cut;
    % by definition, projection perpendicular to cut is what we need to add
    % to the cut centre to get to the centre of the new cut, and hence is
    % what needs to be added to either end of the cut line to get to the
    % new cut lines...
    newx = handles.kp.xcut + proj_perp_to_cut(1);
    newy = handles.kp.ycut + proj_perp_to_cut(2);
    handles.hnewline = line(newx, newy, 'LineStyle', '--', 'Color', 'c', 'LineWidth', 3);
    handles.new_cut_x = newx;
    handles.new_cut_y = newy;
    handles.offset_x = round(proj_perp_to_cut(1));
    handles.offset_y = round(proj_perp_to_cut(2));
    
    handles.distance_cut_to_apical_surface = sqrt(handles.offset_x^2 + handles.offset_y^2);;
    disp('distance_cut_to_apical_surface = ');
    disp(handles.distance_cut_to_apical_surface);
%     set(gcf, 'UserData', handles);
    
    guidata(gcf, handles);

end