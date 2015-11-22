function output = kymographBase(root)
% kymographBase takes a directory containing data directories as an
% argument and performs all steps for generation of quantitative kymograph
% data. 

    output.metadata = [];

    % Find all directories in the root directory
    dirs = dir([root filesep '*_*']);
    dirs = dirs([dirs.isdir]);
    
    % Loop through these (tiff-containing) data directories
    for dind = 1:length(dirs)
        
       d = dirs(dind).name;
       % Identify how many cuts were performed on this embryo
       curr_path = [root filesep d];
       num_cuts = length(dir([curr_path filesep '*.txt']))/2;
       
       for cut_ind = 0:num_cuts-1
          
           curr_metadata = getMetadata(curr_path, cut_ind);
           output.metadata = [output.metadata; curr_metadata];
           
       end
        
    end

end