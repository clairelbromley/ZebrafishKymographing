function out_data = check_if_lr_interface_length_conserved(data_file_path, images_path, start_hpf)

    load(data_file_path);
    out_data = [];
    [~, data.timestamps] = order_files(images_path);

    for eidx =  unique([data.edges.timepoint])

        fprintf('Processing timepoint %d of %d\n\r', eidx, max([data.edges.timepoint]));
        edges = data.edges([data.edges.timepoint] == eidx);
        data.czi_reader = bfGetReader([images_path filesep data.files(eidx).name]);
        data.ome_meta = data.czi_reader.getMetadataStore();
        for z = [edges.z]
            edge = edges([edges.z] == z);
            [ios, manual_length] = calc_sinuosity_index(data, edge);
            if (edge.timestamp ~= 0)
                out_data = [out_data; [z, start_hpf + edge.timestamp/60, manual_length, ios]];
            else
                out_data = [out_data; [z, start_hpf + data.timestamps(edge.timepoint)/60, manual_length, ios]];
            end
        end
    end
    
    hdr = {'hpf', 'LR interface length, microns', 'Index of straightness'};
    
    [p, ~, ~] = fileparts(data_file_path);
   for z = [35 40 45]
       oodata  = [hdr; num2cell(out_data((out_data(:,1) == z), 2:4))];
       xlswrite([p filesep 'isLRInterfaceLengthConserved.xlsx'], ...
           oodata, ...
           num2str(z));
   end
end   