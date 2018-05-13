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
                'AllRh_MedianDeviationFromGeometricalMidline', ...
                'AllRh_MaxDeviationFromGeometricalMidline', ...
                'APLengthAllRh_Ap_lengths_median', ...
                'APLengthAllRh_Ap_lengths_max', ...
                'AllRh_Median_bb_dist', ...
                'AllRh_Max_bb_dist',...
                'AllRh_Midline_def_median', ...
                'AllRh_Midline_def_mean'};
            
z_planes = [35 40 45];            

fldr = uigetdir('C:\Users\Doug\Google Drive\2018-05-09 Exp92 CSVs\Split by treatment', ...
                'Choose folder containing results CSVs...');
            
out_folder = uigetdir('C:\Users\Doug\Google Drive\2018-05-09 Exp92 CSVs\Split by treatment', ...
                'Choose folder in which to dump output...');
            
data = import_devwise_data(fldr);

% z levels/time points that haven't got lines drawn will sometimes have
% non-NaN values for AP length because of automatic Rhombomere detection -
% this will (most likely) be nonsense. Therefore, we should filter here to
% remove any data that has any NaNs at all. Since data is in a structure,
% this is slightly non-trivial...
nanfilt = zeros(length(data.z), length(input_stats));
for idx = 1:length(input_stats)
    nanfilt(:,idx) = isnan(data.(input_stats{idx}));
end
nanfilt = logical(sum(nanfilt, 2));

embryos = cell(1,length(data.Embryo));
for idx = 1:length(data.Embryo)
    embryos{idx} = sprintf('Exp %d, E%d', data.Experiment(idx), data.Embryo(idx));
end

for z_plane = z_planes
    
    for stat_idx = 1:length(input_stats)
        
        input_header = input_stats{stat_idx};
        dev_stage_wise_stats(embryos, data, input_header, z_plane, out_folder, nanfilt)
        
    end
    
end
        