data_path = 'C:\Users\Doug\Downloads\depth 35um AP lengths .xlsx';
[~, ~, raw] = xlsread(data_path);
data = [];
for colidx = 1:5
    data.(strrep(raw{1, colidx}, ' ', '_')) = raw(2:end, colidx);
end
embryo_ids = unique(data.Embryo);

ax_pos = [];
txth = [];
figure;

for embryo_idx = 1:length(embryo_ids)
    
    % calculate the correlation matrix between rhombomeres for each embryo
    % separately
    msk = strcmp(data.Embryo, embryo_ids{embryo_idx});
    [corr_matrix, ps] = corr([cell2mat(data.R3(msk)) ...
        cell2mat(data.R4(msk)) cell2mat(data.R5(msk))], ...
        'type', 'Spearman');
    
    % plot the correlation matrix on a colormap
    hax = subplot(2, 3, embryo_idx);
    imagesc(corr_matrix);
    set(hax, 'CLim', [-1 1]);
    axis equal tight;
    
    % deal with axis ticks and labels
%     title(embryo_ids{embryo_idx});
    set(hax, 'XTick', [1 2 3], ...
        'YTick', [1 2 3]);
    set(hax, 'XTickLabel', {'R3', 'R4', 'R5'}, ...
        'YTickLabel', {'R3', 'R4', 'R5'});
    set(hax, 'FontSize', 14');
    
    % deal with colormap
    cm = [[ones(128,1); linspace(1,0,128)']  ...
        [linspace(0,1,128)'; ones(128,1)] ...
        [linspace(0,1,128)'; linspace(1,0,128)']];
    colormap(cm);
    
    % deal with cross-terms
    ad = 1 - eye(3);
    set(get(hax, 'Children'), 'AlphaData', ad);
    set(hax, 'Color', [0.9 0.9 0.9]);
    
    hl1 = line([0.5 3.5], [0.5 3.5], 'Color', 'w');
    hl2 = line([1.5 0.5], [0.5 1.5], 'Color', 'w');
    hl3 = line([2.5 1.5], [1.5 2.5], 'Color', 'w');
    hl4 = line([3.5 2.5], [2.5 3.5], 'Color', 'w');
    
    % add p value labels
    for xidx = 1:3
        for yidx = 1:3
            if xidx ~= yidx
                fs = 18;
                if ps(yidx, xidx) > .05
                    plbl = 'ns';
                    fs = 12;
                elseif  ( (ps(yidx, xidx) <= 0.05) && (ps(yidx, xidx) > 0.01) )
                    plbl = '*';
                elseif ( (ps(yidx, xidx) <= 0.01) && (ps(yidx, xidx) > 0.001) )
                    plbl = '**';
                elseif ( (ps(yidx, xidx) <= 0.001) && (ps(yidx, xidx) > 0.0001) )
                    plbl = '***';
                elseif ( (ps(yidx, xidx) <= 0.0001) )
                    plbl = '****';
                end
                txth = [txth; text(xidx, yidx, plbl, ...
                    'HorizontalAlignment', 'center', ...
                    'VerticalAlignment', 'middle', ...
                    'FontSize', fs)];
            end
        end
    end
    
    set(hax, 'Units', 'normalized');
    ax_pos = [ax_pos; get(hax, 'Position')];
    
end
    
% deal with colorbar
cb = colorbar;
cbw = (1 - max(ax_pos(:,1) + ax_pos(1,3)))/4;
cbx = ( max(ax_pos(:,1) + ax_pos(1,3))) + cbw/2;
cby = min(ax_pos(:, 2));
cbh = max(ax_pos(:,2) + ax_pos(1,4)) - cby;
set(cb, 'Position', [ cbx cby cbw cbh]);
ylabel(cb, 'Spearman''s correlation coefficient', 'FontSize', 14);
set(cb, 'FontSize', 14);



