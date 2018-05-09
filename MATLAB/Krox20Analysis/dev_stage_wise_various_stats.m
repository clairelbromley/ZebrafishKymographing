% script to generate dev-wise stats for All rhombomeres for given measures
% at different z planes. 
% possible measures based on current output from line drawing:
% NASIndexOfStraightness
% NASLength_um_
% AllRh_Midline_def_mean
% AllRh_MedianDeviationFromGeometricalMidline
% AllRh_MaxDeviationFromGeometricalMidline
% APLengthAllRh_Ap_lengths_median
% APLengthAllRh_Ap_lengths_max
% AllRh_Median_bb_dist
% AllRh_Max_bb_dist

input_stats = {'NASIndexOfStraightness', ...
                'NASLength_um_', ...
                'AllRh_Midline_def_mean', ...
                'AllRh_MedianDeviationFromGeometricalMidline', ...
                'AllRh_MaxDeviationFromGeometricalMidline', ...
                'APLengthAllRh_Ap_lengths_median', ...
                'APLengthAllRh_Ap_lengths_max', ...
                'AllRh_Median_bb_dist', ...
                'AllRh_Max_bb_dist'};
            
z_planes = [35 40 45];            

fldr = uigetdir('C:\Users\Doug\Google Drive\2018-05-09 Exp92 CSVs', ...
                'Choose folder containing results CSVs...');
            
out_folder = uigetdir('C:\Users\Doug\Google Drive\2018-05-09 Exp92 CSVs', ...
                'Choose folder in which to dump output...');
            
data = import_devwise_data(fldr);

embryos = cell(1,length(data.Embryo));
for idx = 1:length(data.Embryo)
    embryos{idx} = sprintf('Exp %d, E%d', data.Experiment(idx), data.Embryo(idx));
end

for z_plane = z_planes
    
    for stat_idx = 1:length(input_stats)
        
        dev_stage_wise_stats(embryos, data, input_headers, z_plane, out_folder)
        
    end
    
end
        