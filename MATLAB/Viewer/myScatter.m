function hs = myScatter(x, y, S, C, parent)

hold(parent, 'on');
xlim = get(parent, 'XLim');
ylim = get(parent, 'YLim');
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
    
    hs(ind) = scatter(x(ind), y(ind), si, ci, 'fill');
    
end

hold(parent, 'off');
set(parent, 'XLim', xlim);
set(parent, 'YLim', ylim);