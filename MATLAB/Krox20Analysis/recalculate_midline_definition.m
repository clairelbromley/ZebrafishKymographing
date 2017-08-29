function edges = recalculate_midline_definition(data, edges, saved_midline_location)

    rhs = [4, 5, 6];

    for edgidx = 1:length(edges)
        edge = edges(edgidx);
        
        if ~isempty(edge.M)
            fldr = [saved_midline_location filesep sprintf('z = %0.2f um', edges(1).z)]; 
            midline_col = imread([fldr filesep sprintf('midline definition - midline pixels, t = %0.2f.tif', edge.timepoint)]);
            denominator_col = imread([fldr filesep sprintf('midline definition - background pixels, t = %0.2f.tif', edge.timepoint)]);

            if all(edge.edgeValidity(3, :))
                if strcmp(data.midline_definition_method, 'max')
                    midline_definition_array = double(max(midline_col, [], 2)) ./  double(mean(denominator_col, 2));
                else
                    midline_definition_array = double(mean(midline_col, 2)) ./  double(mean(denominator_col, 2));
                end
                edges(edgidx).midlineDefinition.AllRh.mean_midline_def = mean(midline_definition_array);
                edges(edgidx).midlineDefinition.AllRh.median_midline_def = median(midline_definition_array);
                edges(edgidx).midlineDefinition.AllRh.std_midline_def = std(midline_definition_array);
                edges(edgidx).midlineDefinition.AllRh.min_midline_def = min(midline_definition_array);
                edges(edgidx).midlineDefinition.AllRh.max_midline_def = max(midline_definition_array);
            end

            for rh = rhs
                if edge.edgeValidity(3, rh-min(rhs)+1)
                    temp_m = midline_definition_array((edge.rhombomereLimits(rh-min(rhs)+1) - min(edge.rhombomereLimits) + 1):...
                        (edge.rhombomereLimits(rh-min(rhs)+2) - min(edge.rhombomereLimits) + 1));
                    edges(edgidx).midlineDefinition.(['Rh' num2str(rh)]).mean_midline_def = mean(temp_m);
                    edges(edgidx).midlineDefinition.(['Rh' num2str(rh)]).median_midline_def = median(temp_m);
                    edges(edgidx).midlineDefinition.(['Rh' num2str(rh)]).std_midline_def = std(temp_m);
                    edges(edgidx).midlineDefinition.(['Rh' num2str(rh)]).min_midline_def = min(temp_m);
                    edges(edgidx).midlineDefinition.(['Rh' num2str(rh)]).max_midline_def = max(temp_m);
                end
            end
        end
    end
end