% Script to pool diverse dtaset outputs into a single file for analysis. 
% Deal with possible missing data in some fields for some records, and
% possible changes in naming

%% Check if ispc, since Mac Excel stuff is less predictable
answer = 'Yes';
if ~ispc
    answer = questdlg('Not running under windows - Excel import/export may be unpredictable. Continue?', 'Not a PC!', 'Yes');
    if strcmp(answer, 'Yes')
        msgbox('Quitting...');
        return;
    end
end

%% Choose a folder containing Excel files to pool data from   
basePath = uigetdir('C:\Users\Doug\Google Drive\Pooled dev stage data', 'Choose a folder containing data to be pooled...');

if basePath == 0
    msgbox('No path chosen! Quitting...');
    return;
end

%% Choose output file
outFile = uiputfile('*.xls', 'Choose output Excel file...', [basePath filesep 'out.xls']);

%% Identify XLS files in the folder, and split _userQCd files from regular 
% files

dirs = dir([basePath filesep '*.xl*']);
dirnames = {dirs(:).name};
m = cellfun(@any, regexp(dirnames, 'user QC'));
userQCFiles = dirnames(m);
regularFiles = dirnames(~m);

%% Get outputs from QCd files
[~, shts] = xlsfinfo([basePath filesep userQCFiles{1}]);
iData = {};
for flind = 1:length(userQCFiles)
    
    for shtind = 1:length(shts)
        
        disp(userQCFiles{flind});
        [~,~,dummy] = xlsread([basePath filesep userQCFiles{flind}], shts{shtind});
        iData{flind, shtind} = cell2struct(dummy(2:end, :)', regexprep(dummy(1,:)', '\s', ''), 1);
        
        % rename fields to ensure consistency between metadata editions...
        % startSomiteCount <--> startSsCountTime
        % apicalbehindA <--> cUTTYPE
        if isfield(iData{flind, shtind}, 'startSomiteCount')
            [iData{flind, shtind}.startSsCountTime] = iData{flind, shtind}.startSomiteCount;
            iData{flind, shtind} = rmfield(iData{flind, shtind}, 'startSomiteCount');
        end
        if isfield(iData{flind, shtind}, 'cUTTYPE')
            [iData{flind, shtind}.apicalbehindA] = iData{flind, shtind}.cUTTYPE;
            iData{flind, shtind} = rmfield(iData{flind, shtind}, 'cUTTYPE');
        end

    end

end

%% Collapse internal data structure along first axis to combine, accounting
% for differences in fields...
oData = {};

for shind = 1:size(iData, 2)
    
    clear flds;
    
    for dind = 1:size(iData, 1)
        
        flds = fields(iData{dind, shind});
        
        if isfield(iData{dind, shind}(1), 'date')
            disp(iData{dind, shind}(1).date);
        end
        
        % add fields if necessary...
        if (dind ~= 1)
            for fldind = 1:length(flds)
                if ~isfield(oData{shind}, flds{fldind})
                    % initialise all fields in previous data as empty
                    oData{shind}(size(oData{shind}, 1)).(flds{fldind})  = [];
                end
            end
%             if shind ~= 1
                flds2 = fields(oData{shind});
                for fld2ind = 1:length(flds2)
                    if ~isfield(iData{dind, shind}, flds2(fld2ind))
                        iData{dind, shind}(size(iData{dind, shind}, 1)).(flds2{fld2ind}) = [];
                    end
                end
%             end
        end
        
        if shind > length(oData)
            oData{shind} = iData{dind, shind};
        else
            oData{shind} = [oData{shind}; iData{dind, shind}];
        end
    
    end
    
end
        
%% Export data to excel

for shind = 1:length(oData)
    headerLine = fields(oData{shind})';
    data = [headerLine; struct2cell(oData{shind})'];
    xlswrite(outFile, data, shts{shind});
end
    
    
    disp('done');

% function xxwrite(varargin)
% outName = varargin{1};
% data = varargin{2};
% if ~ispc
%     [pname, fname, ~] = fileparts(outName);
%     outName = [pname filesep fname '.xls'];
%     if nargin == 2
%         xlwrite(outName, data);
%     elseif nargin == 3
%         sht = varargin{3};
%         xlwrite(outName, data, sht);
%     end
% else
%     if nargin ==2
%         xlswrite(outName, data);
%     elseif nargin == 3
%         sht = varargin{3};
%         xlswrite(outName, data, sht);
%     end
% end

    