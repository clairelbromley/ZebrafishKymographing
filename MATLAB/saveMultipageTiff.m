function saveMultipageTiff(stack, output_path)

    for ind = 1:size(stack, 3)
        if ind == 1
            imwrite(uint16(squeeze(stack(:,:,ind))), output_path);
        else
            imwrite(uint16(squeeze(stack(:,:,ind))), output_path, 'writemode', 'append');
        end
    end

end