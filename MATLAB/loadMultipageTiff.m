function stack = loadMultipageTiff(input_path)

    info = imfinfo(input_path);
    num_images = numel(info);
    xsize = info(1).Width;
    ysize = info(1).Height;
    stack = zeros(ysize, xsize, num_images);
    for ind = 1:num_images
        stack(:,:,ind) = imread(input_path, ind);
    end

end