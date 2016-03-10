function kymograph_array = getKymographArray(kym_path)

%     try
        h = openfig(kym_paath, 'new', 'invisible');

        fAx = get(h, 'Children');
        dataObjs = get(fAx, 'Children');
        kymograph_array = get(dataObjs(end), 'CData');
        x = get(dataObjs(end), 'XData');
        y = get(dataObjs(end), 'YData');
        close(h);
        
%     catch ME
%         disp(ME);
%     end

end