function mdout = manualBasalMembraneKymographPositioning(frame, userOptions, metadata)

    md = metadata;
    uO = userOptions;
    kp = md.kym_region;
    mdout = md;

    if uO.basalMembraneKym

        if (uO.kymDownOrUp)
            direction = ' upwards';
        else
            direction = ' downwards';
        end


        %% generate UI figure

        uifig = figure('Name', ['Choose' direction '-facing basal membrane position']...
            ,'NumberTitle','off');
        handles = guidata(gcf);
        subplot(1,1,1); % To deal with potential for last loop of figures having subplots and messing things up
        imagesc(frame);
        axis equal tight;
        colormap gray;

        set(gca,'xtick',[]);
        set(gca,'xticklabel',[]);
        set(gca, 'ytick', []);
        set(gca,'yticklabel',[]);

        h_cutline = line(kp.xcut, kp.ycut, 'LineStyle', '--', 'Color', 'b', 'LineWidth', 2);
        h_kymline = line([kp.kym_startx; kp.kym_endx], [kp.kym_starty; kp.kym_endy], 'Color', 'r');
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
        uiwait(gcf);

        % reconfigure kymograph region
        handles = guidata(gcf);
        handles.frame = frame;
        
        mdout = reconfigureKymographRegion(handles, md, userOptions);
        
%         mdout = md;
%         mdout.startPositionX = handles.new_cut_x(1) - kp.deltax/2;
%         mdout.
%         mdout.newcuty = handles.new_cut_y - kp.deltay/2;
        
        close(gcf);
    end

end

function proceedFcn(hObject, eventdata, handles)

    uiresume(gcf);

end

function getNewPosition(hObject, eventdata, handles)

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
       
%     set(gcf, 'UserData', handles);
    
    guidata(gcf, handles);

end

function metadata = reconfigureKymographRegion(data_in, metadata, userOptions)

    kp = metadata.kym_region;
    uO = userOptions;
    offset_x = data_in.offset_x - kp.deltax/4;
    offset_y = data_in.offset_y - kp.deltay/4;
    kp.xcut = kp.xcut + offset_x;
    kp.ycut = kp.ycut + offset_y;
    
    kp.kym_startx = kp.kym_startx + offset_x;
    kp.kym_endx = kp.kym_endx + offset_x;
    kp.kym_endx(kp.kym_endx < 1) = 1;
    kp.kym_endx(kp.kym_endx > size(data_in.frame,2)) = size(data_in.frame,2);
    
    kp.kym_starty = kp.kym_starty + offset_y;
    kp.kym_endy = kp.kym_endy + offset_y;
    kp.kym_endy(kp.kym_endy < 1) = 1;
    kp.kym_endy(kp.kym_endy > size(data_in.frame,1)) = size(data_in.frame,1);
    
    kp.boundingBox_LTRB = [floor(min([kp.kym_startx kp.kym_endx]) - uO.kym_width) ...
                        floor(min([kp.kym_starty kp.kym_endy]) - uO.kym_width) ...
                        ceil(max([kp.kym_startx kp.kym_endx]) + uO.kym_width) ...
                        ceil(max([kp.kym_starty kp.kym_endy]) + uO.kym_width)];

    kp.boundingBox_LTRB(kp.boundingBox_LTRB < 1) = 1;

    kp.cropped_xcut = kp.xcut - kp.boundingBox_LTRB(1);
    kp.cropped_ycut = kp.ycut - kp.boundingBox_LTRB(2);
    kp.cropped_kym_startx = kp.kym_startx - kp.boundingBox_LTRB(1);
    kp.cropped_kym_endx = kp.kym_endx - kp.boundingBox_LTRB(1);
    kp.cropped_kym_starty = kp.kym_starty - kp.boundingBox_LTRB(2);
    kp.cropped_kym_endy = kp.kym_endy - kp.boundingBox_LTRB(2);
    
    metadata.kym_region = kp

end