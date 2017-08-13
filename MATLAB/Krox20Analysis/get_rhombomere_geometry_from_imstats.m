function rhombomere_geometry = get_rhombomere_geometry_from_imstats(imstats, data)

    pixel_to_micron = double(data.ome_meta.getPixelsPhysicalSizeX(0).value);
    rhombomere_geometry = RhombomereGeometry();
    imm = imrotate(imstats.ConvexImage, -imstats.Orientation, 'bilinear', 'crop');
    
    dummy_width = sum(imm, 2);
    dummy_width(dummy_width == 0) = [];
    dummy_width(dummy_width < prctile(dummy_width, 10))=[];
    rhombomere_geometry.medianRhombomereWidth = median(dummy_width) * ...
        pixel_to_micron;
    rhombomere_geometry.meanRhombomereWidth = mean(dummy_width) *...
        pixel_to_micron;
    rhombomere_geometry.stdRhombomereWidth = std(dummy_width) *...
        pixel_to_micron;
    
    dummy_length = sum(imm, 1);
    dummy_length(dummy_length == 0) = [];
    dummy_length(dummy_length < prctile(dummy_length, 10))=[];
    rhombomere_geometry.medianRhombomereLength = median(dummy_length) * ...
        pixel_to_micron;
    rhombomere_geometry.meanRhombomereLength = mean(dummy_length) *...
        pixel_to_micron;
    rhombomere_geometry.meanRhombomereLength = std(dummy_length) *...
        pixel_to_micron;

end