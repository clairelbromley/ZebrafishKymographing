% Script to add Rhombomere number from updated metadata to pooled data
% output.
% Make into a function with no arguments so we can easily boilerplate
% stringutil from viewerMain

function addRhombomeresScript()

newMetadataPath = 'C:\Users\d.kelly\Downloads\metadata July16 +rhombomeres.xlsx';
pooledDataPath = 'C:\Users\d.kelly\Downloads\POOLED (2).xls';
pooledDataOutPath = 'C:\Users\d.kelly\Downloads\POOLED +rhombomeres.xls';

%% Get metadata
metadata = getExperimentMetadata(newMetadataPath);
rhombomeres = {metadata.rhombomere};
%% For each sheet in the pooled data, use ID to find appropriate row in the
% metadata structure from which to pull rhombomere info
[~, shts] = xlsfinfo(pooledDataPath);

for shind = 1:length(shts)
    
    if ~strcmp(shts{shind}, 'QC summary')
        [~,~,data] =  xlsread(pooledDataPath, shts{shind});
        dates = convertToStringUtil({data(2:end,strcmp(data(1,:), 'date'))});
        embryoNumbers = convertToStringUtil({data(2:end,strcmp(data(1,:), 'embryoNumber'))});
        cutNumbers = data(2:end,strcmp(data(1,:), 'cutNumber'));
    %     dRhombomeres{1} = 'rhombomere';

        for dind = 1:length(cutNumbers)

            cnMask = ([metadata.cutNumber] == cutNumbers{dind});
            enMask = strcmp({metadata.embryoNumber}, embryoNumbers{dind});
            dtMask = strcmp({metadata.date}, dates{dind});
            tMask = cnMask & enMask & dtMask;
            if sum(tMask) > 0
                dRhombomeres{dind} = rhombomeres{tMask}; 
            end

        end

        % extract rhombomere number as a double from previous (2015) metadata,
        % which is in format "R#" or "r#"
        rt = data(2:end, strcmp(data(1,:), 'rhombomere'));
        for rind = 1:length(rt)
            if strcmp(rt{rind}, 'NaN')
                rt{rind} = dRhombomeres{rind};
            else
                if ischar(rt{rind})
                    rt{rind} = str2double(rt{rind}(2));
                end
            end
        end
        data(2:end, strcmp(data(1,:), 'rhombomere')) = rt;

        xlswrite(pooledDataOutPath, data, shts{shind});
    end
    
end

function outVar = convertToStringUtil(inVar)

if isnumeric(inVar{1}{1})
    outVar = cellfun(@num2str, inVar{1}, 'UniformOutput', false);
else
    outVar = inVar;
end
