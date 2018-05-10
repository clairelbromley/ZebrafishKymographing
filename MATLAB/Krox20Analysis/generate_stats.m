function output_struct = generate_stats(output_struct, input_var_name, stat_type, rhombomeres, indata)
% take string determining variable name, cell array of strings of
% statistical functions to evaluate and cell array of rhombomere labels, e.g.
% midline_defn = generate_stats_struct('midline_defn', {'mean', 'median'},
% ... {3 4 5])

    if isempty(output_struct)
        output_struct = struct();
    end

    for stidx = 1:length(stat_type)
        
        for rhidx = 1:length(rhombomeres)
            
            if strcmp(rhombomeres{rhidx}, 'AllRh')
                rhlbl = 'AllRh';
            else
                rhlbl = ['Rh' num2str(rhombomeres{rhidx})];
            end
            
            statstr = stat_type{stidx};
            if length(statstr) > 3
                if strcmp(statstr(1:3), 'nan')
                    statstr = statstr(4:end);
                end
            end
            
            output_struct.(rhlbl).([input_var_name '_' statstr]) = feval(stat_type{stidx}, indata(~isinf(indata)));
            
        end
        
    end
 
end