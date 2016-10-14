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
end