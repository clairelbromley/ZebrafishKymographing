function updateMyScatterColors(hs, colormat)

for ind = 1:length(hs)
    
    set(hs(ind), 'MarkerEdgeColor', colormat(ind,:), ...
        'MarkerFaceColor', colormat(ind, :));
    
end