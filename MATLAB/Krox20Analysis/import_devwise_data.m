function data = import_devwise_data(pth)

    fs = dir([pth filesep '*.csv']);
    data = [];
    hdrs = [];
    
    for fidx = 1:length(fs)
        if (fidx == 1)
            [num, txt, ~] = xlsread([pth filesep fs(fidx).name]);
            hdrs = txt(1,:);
            hdrs = matlab.lang.makeValidName(hdrs);
            hdrs = ['Experiment', 'Embryo', hdrs];
        else
            [num, ~, ~] = xlsread([pth filesep fs(fidx).name]);
        end
        
        temp = textscan(fs(fidx).name, 'Exp%f E%f results.csv');
        experimentID = temp{1};
        embryoID = temp{2};
        num = [repmat(embryoID, size(num,1), 1) num];
        num = [repmat(experimentID, size(num,1), 1) num];
        
        
        for fldidx = 1:length(hdrs)
            if  (fidx == 1)
                data.(hdrs{fldidx}) = num(:,fldidx);
            else
                data.(hdrs{fldidx}) = [data.(hdrs{fldidx}); num(:,fldidx)];
            end
        end
        
    end