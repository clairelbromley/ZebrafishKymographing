function xcoord = find_cross_point(edg, ycoord)
% given the y-coordinate of a horizontal line and a nx2-array representing
% a (near-vertical) edge, find the x-coordinate of the point where the edge
% crosses the line. 

    [~, I] = sort(edg(:,2));
    edg = edg(I, :);
    ys  = edg(:,2) - ycoord;
    [~, mnidx] = min(abs(ys));
    c1 = edg(mnidx, :);
    if ys(mnidx) > 0
        edg = edg((ys < 0), :);
        ys = ys(ys < 0);
    else
        edg = edg((ys >= 0), :);
        ys = ys(ys >= 0);
    end
    [~, mnidx] = min(abs(ys));
    c2 = edg(mnidx, :);
    f = (c2(2) - ycoord)/(c2(2) - c1(2));
    xcoord = f * (c2(1) - c1(1)) + c1(1);
    
end