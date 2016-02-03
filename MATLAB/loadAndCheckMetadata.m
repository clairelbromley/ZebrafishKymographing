function [outmd, outuO, redoPreprocess] = loadAndCheckMetadata(cutPath, inuO, inmd, check)

    redoPreprocess = false;
    outuO = [];
    
    cutDataPath = [cutPath filesep sprintf('trimmed_cutinfo_cut_%d.txt', inmd.cutNumber)];
    fid = fopen(cutDataPath, 'r');
    c = textscan(fid, '%s', 'delimiter', '\r\n');
    c = c{1};
    iE = cellfun(@isempty, c);
    c(iE) = [];
    
    fields = cell(length(c), 1);
    data = cell(length(c), 1);
    fnames = cell(length(c), 1);
    
    for ind = 1:length(c)
       temp = regexp(c{ind}, '\t', 'split');
       fields{ind} = regexp(temp{1}, '\.', 'split');
       fnames{ind} = fields{ind}{end};
       fields{ind}(end)=[];
       data{ind} = temp(2:end);
    end
    
    inmd
    outmd = readInStruct(fields, fnames, data, 'metadata', inmd)
    inuO
    outuO = readInStruct(fields, fnames, data, 'userOptions', inuO)
    
    if check
        if ~compareStruct(outuO, inuO)
            choice = questdlg('The user options used to generate the saved preprocessed data don''t match the current user options!', ...
                'User options mismatch!', 'Redo preprocess', 'Use saved data anyway', 'Redo preprocess');
            switch choice
                case 'Redo preprocess'
                    redoPreprocess = true;
                    outmd = inmd;
                    outuO = inuO;
                case 'Use saved data anyway'
                    outuO.loadPreprocessedImages = true;
            end
        end
    end
                
            
%     disp(outuO);
    
%     if strcmp(outuO.
%     for ind = 1:length(fields)
%         if strcmp(fields{ind}{1}, 'metadata')
%             if length(fields{ind}) > 1
%                 if isfloat(md.(fields{ind}{2}).(fnames{ind}))
%                     md.(fields{ind}{2}).(fnames{ind}) = cellfun(@str2num, data{ind});
%                 elseif ischar(md.fields{ind}{2}.fnames{ind})
%                     md.(fields{ind}{2}).(fnames{ind}) = data{ind};
%                 end
%             else
%                 if isfloat(md.(fnames{ind}))
%                     md.(fnames{ind}) = cellfun(@str2num, data{ind});
%                 elseif ischar(md.(fields{ind}{2}).(fnames{ind}))
%                     md.(fnames{ind}) = data{ind};
%                 end
%             end
%         end
%     end
                
end

function structOut = readInStruct(fields, fnames, data, structName, structIn)

    for ind = 1:length(fields)
        if strcmp(fields{ind}{1}, structName)
            if length(fields{ind}) > 1
                if isfloat(structIn.(fields{ind}{2}).(fnames{ind}))
                    structOut.(fields{ind}{2}).(fnames{ind}) = cellfun(@str2num, data{ind});
                elseif ischar(structIn.fields{ind}{2}.fnames{ind})
                    structOut.(fields{ind}{2}).(fnames{ind}) = data{ind}{1};
                elseif islogical(structIn.fields{ind}{2}.fnames{ind})
                    structOut.(fields{ind}{2}).(fnames{ind}) = logical(str2double(data{ind}));
                end
            else
                if isfloat(structIn.(fnames{ind}))
                    structOut.(fnames{ind}) = cellfun(@str2num, data{ind});
                elseif ischar(structIn.(fnames{ind}))
                    structOut.(fnames{ind}) = data{ind}{1};
                elseif islogical(structIn.(fnames{ind}))
                    structOut.(fnames{ind}) = logical(str2double(data{ind}));
                end
            end
        end
    end
    
end

function same = compareStruct(struct1, struct2)

    s1 = struct2cell(struct1);
    s2 = struct2cell(struct2);

    y = logical(zeros(1,length(s1)));

    for ind = 1:length(s1)

        w = false;
        if ischar(s1{ind})
            w = strcmp(s1{ind}, s2{ind});
        elseif iscell(s1{ind})
            c1 = char(s1{ind});
            c2 = char(s2{ind});
            w = strcmp(c1, c2);
        else
            w = (s1{ind} == s2{ind});

            if length(w) > 1
                w = (sum(w) > 0);
            end
        end

        y(ind) = ~w;

    end

    same = (sum(y) == 1);

end