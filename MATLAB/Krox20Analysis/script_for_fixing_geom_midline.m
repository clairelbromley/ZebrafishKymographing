function script_for_fixing_geom_midline(basepath)

    dirs = dir([basepath filesep '*Ncad Krox Analysis']);
    
    for dind = 1:length(dirs)
        
        % rename .m to .mat
        ems = dir([basepath filesep dirs(dind).name filesep '*.m']);
        for emsind = 1:length(ems)
            [~, f, e] = fileparts(ems(emsind).name);
            movefile([basepath filesep dirs(dind).name filesep ems(emsind).name], ...
                [basepath filesep dirs(dind).name filesep f '.mat']);
        end
        
        load([basepath filesep dirs(dind).name filesep f '.mat'], 'data');
        
        for timepoint = 1:data.timepoint
            
            
        end
        
    end
    
end