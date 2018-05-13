function data = translate_line_pairs_to_rh_edges(edg, controls, data)

    rhombomere_no = sscanf(edg, 'Rh%d');
    edg = ['Rh' num2str(rhombomere_no)];
    
    z = round((data.top_slice_index -  round(get(controls.hzsl, 'Value'))) * ...
        double(data.ome_meta.getPixelsPhysicalSizeZ(0).value(ome.units.UNITS.MICROM)));
    t = data.timepoint;
    
    if ~isempty(data.edges)
        ts = [data.edges.timepoint];
        zs = [data.edges.z];
       
        top = data.edges((ts == t) & (zs == z)).([edg 'Top']);
        bot = data.edges((ts == t) & (zs == z)).([edg 'Bot']);
        
        % identify basal surfaces as peaks in smoothed line profile along
        % defined line. Makes assumptions about how the line is drawn, and
        % will also fall over because of bright regions outside the basal
        % surface. Don't worry about this for now as there's no crucial
        % morphological data taken from these definitions. 
        im = get(controls.hax, 'Children');
        im = get(im(strcmp(get(im, 'Type'), 'image')), 'CData');
        
        lt = improfile(im, top(:,1), top(:,2));
        lb = improfile(im, bot(:,1), bot(:,2));
        for yidx = 1:2
            lt = lt + improfile(im, top(:,1), top(:,2) + yidx);
            lt = lt + improfile(im, top(:,1), top(:,2) - yidx);
            lb = lb + improfile(im, bot(:,1), bot(:,2) + yidx);
            lb = lb + improfile(im, bot(:,1), bot(:,2) - yidx);
        end
        lt = lt/5;
        lb = lb/5;
        
        lt = smooth(lt, 50);
        lb = smooth(lb, 50);
        
        [~, top_left_peak_pos] = max(lt(1:round(length(lt)/4)));
        [~, top_right_peak_pos] = max(lt(round(3*length(lt)/4):end));
        top_right_peak_pos = top_right_peak_pos + round(3*length(lt)/4);
        [~, bot_left_peak_pos] = max(lb(1:round(length(lb)/4)));
        [~, bot_right_peak_pos] = max(lb(round(3*length(lb)/4):end));
        bot_right_peak_pos = bot_right_peak_pos + round(3*length(lb)/4);
        
        top_left_corner_x = top(1,1) + ...
            top_left_peak_pos * (top(2,1) - top(1,1))/length(lt);
        top_left_corner_y = top(1,2) + ...
            top_left_peak_pos * (top(2,2) - top(1,2))/length(lt);
        top_right_corner_x = top(1,1) + ...
            top_right_peak_pos * (top(2,1) - top(1,1))/length(lt);
        top_right_corner_y = top(1,2) + ...
            top_right_peak_pos * (top(2,2) - top(1,2))/length(lt);
        
        bot_left_corner_x = bot(1,1) + ...
            bot_left_peak_pos * (bot(2,1) - bot(1,1))/length(lt);
        bot_left_corner_y = bot(1,2) + ...
            bot_left_peak_pos * (bot(2,2) - bot(1,2))/length(lt);
        bot_right_corner_x = bot(1,1) + ...
            bot_right_peak_pos * (bot(2,1) - bot(1,1))/length(lt);
        bot_right_corner_y = bot(1,2) + ...
            bot_right_peak_pos * (bot(2,2) - bot(1,2))/length(lt);
        
        data.current_edge = [top_left_corner_x top_left_corner_y;...
            top_right_corner_x top_right_corner_y;...
            bot_right_corner_x bot_right_corner_y;...
            bot_left_corner_x bot_left_corner_y];
        
        data = add_edge(edg, controls, data);
    end

end