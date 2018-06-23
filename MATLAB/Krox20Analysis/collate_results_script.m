init_folder = 'D:\Bleb_straightening\exp98_SORT';

root_folder = uigetdir(init_folder, 'Choose root folder...');
out_folder = uigetdir(init_folder, 'Choose output folder...');

embryo_folders = dir([root_folder filesep 'Exp*']);

data = {};

for idx = 1:length(embryo_folders)
    
    ef = embryo_folders(idx).name;
    dfs = dir([root_folder filesep ef filesep '* Ncad Krox Analysis']);
    [~,mxidx]= max([dfs.datenum]);
    results_file_path = [root_folder filesep ef filesep dfs(mxidx).name ...
        filesep 'results.csv'];
    
    [num,~,~] = xlsread(results_file_path);
    num = num2cell(num);
    eid = cell(size(num,1),1);
    eid(:) = {ef};
    num = [eid num];
    data = [data; num];
    
end

xlswrite([out_folder filesep 'collated_data.xls'], data);