function moveApicalCuts()

%     [fname, fpath, ~] = uigetfile('*.xls', 'Choose SORTING FILE');
%     if fname == 0
%        disp('No sorting file chosen');
%        return;
%     else
%         sortingFilePath = [fpath fname];
%     end
%     
%     inputFolder = uigetdir('','Choose INPUT BASE FOLDER');
%     if inputFolder == 0
%        disp('No input folder chosen');
%        return;
%     end
%     
%     apicalCutOutputPath = uigetdir('','Choose OUTPUT BASE FOLDER');
%     if apicalCutOutputPath == 0
%        disp('No output folder chosen');
%        return;
%     end
   
%     answer = questdlg(sprintf('Moving apical files from %s to %s based on information in %s. Continue?', ...
%         inputFolder, apicalCutOutputPath, sortingFilePath));
%     if ~strcmp(answer, 'Yes')
%         return;
%     end
    
    %% debug
    sortingFilePath = '/Users/clairebromley/Google Drive/cutTypeFile.xls'
    apicalCutOutputPath = '/Volumes/Arthur/DATA etc/CUTS/Vienna 1/DATA Vienna 1/Cut data/USE raw SORT/Processed/apical'
    inputFolder = '/Volumes/Arthur/DATA etc/CUTS/Vienna 1/DATA Vienna 1/Cut data/USE raw SORT/Processed/behind apical'
    
    %% Identify apical cuts from xls file
    [~, ~, rawSorting] = xlsread(sortingFilePath);
    apicalMask = strcmp(rawSorting(:, strcmp(rawSorting(1,:), 'Type')), 'apical');
    dates = rawSorting(apicalMask, strcmp(rawSorting(1,:), 'Date'));
    embryoNumbers = rawSorting(apicalMask, strcmp(rawSorting(1,:), 'embryoNumber'));
    cutNumbers = rawSorting(apicalMask, strcmp(rawSorting(1,:), 'cutNumber'));
    
    %% Loop through apical cuts, moving relevant files to relevant subfolders of output folder
    apicalFolder = [apicalCutOutputPath filesep 'ApicalCuts'];
    mkdir(apicalFolder)
    uds = {'downwards' 'upwards'};
    for ind = 1:length(cutNumbers)
       for ud = uds
           folderString = [num2str(dates{ind}) ', Embryo ' num2str(embryoNumbers{ind}) ' ' ud{:}]
           spath = [inputFolder filesep folderString];
           sstring = ['*Cut ' num2str(cutNumbers{ind}) '*'];
           files = dir([spath filesep sstring]);
           if ~isempty(files)
               opath = [apicalFolder filesep folderString];
               mkdir(opath);
           end
           for flind = 1:length(files)
              if isempty(regexp(files(flind).name, 'Overlay', 'once'))
                 movefile([spath filesep files(flind).name], opath) 
              end
           end
           cinf = dir([spath filesep '*cut_' num2str(cutNumbers{ind}) '*']);
           for cinfind = 1:length(cinf)
               movefile([spath filesep cinf(cinfind).name], opath);
           end
               
       end
    end