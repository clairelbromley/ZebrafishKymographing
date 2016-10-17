function hs = myScatter(x, y, S, C, parent)

haskids = ~isempty(get(parent, 'Children'));
hold(parent, 'on');

if haskids
    xlmts = get(parent, 'XLim');
    ylmts = get(parent, 'YLim');
end
% check vectors are all either the same length or one element. 


hs = zeros(length(x), 1);

for ind = 1:length(x)
    
    if numel(S) == 1
        si = S;
    else
        si = S(ind);
    end
    
    if size(C,1) == 1
        ci = C;
    else
        ci = C(ind, :);
    end
    
    hs(ind) = scatter(x(ind), y(ind), si, ci, 'fill', 'Parent', parent);
    
end

hold(parent, 'off');

if haskids
    set(parent, 'XLim', xlmts);
    set(parent, 'YLim', ylmts);
else
    % manually set limits since it seems matlab can't be trusted to do this
    % properly
    rx = max(x) - min(x);
    ry = max(y) - min(y);
    set(parent, 'XLim', [(min(x) - 0.1 * rx) (max(x) + 0.1 * rx)]);
    set(parent, 'YLim', [(min(y) - 0.1 * ry) (max(y) + 0.1 * ry)]);
    axis fill;
    axis normal;
    
end