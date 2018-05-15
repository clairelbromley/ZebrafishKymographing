function rhombomere_edge = redraw_rhombomere(data, controls, rhtag)
% generate rhombomeres based on basal edges and morphological marker-based
% upper and lower limits. 

    z = round((data.top_slice_index -  round(get(controls.hzsl, 'Value'))) * ...
        double(data.ome_meta.getPixelsPhysicalSizeZ(0).value(ome.units.UNITS.MICROM)));
    t = data.timepoint;
    
    ts = [data.edges.timepoint];
    zs = [data.edges.z];

    % get relevant upper and lower edges
    top = data.edges((ts == t) & (zs == z)).([rhtag 'Top']);
    bot = data.edges((ts == t) & (zs == z)).([rhtag 'Bot']);
    
    % get relevant left and right edges
    left = data.edges((ts == t) & (zs == z)).L;
    right = data.edges((ts == t) & (zs == z)).R;
    
    % sort l edge and inverse-sort r edge, and truncate at y value of top
    % and bottom edges, by interpolating from either side of the top and
    % bottom edges and thus getting the position at which the lateral and
    % horizontal edges intersect
    ytop = top(2,2);
    ybot = bot(2,2);
    
    left = [left; ...
            [find_cross_point(left, ytop) ytop]; ...
            [find_cross_point(left, ybot) ybot]];
    left = left((left(:,2) >= ytop) & (left(:,2) <= ybot), :);
    
    right = [right; ...
            [find_cross_point(right, ytop) ytop]; ...
            [find_cross_point(right, ybot) ybot]];
    right = right((right(:, 2) >= ytop) & (right(:,2) <= ybot), :);
        
    [~, I] = sort(left(:,2));
    left = left(I, :);
    [~, I] = sort(right(:,2));
    right = flipud(right(I, :));
    
    rhombomere_edge = [left; right];

end