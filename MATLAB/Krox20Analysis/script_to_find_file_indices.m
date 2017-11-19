folder = 'D:\KroxNcad files\Exp63\E2';
files = dir([folder filesep '*.czi']);
filenames = {files.name}';

% extract saved file indices from file names
openb  = strfind(filenames, '(');
closeb = strfind(filenames, ')');
fls_with_idx = ~cellfun(@isempty, strfind(filenames, '('));

findices = zeros(length(filenames),1);
for fidx = 1:length(filenames)
    if fls_with_idx(fidx)
        findices(fidx) = str2num(filenames{fidx}((openb{fidx}+1):(closeb{fidx}-1)));
    end
end
