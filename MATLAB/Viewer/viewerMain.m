function varargout = viewerMain(varargin)
% VIEWERMAIN MATLAB code for viewerMain.fig
%      VIEWERMAIN, by itself, creates a new VIEWERMAIN or raises the existing
%      singleton*.
%
%      H = VIEWERMAIN returns the handle to a new VIEWERMAIN or the handle to
%      the existing singleton*.
%
%      VIEWERMAIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VIEWERMAIN.M with the given input arguments.
%
%      VIEWERMAIN('Property','Value',...) creates a new VIEWERMAIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before viewerMain_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to viewerMain_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help viewerMain

% Last Modified by GUIDE v2.5 22-Jan-2017 18:06:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @viewerMain_OpeningFcn, ...
                   'gui_OutputFcn',  @viewerMain_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before viewerMain is made visible.
function viewerMain_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to viewerMain (see VARARGIN)

handles.softwareVersion = 1.0;

% Choose default command line output for viewerMain
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

handles.newMatlab = ~verLessThan('matlab', '8.4.0.150421 (R2014b)');

dummy = [mfilename('fullpath') '.m'];
currdir = fileparts(dummy);
resPath = [currdir filesep 'Resources'];
funcPath = [currdir filesep '..'];
addpath(genpath(currdir));
addpath(funcPath);
addpath(resPath);

javaaddpath([currdir filesep 'Archive' filesep 'jxl.jar']);
javaaddpath([currdir filesep 'Archive' filesep 'MXL.jar']);
javaaddpath([currdir filesep 'jheapcl' filesep 'MatlabGarbageCollector.jar']);
    
set(handles.axUpFirstFrame, 'XTick', []);
set(handles.axDownFirstFrame, 'XTick', []);
set(handles.axUpFirstFrame, 'YTick', []);
set(handles.axDownFirstFrame, 'YTick', []);

xlab = 'Kymograph position along cut, \mum';
ylab = 'Membrane speed, \mum s^{-1}';

xlabel(handles.axUpSpeedVPosition, xlab);
ylabel(handles.axUpSpeedVPosition, ylab);
xlabel(handles.axDownSpeedVPosition, xlab);
ylabel(handles.axDownSpeedVPosition, ylab);

handles.manualSpeeds = [];

handles.linTexpF = true;
set(handles.menuExpFit,'Enable','off');

handles.kymAxisThickness = 1;

handles.includedData = [];
handles.currentLongerSide = [];
handles.meanDifferenceGeometricalActualMidline = [];
handles.sdDifferenceGeometricalActualMidline = [];

handles.laserIcon = imread('laser-icon-12.png');

handles.initTimeStamp = datestr(now);
% search temp directory for temp files older than 7 days, and delete
if ispc
    home = [getenv('HOMEDRIVE') getenv('HOMEPATH')];
else
    home = getenv('HOME');
end
vtemp = [home filesep 'viewerMainTemp'];
handles.tempFilePath = vtemp;
mkdir(vtemp);
files = dir([vtemp filesep '* viewerMainTempVars.mat']);
files = {files.name};
dates = regexp(files, ' viewerMainTempVars.mat', 'split');
dates = [dates{:}];
dates = dates(1:2:end);
dates = strrep(dates, '_', ':');
for ind = 1:length(files)
    if (datenum(dates{ind}) - now) > 7
        delete([vtemp filesep files{ind}])
    end
end

guidata(hObject, handles);

% UIWAIT makes viewerMain wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = viewerMain_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --------------------------------------------------------------------
function menuFile_Callback(hObject, eventdata, handles)
% hObject    handle to menuFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function menuLoadData_Callback(hObject, eventdata, handles)
% hObject    handle to menuLoadData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

default_folder = 'C:\Users\Doug\Documents\DOug- cuts\Processed data 20160314\080316 apical surface distance values\Apical';
if ~isfield(handles, 'baseFolder')
    sf = default_folder;
else
    if ischar(handles.baseFolder)
        sf = handles.baseFolder;
    else
        sf = default_folder;
    end
end

base_folder = uigetdir(sf, 'Choose the base folder to populate the data list...');

if ~isequal(base_folder, 0)
    dataList = cell(0);
    handles.baseFolder = base_folder;

    folders = dir([base_folder filesep '*Embryo*']);
    pattern = ' (down|up)?wards';
    a = regexp({folders.name},pattern, 'split');
    
    for ind = 1:length(a)
        b(ind) = a{ind}(1);
    end
    
    [~,ia,~] = unique(b);
    
    folders = folders(ia);

    for fInd = 1:length(folders)

        s = dir([base_folder filesep folders(fInd).name filesep 'trimmed_cutinfo_cut_*.txt']);

        for cInd = 1:length(s)

            cutNumber = sscanf(s(cInd).name, 'trimmed_cutinfo_cut_%d.txt');
            ex = '(?<date>\d+), Embryo (?<embryoNumber>\w+) (up|down)?wards';
            out = regexp(folders(fInd).name, ex, 'names');

            dataList = [dataList; cellstr(sprintf('Date = %s, Embryo = %s, Cut = %d', ...
                out.date, out.embryoNumber, cutNumber))];

        end

    end

    exps = dir([base_folder filesep folders(1).name filesep '*exponential*']);
    if ~isempty(exps)
        set(handles.menuExpFit,'Enable','on');
    end
    
    set(handles.listData, 'String', dataList);
    handles.damagedSideList = cell(numel(get(handles.listData, 'String')),1);

    guidata(hObject, handles);
    
    %% Fire metadata load event
    if ~isempty(dataList)
        callback = get(handles.menuLoadMetadata, 'Callback');
        callback(handles.listData, []);
    end
    
    %% Fire selection event for first item in list
    if ~isempty(dataList)
        set(handles.listData, 'Value', 1);
        callback = get(handles.listData, 'Callback');
        callback(handles.listData, []);
    end
end

% guidata(hObject, handles);
        
% --- Executes on selection change in listData.
function listData_Callback(hObject, eventdata, handles)
% hObject    handle to listData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


cla(handles.axUpSpeedVPosition, 'reset');
cla(handles.axDownSpeedVPosition, 'reset');

showDamageIcon(handles.damagedSideList{get(handles.listData, 'Value')}, handles);  
handles.currentDamageSide = handles.damagedSideList{get(handles.listData, 'Value')};
% if strcmp(, 'up'


if isfield(handles, 'manualLine')
    if ~isempty(handles.manualLine)
        delete(handles.manualLine);
    end
end

contents = cellstr(get(hObject,'String')); % returns listData contents as cell array
selected = contents{get(hObject,'Value')}; % returns selected item from listData
disp(selected);
%% start busy
busyOutput = busyDlg();
set(handles.listData, 'Enable', 'off');
butDownFcn = {@axUpSpeedVPosition_ButtonDownFcn, handles};
butDownFcns = repmat(butDownFcn, 1, 4);
disableEnableOnClick([handles.axDownSpeedVPosition; handles.axUpSpeedVPosition]);


%% Get and plot speed vs position
ex = 'Date = (?<date>\w+), Embryo = (?<embryoNumber>\w+), Cut = (?<cutNumber>\d+)';
s = regexp(selected, ex, 'names');
dt = s.date;
embryoNumber = s.embryoNumber;
cutNumber = s.cutNumber;

% FORCE LINEAR ALWAYS:
handles.linTexpF = true;
if handles.linTexpF
    expTxt = '';
    expTxt2 = ', S';
else
    expTxt = ' exponential fit';
    expTxt2 = ', exponential s';
end

handles.date = dt;
handles.cutNumber = cutNumber;
handles.embryoNumber = embryoNumber;

axHandles = [handles.axUpSpeedVPosition; handles.axDownSpeedVPosition]; 
titleAppendices = {['upwards' expTxt]; ['downwards' expTxt]};

baseFolder2 = [handles.baseFolder filesep handles.date ', Embryo ' handles.embryoNumber];
folder = [baseFolder2 ' downwards'];
mdfpath = [folder filesep 'trimmed_cutinfo_cut_' handles.cutNumber '.txt'];
handles.positionsAlongLine = getKymPosMetadataFromText(mdfpath);    
fractional_pos_along_cut = getNumericMetadataFromText(mdfpath, 'metadata.kym_region.fraction_along_cut');
distance_from_edge = getNumericMetadataFromText(mdfpath, 'metadata.kym_region.distance_from_edge');
handles.plotHandles = num2cell(axHandles);
handles.timeBeforeCut = getNumericMetadataFromText(mdfpath, 'userOptions.timeBeforeCut');
handles.timeAfterCut = getNumericMetadataFromText(mdfpath, 'userOptions.timeAfterCut');
handles.frameTime = getNumericMetadataFromText(mdfpath, 'metadata.acqMetadata.cycleTime');
handles.umPerPixel = getNumericMetadataFromText(mdfpath, 'metadata.umperpixel');
handles.quantAnalysisTime = getNumericMetadataFromText(mdfpath, 'userOptions.quantAnalysisTime');
x1 = getNumericMetadataFromText(mdfpath, 'metadata.cutMetadata.startPositionX');
x2 = getNumericMetadataFromText(mdfpath, 'metadata.cutMetadata.stopPositionX');
y1 = getNumericMetadataFromText(mdfpath, 'metadata.cutMetadata.startPositionY');
y2 = getNumericMetadataFromText(mdfpath, 'metadata.cutMetadata.stopPositionY');
handles.currentCutLength = sqrt( (x1 - x2)^2 + (y1 - y2)^2 ) * handles.umPerPixel;
handles.currentCutDuration = getNumericMetadataFromText(mdfpath, 'metadata.cutMetadata.time');
handles.qcColor = cell(2,1);
handles.qcScatter = cell(2,1);
handles.poss = cell(2,1);
handles.speeds = cell(2,1);

% buttonDownFcns = {{@axUpSpeedVPosition_ButtonDownFcn, handles};...
%     {@axDownSpeedVPosition_ButtonDownFcn, handles}};

for ind = 1:length(axHandles)
    try

        figFilePaths = [cellstr([handles.baseFolder filesep dt ', Embryo ' embryoNumber ' upwards' filesep dt ', Embryo ' embryoNumber ', Cut ' cutNumber expTxt2 'peed against cut position upwards' expTxt '.fig']);...
            cellstr([handles.baseFolder filesep dt ', Embryo ' embryoNumber ' downwards' filesep dt ', Embryo ' embryoNumber ', Cut ' cutNumber expTxt2 'peed against cut position downwards' expTxt '.fig'])];

        if axHandles(ind) == handles.axUpSpeedVPosition
            direction = 'up';
        else
            direction = 'down';
        end
            

        axHandles = [handles.axUpSpeedVPosition; handles.axDownSpeedVPosition]; 
    
        fpath = figFilePaths{ind};
        
        h = openfig(fpath, 'new', 'invisible');
        ax = get(h, 'Children');
        dataObjs = get(ax, 'Children');
        handles.speeds{ind} = get(dataObjs, 'YData');
        handles.poss{ind} = get(dataObjs, 'XData');
%         hold(axHandles(ind), 'on');
        handles.qcColor{ind} = 0.95 * ones(length(handles.poss{ind}), 3);   % put scatter in place to be modified once qc data dealt with
%         handles.qcColor{ind}(:,2:3) = 0; % DEBUG
        handles.qcScatter{ind} = myScatter(handles.poss{ind}, handles.speeds{ind}, 200, handles.qcColor{ind}, axHandles(ind));
        hold(axHandles(ind), 'on');
        handles.plotHandles{ind} = plot(axHandles(ind), handles.poss{ind}, handles.speeds{ind}, 'x-');
        hold(axHandles(ind), 'off');
        xlab = 'Kymograph position along cut, \mum';
        ylab = 'Membrane speed, \mum s^{-1}';
        xlabel(axHandles(ind), xlab);
        ylabel(axHandles(ind), ylab);
        title(axHandles(ind), sprintf('%s, Embryo %s, Cut %s, %s', dt, embryoNumber, cutNumber, titleAppendices{ind}));

                
    catch ME

        disp(ME)
    %     uiwait(msgbox(['No figure to load at ' fpath]));   
        axHandles = [handles.axUpSpeedVPosition; handles.axDownSpeedVPosition]; 
    %     handles.plotHandles{ind} = plot(handles.positionsAlongLine, zeros(1,length(handles.positionsAlongLine)),'Parent',axHandles(ind), 'Marker', 'x', 'Color', [0.8 0.8 0.8], ...
    %         'MarkerEdgeColor', [0.8 0.8 0.8]);
        ds = {'up' 'down'};
        for i = 1:length(handles.positionsAlongLine)
            handles.currentPosition = handles.positionsAlongLine(i);
            handles.poss{ind} = [];
            handles.currentFractionalPosition = fractional_pos_along_cut(round(100*handles.positionsAlongLine)/100 ...
                            == round(100*handles.currentPosition)/100);
            handles.currentDistanceFromEdge = distance_from_edge(round(100*handles.positionsAlongLine)/100 ...
                == round(100*handles.currentPosition)/100);
            handles.currentSpeed = 0;
            handles.currentBlockedFrames = nan;
            handles.edgeSide = '';
            handles.currentApicalSurfaceToCutDistance = nan;
            genericInclude(handles, 'no edge', ds{ind}, handles.positionsAlongLine(i));
        end
    end
end
        %% Get and plot first frames and relevant lines
try
        figFilePaths = [cellstr([handles.baseFolder filesep dt ', Embryo ' embryoNumber ' upwards' filesep dt ', Embryo ' embryoNumber ', Cut ' cutNumber ', * s pre-cut upwards.fig']);...
            cellstr([handles.baseFolder filesep dt ', Embryo ' embryoNumber ' downwards' filesep dt ', Embryo ' embryoNumber ', Cut ' cutNumber ', * s pre-cut downwards.fig'])];

        dummyPaths = {};
        for figFilePath = figFilePaths'
            dirs = dir(figFilePath{1});
            [basepath, ~, ~] = fileparts(figFilePath{1});
            dummyPaths = [dummyPaths; [basepath filesep dirs.name]];
        end
        figFilePaths = dummyPaths;
            
        
        axHandles = [handles.axUpFirstFrame; handles.axDownFirstFrame];
        handles.kymLines = [];

        for ind = 1:length(axHandles)

            fpath = figFilePaths{ind};

            h = openfig(fpath, 'new', 'invisible');
            ax = get(h, 'Children');
            dataObjs = get(ax, 'Children');
            im = get(dataObjs(end), 'CData');

            imH = imagesc(im, 'Parent', axHandles(ind));
            colormap(axHandles(ind), gray)

            set(axHandles(ind), 'XTick', []);
            set(axHandles(ind), 'YTick', []);

            %% scale bar...
            sc_line_x = get(dataObjs(2), 'XData');
            sc_line_y = get(dataObjs(2), 'YData');
            line(sc_line_x, sc_line_y, 'Parent', axHandles(ind), 'Color', 'w', ...
                'LineWidth', 3);
            handles.umPerPixel = 20/diff(sc_line_x); %  ASSUMES SCALE BAR IS ALWAYS 20!

            %% cut line...
            cut_line_x = get(dataObjs(end-1), 'XData');
            cut_line_y = get(dataObjs(end-1), 'YData');
            handles.cut_line_x = cut_line_x;
            handles.cut_line_y = cut_line_y;
            line(cut_line_x, cut_line_y, 'Parent', axHandles(ind), 'Color', 'b', ...
                'LineWidth', 2);

            %% kymograph lines...   
            kym_lines = zeros(1,length(dataObjs)-4);
            x = [kym_lines; kym_lines];
            y = x;
            for lInd = 3:(length(dataObjs)-2)
        %         for lInd = 3:(length(dataObjs)-2)
                x(:,lInd-2) = get(dataObjs(lInd), 'XData')';
                y(:,lInd-2) = get(dataObjs(lInd), 'YData')';
                kym_lines(lInd-2) = line(get(dataObjs(lInd), 'XData'), get(dataObjs(lInd), 'YData'), ...
                    'Parent', axHandles(ind), 'Color', 'r', 'LineStyle', '--', 'LineWidth', 2);
            end


            offset = handles.umPerPixel * sqrt((x(1,1) - cut_line_x(1))^2 + (y(1,1) - cut_line_y(1))^2);
            handles.positionsAlongLine = (-handles.umPerPixel * sqrt((x(1,end) - x(1,:)).^2 + (y(1,end) - y(1,:)).^2) + offset);
            baseFolder2 = [handles.baseFolder filesep handles.date ', Embryo ' handles.embryoNumber];
            folder = [baseFolder2 ' downwards'];
            mdfpath = [folder filesep 'trimmed_cutinfo_cut_' handles.cutNumber '.txt'];
            handles.positionsAlongLine = getKymPosMetadataFromText(mdfpath);    
            handles.zoomBoxLTBR(ind,:) = [min(x(:)) min(y(:)) max(x(:)) max(y(:))];

        %     %% find which attempted kymograph lines are represented in results
        %     plotPos = round(100*handles.poss{ind})/100;
        %     drawnPos = round(100*handles.positionsAlongLine)/100;
        %     [~,~,included] = intersect(plotPos, drawnPos);
        %     toRemove = 1:length(kym_lines);
        %     toRemove(included)=[];
        %     delete(kym_lines(toRemove));

            handles.kymLines(ind,:) = fliplr(kym_lines);

            set(imH, 'UIContextMenu', handles.menuPreCutFig);
            set(handles.menuZoomToggle, 'Checked', 'off')
%             catch
%                 msgbox(['No figure to load at ' fpath]);
%             end
        end
catch ME
    disp(ME)
    for eind = 1:length(ME.stack)
        disp(ME.stack(eind).name);
        disp(ME.stack(eind).line);
    end
    uiwait(msgbox(['No figure to load at ' fpath]));   
    axHandles = [handles.axUpFirstFrame; handles.axDownFirstFrame];
    imagesc(zeros(5),'Parent',axHandles(ind));

end
    
% Load distance from apical surface for current cut
fname = [handles.baseFolder filesep dt ', Embryo ' embryoNumber ' downwards' filesep ...
    'trimmed_cutinfo_cut_' cutNumber '.txt' ];
varn = 'metadata.distanceToApicalSurface';
try
    handles.currentApicalSurfaceToCutDistance = getNumericMetadataFromText(fname, varn);
catch
    handles.currentApicalSurfaceToCutDistance = NaN;
end

        % IF DATA NOT ALREADY PRESENT, populate includedData with all
        % kymograph positions and label with 'not QCd' or 'no edge'
        % Loop through positions detailed in handles.positionsAlongLine
        % check for each whether kymograph edge exists and whether it
        % exists in includedData
        % Add to included data if necessary
        
try       
        directions = {'up' 'down'};
%         if ~isempty(handles.includedData)
            for direction = directions
                ind = find(strcmp(direction, directions)); % untidy, but never mind - saves rewriting...
                baseFolder2 = [handles.baseFolder filesep handles.date ', Embryo ' handles.embryoNumber];
                folder = [baseFolder2 ' ' direction{1} 'wards'];
                filepath = [folder filesep 'trimmed_cutinfo_cut_' handles.cutNumber '.txt'];
                fractional_pos_along_cut = getNumericMetadataFromText(filepath, 'metadata.kym_region.fraction_along_cut');
                distance_from_edge = getNumericMetadataFromText(filepath, 'metadata.kym_region.distance_from_edge');
               
                for pos = handles.positionsAlongLine
                    handles.currentPosition = pos;
                    handles.currentSpeed = nan;
                    handles.currentFractionalPosition = fractional_pos_along_cut(round(100*handles.positionsAlongLine)/100 ...
                        == round(100*handles.currentPosition)/100);
                    handles.currentDistanceFromEdge = distance_from_edge(round(100*handles.positionsAlongLine)/100 ...
                        == round(100*handles.currentPosition)/100);
                    handles.edgeSide = '';
                    handles.currentBlockedFrames = nan;
                    
                   if (sum(checkIfStored(handles, direction{1}, pos)) == 0)
                       % was edge found, i.e. is relevant x position in the
                       % speed v position plot?
                       if isempty(handles.poss)
                           qcLabel = 'no edge';
                           handles = genericInclude(handles, qcLabel, direction{1}, pos);
                       else
                           if iscell(handles.poss)
                               if ((sum(round(100*handles.poss{strcmp(directions, direction{1})})/100 == round(100*pos)/100) > 0))  % nonsense
                                   qcLabel = 'not QCd';
                                   handles = genericInclude(handles, qcLabel, direction{1}, pos);
                               else
                                   qcLabel = 'no edge';
                                   handles = genericInclude(handles, qcLabel, direction{1}, pos);
                               end
                           else
                               qcLabel = 'no edge';
                               handles = genericInclude(handles, qcLabel, direction{1}, pos);
                           end
                       end
                   end
                end

                handles.qcColor{ind} = generateQCColorArray(handles, handles.qcColor{ind}, direction);
                updateMyScatterColors(handles.qcScatter{ind}, handles.qcColor{ind});
            
            end
            
%         end
        
catch ME
    disp(ME)
    for eind = 1:length(ME.stack)
        disp(ME.stack(eind).name);
        disp(ME.stack(eind).line);
    end
    uiwait(msgbox('Error parsing metadata to include data structure!'));   
    imagesc(zeros(5),'Parent',axHandles(ind));

end

%% end busy
busyDlg(busyOutput);
tempHand = [handles.axDownSpeedVPosition; handles.axUpSpeedVPosition];
for ind = 1:length(handles.plotHandles)
    tempHand = [tempHand; handles.plotHandles{ind}];
end

disableEnableOnClick(tempHand, butDownFcns);

set(handles.listData, 'Enable', 'on');
close(h);

cla(handles.axUpSelectedKym, 'reset');
cla(handles.axDownSelectedKym, 'reset');

% TODO: add function, broken out from callback, to allow checking whether
% data has already been added to the list to be exported - upon this, we
% can base the coloring of the title and the checked state in the UI menu. 
set(handles.menuInclude, 'checked', 'off');
% 
figs = findobj('Type', 'figure');
figs(figs == handles.figure1) = []; % delete your current figure from the list
close(figs)

% no kymograph is selcted at this point...
handles.currentKymInd = [];

saveTempVars(handles);
memoryTest();
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function listData_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function menuZoomToggle_Callback(hObject, eventdata, handles)
% hObject    handle to menuZoomToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% ax = gca;
axHandles = [handles.axUpFirstFrame; handles.axDownFirstFrame];
if strcmp(get(handles.menuZoomToggle, 'Checked'), 'on')
    zoomState = true;
    set(handles.menuZoomToggle, 'Checked', 'off')
else
    zoomState = false;
    set(handles.menuZoomToggle, 'Checked', 'on')
end

for ind = 1:length(axHandles)
    
    zBox = handles.zoomBoxLTBR(ind,:);
    ax = axHandles(ind);
    kym_lines = (handles.kymLines(ind,:));
    
    if zoomState
        set(ax, 'XLim', [0 512]);
        set(ax, 'YLim', [0 512]);

        delete(handles.pos_txt(:,ind));

    else
        set(ax, 'XLim', [zBox(1) zBox(3)]);
        set(ax, 'YLim', [zBox(2) zBox(4)]);
        
        tposx = get(kym_lines, 'XData');
        tposy = get(kym_lines, 'YData');
        for kpos = 1:length(kym_lines)
            handles.pos_txt(kpos,ind) = text(tposx{kpos}(1), tposy{kpos}(1), ...
                sprintf('%0.2f', handles.positionsAlongLine(kpos)),...
                'Parent', axHandles(ind), 'FontSize', 8);
            set(handles.pos_txt(kpos, ind), 'Color', 'r');
        end
    end
    
end

guidata(hObject, handles);


% --------------------------------------------------------------------
function menuPreCutFig_Callback(hObject, eventdata, handles)
% hObject    handle to menuPreCutFig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on mouse press over axes background.
function axUpSpeedVPosition_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axUpSpeedVPosition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
handles = guidata(gcf);

if gca == handles.axUpSpeedVPosition
    ax = 1;
    appendText = ' upwards';
    kym_ax = handles.axUpSelectedKym;
    direction = 'up';
    handles.currentDir = 'up';
else
    ax = 2;
    appendText = ' downwards';
    kym_ax = handles.axDownSelectedKym;
    direction = 'down';
    handles.currentDir = 'down';
end

a = get(gca, 'CurrentPoint');
xpos = a(1,1);
x = abs(handles.poss{ax} - xpos);

closest = find(x == min(x));

handles = move_selected_point(closest);
guidata(hObject, handles);

function handles = move_selected_point(closest)

handles = guidata(gcf);
set(handles.listData, 'Enable', 'on');
busyOutput = busyDlg();
set(handles.listData, 'Enable', 'off');
baseFolder2 = [handles.baseFolder filesep handles.date ', Embryo ' handles.embryoNumber];

if gca == handles.axUpSpeedVPosition
    ax = 1;
    appendText = ' upwards';
    kym_ax = handles.axUpSelectedKym;
    direction = 'up';
    handles.currentDir = 'up';
else
    ax = 2;
    appendText = ' downwards';
    kym_ax = handles.axDownSelectedKym;
    direction = 'down';
    handles.currentDir = 'down';
end

folder = [baseFolder2 appendText];

if handles.newMatlab
    h = findobj('Parent', gca, '-not', 'Type', 'Scatter');
else
    h = findobj('Parent', gca, '-not', 'Type', 'hggroup');
end
    
for ind = 1:length(h)
    if (get(h(ind), 'Color') == [1 0 0])
        delete(h(ind));
    end
end    

hold on
plot(handles.poss{ax}(closest), handles.speeds{ax}(closest), 'o', 'Color', 'r');
hold off

[~, closest_kymline] = min(abs(handles.positionsAlongLine - handles.poss{ax}(closest)));

for kymInd = 1:length(handles.kymLines(ax,:))
    if kymInd == closest_kymline
        set(handles.kymLines(ax, closest_kymline), 'Color', 'g');
    else
        set(handles.kymLines(ax, kymInd), 'Color', 'r');
    end
end


%% Get relevant kymograph file and plot
filepath = [folder filesep 'trimmed_cutinfo_cut_' handles.cutNumber '.txt'];
pos_along_cut = getKymPosMetadataFromText(filepath);
fractional_pos_along_cut = getNumericMetadataFromText(filepath, 'metadata.kym_region.fraction_along_cut');
distance_from_edge = getNumericMetadataFromText(filepath, 'metadata.kym_region.distance_from_edge');
kym_ind = find((round(100*pos_along_cut)/100) == (round(100*handles.poss{ax}(closest))/100)) - 2;
handles.currentKymInd = kym_ind;

fpath = [folder filesep handles.date ', Embryo ' handles.embryoNumber ...
    ', Cut ' handles.cutNumber ', Kymograph index along cut = ' num2str(kym_ind)...
    appendText '.fig'];
try
    h = openfig(fpath, 'new', 'invisible');

    fAx = get(h, 'Children');
    dataObjs = get(fAx, 'Children');
    im = get(dataObjs(end), 'CData');
    x = get(dataObjs(end), 'XData');
    y = get(dataObjs(end), 'YData');

    % imH = imagesc(x, y, im, 'Parent', kym_ax);
    hold(kym_ax, 'on');
    RI = imref2d(size(im));
    RI.XWorldLimits = [min(x) max(x)];
    RI.YWorldLimits = [min(y) max(y)];
    bg = zeros(size(im));
    cmap = gray;
    cmap(1,:) = [0 1 1];
    colBg = ind2rgb(bg, cmap);
    % hold off;
    handles.kymIm(ax) = imshow(im, RI, [min(im(:)) max(im(:))], 'Parent', kym_ax);
    axis tight;
    handles.kymData(ax,:,:) = im;
    xlabel(kym_ax, 'Time relative to cut, s')
    ylabel(kym_ax, 'Position relative to cut, \mum')
    

    title_txt = [handles.date ' Embryo ' handles.embryoNumber ', Cut ' handles.cutNumber...
        ',' appendText ', kymograph position along cut: ' sprintf('%0.2f', handles.poss{ax}(closest)) ' \mum'];
    handles.kymTitle{ax} = title(kym_ax, title_txt);

    handles.currentPosition = round(100*handles.poss{ax}(closest))/100;
    handles.currentSpeed = handles.speeds{ax}(closest);
    handles.currentFractionalPosition = fractional_pos_along_cut(round(100*pos_along_cut)/100 ...
        == round(100*handles.currentPosition)/100);
    handles.currentDistanceFromEdge = distance_from_edge(round(100*pos_along_cut)/100 ...
        == round(100*handles.currentPosition)/100);

    %% get number of blocked out frames
    temp = regionprops(logical(sum(im,1) == 0));
    handles.currentBlockedFrames = max([temp.Area]);

    indices = checkIfStored(handles, direction, handles.currentPosition);
    if sum(indices) > 0
        if strcmp(handles.includedData(indices).userQCLabel, 'Good')
            set(handles.kymTitle{ax}, 'BackgroundColor', [0 1 0]);
        elseif strcmp(handles.includedData(indices).userQCLabel, 'Misassigned edge')
            set(handles.kymTitle{ax}, 'BackgroundColor', [0 1 1]);
        elseif strcmp(handles.includedData(indices).userQCLabel, 'Noise')
            set(handles.kymTitle{ax}, 'BackgroundColor', [1 0 0]);
        elseif strcmp(handles.includedData(indices).userQCLabel, 'Manual')
            set(handles.kymTitle{ax}, 'BackgroundColor', [0 0 1]);
        else
            set(handles.kymTitle{ax}, 'BackgroundColor', 'none');
        end
    else
        set(handles.kymTitle{ax}, 'BackgroundColor', 'none');
    end
    
    oldy = y;
    if sum(indices) > 0
        if strcmp(handles.includedData(indices).userQCLabel, 'Manual')
            [handles, x, y] = getQuantitativeKym(handles, folder, x, y, im, 'manual');
        else
            [handles, x, y] = getQuantitativeKym(handles, folder, x, y, im, 'auto');
        end
    end
        

    handles.fitLine(ax) = line(x, y, 'Parent', kym_ax, 'Color', 'r');
    if sum(indices) > 0
        if strcmp(handles.includedData(indices).userQCLabel, 'Manual')
            filt = strcmp({handles.includedData.date}, handles.date) & strcmp({handles.includedData.embryoNumber}, handles.embryoNumber) & ...
                ([handles.includedData.cutNumber] == str2double(handles.cutNumber)) & strcmp({handles.includedData.direction}, direction) & ...
                (round(100*handles.currentPosition) == round(100 * [handles.includedData.kymPosition]));
            handles.currentManualLineSpeed = handles.includedData(filt).manualSpeed;
            handles.fitText(ax) = text(x(2)+1, y(2), {[sprintf('%0.2f', handles.currentManualLineSpeed) ' \mum s^{-1}'], 'R^{2} = '},...
                'Parent', kym_ax, 'Color', 'r', 'FontSize', 10, 'BackgroundColor', 'k');
        else
            handles.fitText(ax) = text(x(2)+1, y(2), {[sprintf('%0.2f', handles.speeds{ax}(closest)) ' \mum s^{-1}'], 'R^{2} = '},...
            'Parent', kym_ax, 'Color', 'r', 'FontSize', 10, 'BackgroundColor', 'k');
        end
    else
        handles.fitText(ax) = text(x(2)+1, y(2), {[sprintf('%0.2f', handles.speeds{ax}(closest)) ' \mum s^{-1}'], 'R^{2} = '},...
            'Parent', kym_ax, 'Color', 'r', 'FontSize', 10, 'BackgroundColor', 'k');
    end
    

    fitLineState = get(handles.menuOverlayFitLine, 'Checked')   ;
    membraneOverlayState = get(handles.menuOverlayEdge, 'Checked');
    if(~strcmp(fitLineState, 'on'))
        set(handles.fitLine(ax), 'Visible', 'off');
        set(handles.fitText(ax), 'Visible', 'off');
    end
    
    axis(kym_ax, [-handles.timeBeforeCut handles.timeAfterCut 0 max(oldy)], 'tight');

    handles.edgeSide = upperOrLowerEdge(handles.paddedMembrane{ax}, im);
    if strcmp(handles.edgeSide(1), 'u')
        bgcol = [1 0 0];
    else
        bgcol = [0 1 0.2];
    end
    handles.edgeSideTxt = text(9, 1, handles.edgeSide(1), 'Parent', kym_ax, 'BackgroundColor', bgcol);
    
    close(h);
catch ME
    disp(ME);
    for eind = 1:length(ME.stack)
        disp(ME.stack(eind).name);
        disp(ME.stack(eind).line);
    end
end
busyDlg(busyOutput);
set(handles.listData, 'Enable', 'on');

memoryTest();

function memoryTest()
    
    jheapcl;
    hObj = findobj();
    categories = unique(get(hObj, 'Type'));
%     disp(['Total number of objects = ' num2str(length(hObj))])
    for ind = 1:length(categories)
        freq = sum(strcmp(categories{ind}, get(hObj, 'Type')));
%         disp(['Number of ' categories{ind} ' objects = ' num2str(freq)]);
    end
    
    if ispc
        memory;
    end

    

function [handles, x, y] = getQuantitativeKym(handles, folder, x,y, im, manual_auto)

    if strcmp(handles.currentDir, 'up')
        ax = 1;
        appendText = ' upwards';
        kym_ax = handles.axUpSelectedKym;
        direction = 'up';
        handles.currentDir = 'up';
    else
        ax = 2;
        appendText = ' downwards';
        kym_ax = handles.axDownSelectedKym;
        direction = 'down';
        handles.currentDir = 'down';
    end
    
    hold(kym_ax, 'on');
    RI = imref2d(size(im));
    RI.XWorldLimits = [min(x) max(x)];
    RI.YWorldLimits = [min(y) max(y)];
    bg = zeros(size(im));
    cmap = gray;
    cmap(1,:) = [0 1 1];
    colBg = ind2rgb(bg, cmap);
    
    if strcmp(manual_auto, 'auto')
        fpath = [folder filesep handles.date ', Embryo ' handles.embryoNumber ...
            ', Cut ' handles.cutNumber ', Kymograph index along cut = ' num2str(handles.currentKymInd)...
           ' - quantitative kymograph.fig'];
    else
        fpath = [folder filesep handles.date ', Embryo ' handles.embryoNumber ...
            ', Cut ' handles.cutNumber ', Kymograph index along cut = ' num2str(handles.currentKymInd)...
           ' - quantitative kymograph - MANUAL.fig'];
    end
    h = openfig(fpath, 'new', 'invisible');
    fAx = get(h, 'Children');
    dataObjs = get(fAx, 'Children');

    % TODO: get data on frames/second and pre- and post-cut time from metadata
    metadataFName = [folder filesep 'trimmed_cutinfo_cut_' handles.cutNumber '.txt'];
    handles.timeBeforeCut = getNumericMetadataFromText(metadataFName, 'userOptions.timeBeforeCut');
    handles.timeAfterCut = getNumericMetadataFromText(metadataFName, 'userOptions.timeAfterCut');
    handles.frameTime = getNumericMetadataFromText(metadataFName, 'metadata.acqMetadata.cycleTime');
    handles.umPerPixel = getNumericMetadataFromText(metadataFName, 'metadata.umperpixel');
    handles.quantAnalysisTime = getNumericMetadataFromText(metadataFName, 'userOptions.quantAnalysisTime');
        
    xoffset = (sum(sum(im(:,(handles.timeBeforeCut/handles.frameTime):((handles.timeBeforeCut/handles.frameTime) + 5)),1)==0) - 1.5)*handles.frameTime;
    y=get(dataObjs{1}(1), 'YData') + handles.umPerPixel;
    x=get(dataObjs{1}(1), 'XData');
    x = x + xoffset;
    x = [x(1) x(end)];
    y = [y(1) y(end)];

    set(handles.kymIm(ax), 'UIContextMenu', handles.menuSelectedKymFig);

    % handles.kymIm(ax) = imH;

    membrane = get(dataObjs{2}, 'CData');
    prePad = zeros(size(membrane, 1), ((handles.timeBeforeCut/handles.frameTime) - 4) + find(sum(im(:,((handles.timeBeforeCut/handles.frameTime) - 3):((handles.timeBeforeCut/handles.frameTime) + 7)),1)==0, 1, 'last') - 1);
    postPad = zeros(abs(size(im) - size(membrane) - size(prePad)));
    handles.paddedMembrane{ax} = [prePad membrane postPad];


        imshow(colBg, RI, 'Parent', kym_ax);
        handles.kymIm(ax) = imshow(im, RI, [min(im(:)) max(im(:))], 'Parent', kym_ax);

        % For now, default overlay to on
        set(handles.kymIm(ax), 'AlphaData', 1-handles.paddedMembrane{ax}/2);
        set(handles.menuOverlayEdge, 'Checked', 'on');
        hold(kym_ax, 'off');
        set(handles.kymIm(ax), 'UIContextMenu', handles.menuSelectedKymFig);
        
        title_txt = [handles.date ' Embryo ' handles.embryoNumber ', Cut ' handles.cutNumber...
        ',' appendText ', kymograph position along cut: ' sprintf('%0.2f', handles.currentPosition) ' \mum'];
        handles.kymTitle{ax} = title(kym_ax, title_txt);

    delete(h);

% --------------------------------------------------------------------
function saveToPNG_Callback(hObject, eventdata, handles)
% hObject    handle to saveToPNG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isfield(handles, 'baseFolder')
    default_folder = handles.baseFolder;
else
    default_folder = 'C:\Users\Doug\Desktop\test';
end

c = clock;
dateStr = sprintf('%d-%02d-%02d %02d%02d', c(1), c(2), c(3), c(4), c(5));
defaultName = [dateStr ' Kymograph Data Viewer.png'];
[fname,pname] = uiputfile('*.png', 'Save current view to PNG...', [default_folder filesep defaultName]);
set(gcf,'PaperPositionMode','auto');
set(gcf,'InvertHardcopy','off')

print(gcf, [pname fname], '-dpng', '-r600', '-loose');

% --------------------------------------------------------------------
function saveToPPT_Callback(hObject, eventdata, handles)
% hObject    handle to saveToPPT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function incData = addMissingDataForExport(incData, handles)
%% loop through experiment metadata, getting ids for all cuts/kymograph positions, 
% then figuring out whether these exist in the incData structure. If not. add (insert?)
% lines in the structure corresponding to these fields, marking either as
% non-existent edges (if no point on speed v position plot exists) or as
% unQCd data (if user simply hasn't classified the data yet). 

% This should be made considerably faster by farming out assessment of
% whether edges have been found to point of data loading (i.e. on click in
% the leftmost list) and pre-populating the includedData structure at that
% point with 'not QCd' in userQCLabel field, assuming data for this cut is
% not already in the structure. 
incData = incData;


% --------------------------------------------------------------------
function exportWizard_Callback(hObject, eventdata, handles)
% hObject    handle to exportWizard (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% CHECK IF THERE IS DATA TO SAVE?
if isfield(handles, 'includedData')
   if isempty(handles.includedData)
       msgbox('No data included for export!');
       return;
   end
else
    msgbox('No data included for export!');
    return;
end

%% DIALOG TO CHECK WHETHER DATA SHOULD BE APPENDED OR WRITTEN ANEW
% reply = questdlg('Create a new output file, or append output to an existing file?', ...
%     'Create/append?', 'Create new', 'Append', 'Create new');
reply = 'Create new';

switch reply
    case 'Create new'
        [fname, pname] = uiputfile('*.xlsx');
    case 'Append'
        [fname, pname, ~] = uigetfile('*.xlsx');
    otherwise
        return;
end

if isequal(fname, 0)
    return;
else
    outputName = [pname filesep fname];
end

busyOutput = busyDlg();
set(handles.listData, 'Enable', 'off');
        
%% DIALOG TO CHECK WHICH STATS (MAX, MEAN, MEDIAN ETC.) SHOULD BE INCLUDED
reply = questdlg('Save raw data only, or generate max, median, mean for each kymograph?', ...
    'Include max/median/mean?', 'Include stats', 'Don''t include stats', 'Don''t include stats');

switch reply
    case 'Include stats'
        includeStats = true;
    case 'Don''t include stats'
        includeStats = false;
    otherwise
        return;
end

%% EXPORT (TO CSV?)
disp('Export...')

% busyOutput = busyDlg();
% set(handles.listData, 'Enable', 'off');

headerLine = fields(handles.includedData)';
data = struct2cell(handles.includedData)';
% data = addMissingDataForExport(data, handles);

parseForXLExport(handles, headerLine, data, outputName, includeStats);    % Complete output

colFilt = strcmp(headerLine, 'userQCLabel');
rowFilt = strcmp(data(:, colFilt), 'Good') | strcmp(data(:, colFilt), 'Manual');
goodData = data(rowFilt, :);

% replace speeds in manual-labelled cases with manually-determined speeds
goodData(strcmp(goodData(:,strcmp(headerLine, 'userQCLabel')), 'Manual'),...
    strcmp(headerLine, 'speed')) = ...
    goodData(strcmp(goodData(:,strcmp(headerLine, 'userQCLabel')), 'Manual'),... 
    strcmp(headerLine, 'manualSpeed'));

if ~isempty(goodData)
    [pa, fn, ext] = fileparts(outputName);
    goodOutputName = [pa filesep fn '_user QCd' ext];
    parseForXLExport(handles, headerLine, goodData, goodOutputName, includeStats);    % 'Good' kym only output
end
   
busyDlg(busyOutput);
set(handles.listData, 'Enable', 'on');
    
function parseForXLExport(handles, headerLine, data, outputName, includeStats)

if ~isfield(handles.includedData, 'distanceCutToApicalSurfaceUm')

	varn = 'metadata.distanceToApicalSurface';

	distances = cell(0);

	for ind = 1:size(data,1)
	 
	 
		fdate = data{ind,1};
		fENumber = data{ind,2};
		fDirection = data{ind, 31};
		fCNumber = data{ind, 3};
        
        if isa(fdate, 'double')
            fdate = num2str(fdate);
        end
        
        if isa(fCNumber, 'double')
            fCNumber = num2str(fCNumber);
        end
        
        if isa(fENumber, 'double')
            fENumber = num2str(fENumber);
        end
		
		fpath = [handles.baseFolder filesep fdate ', Embryo ' fENumber...
		 ' ' fDirection 'wards' filesep 'trimmed_cutinfo_cut_' num2str(fCNumber)...
		 '.txt'];
	 
		distances = [distances; num2cell(getNumericMetadataFromText(fpath, varn))];
		
	end
	
	data = [data distances];
	
	headerLine = [headerLine 'distanceCutToApicalSurfaceUm'];
 
end

[p, f, ~] = fileparts(outputName);
exportToTextFile([p f '.csv'], headerLine, data, ',', '\n');
xxwrite(outputName, [headerLine; data]);

if includeStats
    %% get list of kymograph IDs
    [uniqueKymIDs,ia,ic]  = unique(data(:, strcmp(headerLine, 'ID')),'stable');
    numQCLabels = [];
    
    % get rid of 'NaN's as side effect of shitty Mac xl import...
    data(strcmp(data(:,strcmp(headerLine, 'speed')), 'NaN'),strcmp(headerLine, 'speed')) = {nan};
    
    %% for each kymograph, isolate the  relevant data rows and calculate stats
    for ind = 1:max(ic)
        temp = [data{ic == ind, strcmp(headerLine, 'speed')}];
        temp(isnan(temp)) = [];
        mu(ind) = mean(temp);
        sd(ind) = std(temp);
        if ~isempty(temp)
            mx(ind) = max(temp);
        else
            mx(ind) = NaN;
        end
        med(ind) = median(temp);
        
        numQCLabels(ind,1) = sum(strcmp(data(ic == ind, strcmp(headerLine, 'userQCLabel')), 'Good'));
        numQCLabels(ind,2) = sum(strcmp(data(ic == ind, strcmp(headerLine, 'userQCLabel')), 'Manual'));
        numQCLabels(ind,3) = sum(strcmp(data(ic == ind, strcmp(headerLine, 'userQCLabel')), 'Noise'));
        numQCLabels(ind,4) = sum(strcmp(data(ic == ind, strcmp(headerLine, 'userQCLabel')), 'Misassigned edge'));
        numQCLabels(ind,5) = sum(strcmp(data(ic == ind, strcmp(headerLine, 'userQCLabel')), 'no edge'));
        numQCLabels(ind,6) = sum(strcmp(data(ic == ind, strcmp(headerLine, 'userQCLabel')), 'not QCd'));
        summ_headerLine = {'EmbryoID' 'Date' 'Embryo number' 'Cut number' 'direction' 'Good' 'Manual' 'Noise' 'Misassigned Edge' 'No Edge' 'Not QCd'};

    end
    
    %% turn off "add sheet" warnings...
    wid = 'MATLAB:xlswrite:AddSheet';
    warning('off', wid);
    
    if ~isempty(numQCLabels)
       numQCLabels = num2cell(numQCLabels);
       xxwrite(outputName, [summ_headerLine; [uniqueKymIDs data(ia, strcmp(headerLine, 'date'))... 
           data(ia, strcmp(headerLine, 'embryoNumber')) data(ia, strcmp(headerLine, 'cutNumber'))...
           data(ia, strcmp(headerLine, 'direction')) numQCLabels]], 'QC summary');
    end
    
    mudata = data(ia, :);
    if ~isempty(mudata)
        mudata(:, strcmp(headerLine, 'speed')) = num2cell(mu);
        xxwrite(outputName, [headerLine; mudata], 'Mean speeds, ums^-1');
    end
    
    sddata = data(ia, :);
    if ~isempty(sddata)
        sddata(:, strcmp(headerLine, 'speed')) = num2cell(sd);
        xxwrite(outputName, [headerLine; sddata], 'SD on speeds, ums^-1');
    end
    
    mxdata = data(ia, :);
    if ~isempty(mxdata)
        mxdata(:, strcmp(headerLine, 'speed')) = num2cell(mx);
        xxwrite(outputName, [headerLine; mxdata], 'Max speeds, ums^-1');
    end
    
    meddata = data(ia, :);
    if ~isempty(meddata)
        meddata(:, strcmp(headerLine, 'speed')) = num2cell(med);
        xxwrite(outputName, [headerLine; meddata], 'Median speeds, ums^-1');
    end
    
    
    
    %% get list of embryo/cut/date
    ids = data(:, strcmp(headerLine, 'ID'));
    if length(ids) > 0
        for ind = 1:length(ids)
            r  = regexp(ids{ind}, '-', 'split');
            ids2{ind} = sprintf('%s-%s-%s', r{1}, r{2}, r{3});
        end

        % perform Jon's suggested filter: speeds corresponding to
        % kymographs inside bounds of cut only. 
        [~, ia, ic] = unique(ids2, 'stable');
        %% for each kymograph, isolate the  relevant data rows and calculate stats
        for ind = 1:max(ic)
            temp = [data{((ic == ind) & (cell2mat(data(:, strcmp(headerLine, 'fractionalPosition'))) > 0) ...
                & (cell2mat(data(:, strcmp(headerLine, 'fractionalPosition'))) < 1)), strcmp(headerLine, 'speed')}];
            temp(isnan(temp)) = [];
            
            if ~isempty(temp)
                filtmu(ind) = mean(temp);

                filtsd(ind) = std(temp);

                try
                    filtmx(ind) = max(temp);
                catch
                    filtmx(ind) = NaN;
                end

                filtmed(ind) = median(temp);
            else
                filtmu(ind) = NaN;
                filtsd(ind) = NaN;
                filtmx(ind) = NaN;
                filtmed(ind) = NaN;
            end
        end

        filtmudata = data(ia, :);
        if ~isempty(filtmudata) && ~isempty(filtmu)
            filtmudata(:, strcmp(headerLine, 'speed')) = num2cell(filtmu);
            xxwrite(outputName, [headerLine; filtmudata], 'CombinedUpDownApicalMean');
        end

        filtsddata = data(ia, :);
        if ~isempty(filtsddata) && ~isempty(filtsd)
            filtsddata(:, strcmp(headerLine, 'speed')) = num2cell(filtsd);
            xxwrite(outputName, [headerLine; filtsddata], 'CombinedUpDownApicalSD');
        end

        filtmxdata = data(ia, :);
        if ~isempty(filtmxdata) && ~isempty(filtmx)
            filtmxdata(:, strcmp(headerLine, 'speed')) = num2cell(filtmx);
            xxwrite(outputName, [headerLine; filtmxdata], 'CombinedUpDownApicalMax');
        end

        filtmeddata = data(ia, :);
        if ~isempty(filtmeddata) && ~isempty(filtmed)
            filtmeddata(:, strcmp(headerLine, 'speed')) = num2cell(filtmed);
            xxwrite(outputName, [headerLine; filtmeddata], 'CombinedUpDownApicalMedian');
        end


        %% Now do Jon-style ("inside cut only") filtering, but separating up and down kymographs for
        % meaningful comparison of apical and basal surface movement in order
        % to assess whether cells are moving or changing size:

        filtmu = [];
        filtsd = [];
        filtmx = [];
        filtmed = [];

        [~, ia, ic] = unique(ids, 'stable');
        %% for each kymograph, isolate the  relevant data rows and calculate stats
        for ind = 1:max(ic)
            temp = [data{((ic == ind) & (cell2mat(data(:, strcmp(headerLine, 'fractionalPosition'))) > 0) ...
                & (cell2mat(data(:, strcmp(headerLine, 'fractionalPosition'))) < 1)), strcmp(headerLine, 'speed')}];
            temp(isnan(temp)) = [];
            
            if ~isempty(temp)
                filtmu(ind) = mean(temp);

                filtsd(ind) = std(temp);

                try
                    filtmx(ind) = max(temp);
                catch
                    filtmx(ind) = NaN;
                end

                filtmed(ind) = median(temp);
            else
                filtmu(ind) = NaN;
                filtsd(ind) = NaN;
                filtmx(ind) = NaN;
                filtmed(ind) = NaN;
            end
            
        end

        filtmudata = data(ia, :);
        if ~isempty(filtmudata) && ~isempty(filtmu)
            filtmudata(:, strcmp(headerLine, 'speed')) = num2cell(filtmu);
            xxwrite(outputName, [headerLine; filtmudata], 'SeparateUpDownBehindAMean');
        end

        filtsddata = data(ia, :);
        if ~isempty(filtsddata) && ~isempty(filtsd)
            filtsddata(:, strcmp(headerLine, 'speed')) = num2cell(filtsd);
            xxwrite(outputName, [headerLine; filtsddata], 'SeparateUpDownBehindASD');
        end

        filtmxdata = data(ia, :);
        if ~isempty(filtmxdata) && ~isempty(filtmx)
            filtmxdata(:, strcmp(headerLine, 'speed')) = num2cell(filtmx);
            xxwrite(outputName, [headerLine; filtmxdata], 'SeparateUpDownBehindAMax');
        end

        filtmeddata = data(ia, :);
        if ~isempty(filtmeddata) && ~isempty(filtmed)
            filtmeddata(:, strcmp(headerLine, 'speed')) = num2cell(filtmed);
            xxwrite(outputName, [headerLine; filtmeddata], 'SeparateUpDownBehindAMedian');
        end
        
%         %% Now do Jon-style ("inside cut only") filtering, but separating damaged and undamaged side kymographs
% 
%         filtmu = [];
%         filtsd = [];
%         filtmx = [];
%         filtmed = [];
% 
%         [~, ia, ic] = unique(ids, 'stable');
%         %% for each kymograph, isolate the  relevant data rows and calculate stats
%         yn = {'yes' 'no'};
%         for ind2 = 1:length(yn)
%             for ind = 1:max(ic)
%                 temp = [data{((ic == ind) & (cell2mat(data(:, strcmp(headerLine, 'fractionalPosition'))) > 0) ...
%                     & (cell2mat(data(:, strcmp(headerLine, 'fractionalPosition'))) < 1)) ...
%                     & (strcmp(data(:,strcmp(headerLine, 'thisSideDamaged')), yn{ind2})), ...
%                     strcmp(headerLine, 'speed')}];
%                 temp(isnan(temp)) = [];
%                 
%                 if ~isempty(temp)
% 
%                     filtmu(ind + (ind2 - 1) * max(ic)) = mean(temp);
% 
%                     filtsd(ind + (ind2 - 1) * max(ic)) = std(temp);
% 
%                     try
%                         filtmx(ind + (ind2 - 1) * max(ic)) = max(temp);
%                     catch
%                         filtmx(ind + (ind2 - 1) * max(ic)) = NaN;
%                     end
% 
%                     filtmed(ind + (ind2 - 1) * max(ic)) = median(temp);
%                     
%                 end
%             end
%         end
% 
%         filtmudata = data(ia, :);
%         if ~isempty(filtmudata) && ~isempty(filtmu)
%             filtmudata(:, strcmp(headerLine, 'speed')) = num2cell(filtmu);
%             xxwrite(outputName, [headerLine; filtmudata], 'InsideCutDamageFiltMean');
%         end
% 
%         filtsddata = data(ia, :);
%         if ~isempty(filtsddata) && ~isempty(filtsd)
%             filtsddata(:, strcmp(headerLine, 'speed')) = num2cell(filtsd);
%             xxwrite(outputName, [headerLine; filtsddata], 'InsideCutDamageFiltSD');
%         end
% 
%         filtmxdata = data(ia, :);
%         if ~isempty(filtmxdata) && ~isempty(filtmx)
%             filtmxdata(:, strcmp(headerLine, 'speed')) = num2cell(filtmx);
%             xxwrite(outputName, [headerLine; filtmxdata], 'InsideCutDamageFiltMax');
%         end
% 
%         filtmeddata = data(ia, :);
%         if ~isempty(filtmeddata) && ~isempty(filtmed)
%             filtmeddata(:, strcmp(headerLine, 'speed')) = num2cell(filtmed);
%             xxwrite(outputName, [headerLine; filtmeddata], 'InsideCutDamageFiltMedian');
%         end

    end
    
end



function xxwrite(varargin)
outName = varargin{1};
data = varargin{2};
if ~ispc
    [pname, fname, ~] = fileparts(outName);
    outName = [pname filesep fname '.xls'];
    if nargin == 2
        xlwrite(outName, data);
    elseif nargin == 3
        sht = varargin{3};
        xlwrite(outName, data, sht);
    end
else
    if nargin ==2
        xlswrite(outName, data);
    elseif nargin == 3
        sht = varargin{3};
        xlswrite(outName, data, sht);
    end
end
    

% --------------------------------------------------------------------
function menuOverlayFitLine_Callback(hObject, eventdata, handles, callAx)
% hObject    handle to menuOverlayFitLine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% replace callAx with gca?
if (callAx == handles.axUpSelectedKym)
    ax = 1;
elseif (callAx == handles.axDownSelectedKym)
    ax = 2;
end

fitLineState = get(handles.menuOverlayFitLine, 'Checked');
if strcmp(fitLineState, 'on')
    if isfield(handles, 'menuOverlayFitLine')
        set(handles.menuOverlayFitLine, 'Checked', 'off');
    end
    if isfield(handles, 'fitLine')
        set(handles.fitLine(ax), 'Visible', 'off');
    end
    if isfield(handles, 'fitText')
        set(handles.fitText(ax), 'Visible', 'off');
    end
else
    if isfield(handles, 'menuOverlayFitLine')
        set(handles.menuOverlayFitLine, 'Checked', 'on');
    end
    if isfield(handles, 'fitLine')
        set(handles.fitLine(ax), 'Visible', 'on');
    end
    if isfield(handles, 'fitText')
    	set(handles.fitText(ax), 'Visible', 'on');
    end
end

guidata(hObject, handles);

% --------------------------------------------------------------------
function menuSelectedKymFig_Callback(hObject, eventdata, handles)
% hObject    handle to menuSelectedKymFig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if (gca == handles.axUpSelectedKym)
    ax = 1;
    handles.currentDir = 'up';
elseif (gca == handles.axDownSelectedKym)
    ax = 2;
    handles.currentDir = 'down';
end

if strcmp(get(handles.fitLine(ax), 'Visible'), 'on')
    set(handles.menuOverlayFitLine, 'Checked', 'on');
else
    set(handles.menuOverlayFitLine, 'Checked', 'off');
end

ad = get(handles.kymIm(ax), 'AlphaData');
if mean(ad(:))==1
    set(handles.menuOverlayEdge, 'Checked', 'off');
else
    set(handles.menuOverlayEdge, 'Checked', 'on');
end

if isfield(handles, 'experimentMetadata')
    if ~isempty(handles.experimentMetadata)
        set(handles.menuInclude, 'Enable', 'on');
        set(handles.menuIncludeNoise', 'Enable', 'on');
        set(handles.menuIncludeMisassigned, 'Enable', 'on');
    else
        set(handles.menuInclude, 'Enable', 'off');
        set(handles.menuIncludeNoise', 'Enable', 'off');
        set(handles.menuIncludeMisassigned, 'Enable', 'off');
    end
else
    set(handles.menuInclude, 'Enable', 'off');
    set(handles.menuIncludeNoise', 'Enable', 'off');
    set(handles.menuIncludeMisassigned, 'Enable', 'off');
end

menuHs = get(handles.menuExport, 'Children');
if ischar(get(handles.kymTitle{ax}, 'BackgroundColor'))
    if strcmp(get(handles.kymTitle{ax}, 'BackgroundColor'), 'none')
        set(handles.menuInclude, 'Checked', 'off');
        set(menuHs, 'Checked', 'off');
    end
else
    if get(handles.kymTitle{ax}, 'BackgroundColor') == [0 1 0]
        set(handles.menuInclude, 'Checked', 'on');
    elseif get(handles.kymTitle{ax}, 'BackgroundColor') == [1 0 0]
        set(handles.menuIncludeNoise, 'Checked', 'on');
    elseif get(handles.kymTitle{ax}, 'BackgroundColor') == [0 1 1]
        set(handles.menuIncludeMisassigned, 'Checked', 'on');
    end
end

guidata(hObject, handles);

% --------------------------------------------------------------------
function menuOverlayEdge_Callback(hObject, eventdata, handles)
% hObject    handle to menuOverlayEdge (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = guidata(gcf);

if isfield(handles, 'paddedMembrane')

    if (gca == handles.axUpSelectedKym)
        ax = 1;
    elseif (gca == handles.axDownSelectedKym)
        ax = 2;
    end

    overlayEdgeState = get(handles.menuOverlayEdge, 'Checked');
    if strcmp(overlayEdgeState, 'on')
        set(handles.menuOverlayEdge, 'Checked', 'off');
        set(handles.kymIm(ax), 'AlphaData', 1);
    else
        set(handles.menuOverlayEdge, 'Checked', 'on');
        set(handles.kymIm(ax), 'AlphaData', 1-handles.paddedMembrane{ax}/2);
    end

end

guidata(hObject, handles);


% --------------------------------------------------------------------
function menuManualLine_Callback(hObject, eventdata, handles)
% hObject    handle to menuManualLine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmp(get(hObject, 'checked'), 'on')
    set(hObject, 'checked', 'off');
    set(handles.menuSaveManualSpeed, 'Enable', 'off')
    if isfield(handles, 'manualLine')
        delete(handles.manualLine);
        handles.currentManualLineSpeed = [];
    end
else
    set(hObject, 'checked', 'on');
    set(handles.menuSaveManualSpeed, 'Enable', 'on')
    nonsense = get(gca);
    handles.manualLine = imline(gca, [0 4], [1 1]);
%     addNewPositionCallback(handles.manualLine, manualLineCallback(hObject, handles))
end

guidata(hObject, handles)


function pos = manualLineCallback(hObject, handles)

    disp('nonsense');
%     pos = handles.manualLine.getPosition;
%     handles.currentManualLineSpeed = (pos(1,2) - pos(2,2))/...
%         (pos(1,1) - pos(2,1));

guidata(hObject, handles)

% --------------------------------------------------------------------
function menuFixAxisLimits_Callback(hObject, eventdata, handles)
% hObject    handle to menuFixAxisLimits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuToggleFixedAxes_Callback(hObject, eventdata, handles)
% hObject    handle to menuToggleFixedAxes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('toggle');


% --------------------------------------------------------------------
function menuSetLimits_Callback(hObject, eventdata, handles)
% hObject    handle to menuSetLimits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuSpeedVPos_Callback(hObject, eventdata, handles)
% hObject    handle to menuSpeedVPos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuLoadMetadata_Callback(hObject, eventdata, handles)
% hObject    handle to menuLoadMetadata (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


default_folder = 'C:\Users\Doug\Desktop\test';
if isfield(handles, 'metadataPath')
    if ischar(handles.metadataPath)
        sf = handles.metadataPath;
    else
        sf = default_folder;
    end
elseif ~isfield(handles, 'baseFolder')
    sf = default_folder;
else
    if ischar(handles.baseFolder)
        sf = handles.baseFolder;
    else
        sf = default_folder;
    end
end

reply = 'OK';
% if isfield(handles, 'includedData')
%     if ~isempty(handles.includedData)
%         reply = questdlg('Discard data currently set as "included" for export?', ...
%             'Discard data - are you sure?', 'OK', 'Cancel', 'Cancel');
%     end
% end

if strcmp(reply, 'OK')

    busyOutput = busyDlg();
    set(handles.listData, 'Enable', 'off');

    [fname, pname,~]= uigetfile('*.xls', 'Choose the xls file containing the experiment metadata...', sf);
    handles.metadataPath = [pname, fname];

    if ischar(handles.metadataPath)
        handles.experimentMetadata = getExperimentMetadata(handles.metadataPath);
    end

    busyDlg(busyOutput);
    set(handles.listData, 'Enable', 'on');

    if ~isfield(handles, 'includedData')
        handles.includedData = [];
    end
%     handles.includedData = [];

end
    
guidata(hObject, handles);

function indices = checkIfStored(handles, direction, position)
% Check whether currently selected kymograph data has been stored for
% export
indices = 0;
if isfield(handles, 'includedData');
    if isstruct(handles.includedData)
        stored = struct2cell(handles.includedData);
        f = fields(handles.includedData);
        dates = {stored(strcmp(f, 'date'), :)};
%         if isnumeric(dates{1}{1})
%             dates = cellfun(@num2str, dates{1}, 'UniformOutput', false);
%             dates = num2str(dates);
%         end
        dates = convertToStringUtil({stored(strcmp(f, 'date'), :)});
        embryoNs = convertToStringUtil({stored(strcmp(f, 'embryoNumber'), :)});
        cutNs = cell2mat(stored(strcmp(f, 'cutNumber'), :));
        directions = convertToStringUtil({stored(strcmp(f, 'direction'), :)}); 
        if ischar(stored{strcmp(f, 'kymPosition'), 1})
            positions = cellfun(@str2num, stored(strcmp(f, 'kymPosition'), :));
        else
            positions = cell2mat(stored(strcmp(f, 'kymPosition'), :));
        end
            
        if max(size(dates)) == 1
            indices = strcmp(dates{1}, handles.date) & strcmp(embryoNs{1}, handles.embryoNumber) & ...
                (cutNs == str2double(handles.cutNumber)) & strcmp(directions{1}, direction) & ...
                round(100*positions)/100 == round(100*position)/100;
        else
            indices = strcmp(dates, handles.date) & strcmp(embryoNs, handles.embryoNumber) & ...
                (cutNs == str2double(handles.cutNumber)) & strcmp(directions{:}, direction) & ...
                round(100*positions)/100 == round(100*position)/100;
        end
            
    end
end

function outVar = convertToStringUtil(inVar)

if isnumeric(inVar{1}{1})
    outVar = cellfun(@num2str, inVar{1}, 'UniformOutput', false);
else
    outVar = inVar;
end


function handles = genericInclude(handles, qcLabel, direction, position)

% if nargin == 0
%     position = handles.currentPosition;
%     fractionalPosition = handles.currentFractionalPosition;
% elseif nargin == 2
%     position = varargin{1}(varargin{3};
%     fractionalPosition = varargin{2}(varargin{3});
% end

% %% Check if current date/embryo/cut/direction/position is stored yet
indices = checkIfStored(handles, direction, position);

%% If not, store in includedData structure along with metadata
if sum(indices) == 0
    
    % Find the relevant experiment metadata fields...
    expMeta = struct2cell(handles.experimentMetadata);
    expMetaFields = fields(handles.experimentMetadata);
    
    dates = {expMeta(strcmp(expMetaFields, 'date'), :)};
    embryoNs = {expMeta(strcmp(expMetaFields, 'embryoNumber'), :)};
    cutNs = {expMeta(strcmp(expMetaFields, 'cutNumber'), :)};
    
    expMetaIndices = strcmp(dates{1}, handles.date) & strcmp(embryoNs{1}, handles.embryoNumber) & ...
        (cell2mat(cutNs{1}) == str2double(handles.cutNumber));
    
    incData = handles.experimentMetadata(expMetaIndices);
    incData.cutLength = handles.currentCutLength;
    incData.cutDuration = handles.currentCutDuration;
    incData.ID = [handles.date '-' handles.embryoNumber '-' handles.cutNumber '-' direction];
    incData.kymPosition = handles.currentPosition;
    incData.fractionalPosition = handles.currentFractionalPosition;
    incData.distanceFromEdge = handles.currentDistanceFromEdge;
    incData.speed = handles.currentSpeed;
    incData.direction = direction;
    incData.numberBlockedFrames = handles.currentBlockedFrames;
    incData.edgeSide = handles.edgeSide;
    
    incData.userQCLabel = qcLabel;
    
    incData.distanceCutToApicalSurfaceUm = handles.currentApicalSurfaceToCutDistance;
    
    if isfield(handles, 'currentManualLineSpeed') && strcmp(qcLabel, 'Manual')
        incData.manualSpeed = handles.currentManualLineSpeed;
    else
        incData.manualSpeed = nan;
    end
    
    
    if strcmp(handles.currentDamageSide, direction)
        incData.thisSideDamaged = 'yes';
    elseif isempty(handles.currentDamageSide)
        incData.thisSideDamaged = '';
    else
        incData.thisSideDamaged = 'no';
    end
    
    if ~isempty(handles.meanDifferenceGeometricalActualMidline)
        incData.meanDifferenceGeometricalActualMidline = ...
            handles.meanDifferenceGeometricalActualMidline;
    else
        handles.meanDifferenceGeometricalActualMidline = '';
    end
    
    if ~isempty(handles.sdDifferenceGeometricalActualMidline)
        incData.sdDifferenceGeometricalActualMidline = ...
            handles.sdDifferenceGeometricalActualMidline;
    else
        handles.sdDifferenceGeometricalActualMidline = '';
    end
    
    if isfield(handles, 'currentLongerSide')
        if ~isempty(handles.currentLongerSide)
            if strcmp(handles.currentLongerSide, direction)
                incData.thisSideLonger = 'yes';
            elseif strcmp(handles.currentLongerSide, 'neither')
                incData.thisSideLonger = 'equal';
            else
                incData.thisSideLonger = 'no';
            end
        else
            incData.thisSideLonger = '';
        end
    else
        incData.thisSideLonger = '';
    end
    
    % deal with case in which loaded QC data doesn't have all the fields
    % that are present in the inclusion data that viewer is now trying to
    % add...
    if ~isempty(handles.includedData)
        if length(fields(incData)) ~= length(fields(handles.includedData))
            flds = fields(incData);
            for fldind = 1:length(flds)
                if sum(strcmp(flds(fldind),fields(handles.includedData))) == 0
                    handles.includedData(size(handles.includedData, 1)).(flds{fldind}) = []; % initialise field values in all array elements as empty
                end
            end
        end
    end
        
    handles.includedData = [handles.includedData; incData];
   
else
    handles.includedData(indices).userQCLabel = qcLabel;
    handles.includedData(indices).speed = handles.currentSpeed;
    if isfield(handles, 'currentManualLineSpeed') && strcmp(qcLabel, 'Manual')
        handles.includedData(indices).manualSpeed = handles.currentManualLineSpeed;
    else
        handles.includedData(indices).manualSpeed = nan;
    end
    handles.includedData(indices).numberBlockedFrames = handles.currentBlockedFrames;
    handles.includedData(indices).edgeSide = handles.edgeSide;
    
    if strcmp(handles.currentDamageSide, direction)
        handles.includedData(indices).thisSideDamaged = 'yes';
    elseif isempty(handles.currentDamageSide)
        handles.includedData(indices).thisSideDamaged = '';
    else
        handles.includedData(indices).thisSideDamaged = 'no';
    end

    
    
end

% --------------------------------------------------------------------
function handles = menuInclude_Callback(hObject, eventdata, handles)
% hObject    handle to menuInclude (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Return warning/break if metadata hasn't been loaded yet...
if ~isfield(handles, 'experimentMetadata')
    msgbox('You need to load metadata before trying to include data for export!');
    return;
end

%% clear other checkboxes
menuHs = get(get(hObject, 'Parent'), 'Children');
for menuH = menuHs
    set(menuH, 'Checked', 'off');
end
set(hObject, 'Checked', 'on');

if gca == handles.axUpSelectedKym
    direction = 'up';
    ax = 1;
else
    direction = 'down';
    ax = 2;
end

handles = genericInclude(handles, get(hObject, 'Label'), direction, handles.currentPosition);

% Make this bit verbose for greater accessbility later...
if strcmp(get(hObject, 'Label'), 'Misassigned edge')
    set(handles.kymTitle{ax}, 'BackgroundColor', [0 1 1]);
elseif strcmp(get(hObject, 'Label'), 'Noise')
    set(handles.kymTitle{ax}, 'BackgroundColor', [1 0 0]);
elseif strcmp(get(hObject, 'Label'), 'Good')
    set(handles.kymTitle{ax}, 'BackgroundColor', [0 1 0]);
elseif strcmp(get(hObject, 'Label'), 'Manual')
    set(handles.kymTitle{ax}, 'BackgroundColor', [0 0 1]);
end

handles.qcColor{ax} = generateQCColorArray(handles, handles.qcColor{ax}, direction);
updateMyScatterColors(handles.qcScatter{ax}, handles.qcColor{ax});

guidata(hObject, handles);
    


% --------------------------------------------------------------------
function menuMovies_Callback(hObject, eventdata, handles)
% hObject    handle to menuMovies (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if gca == handles.axUpFirstFrame
    ax = 1;
    appendText = ' upwards';
else
    ax = 2;
    appendText = ' downwards';
end

if isfield(handles, 'movieFrames')
    if length(handles.movieFrames) >= ax  
        if ~isempty(handles.movieFrames{ax})
%             set(handles.menuSaveMovie, 'Enable', 'on');
        else
            set(handles.menuSaveMovie, 'Enable', 'off');
        end
    else
        set(handles.menuSaveMovie, 'Enable', 'off');
    end
else
    set(handles.menuSaveMovie, 'Enable', 'off');
end


% --------------------------------------------------------------------
function menuViewMovie_Callback(hObject, eventdata, handles)
% hObject    handle to menuViewMovie (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
busyOutput = busyDlg();
baseFolder2 = [handles.baseFolder filesep handles.date ', Embryo ' handles.embryoNumber];
if gca == handles.axUpFirstFrame
    ax = 1;
    appendText = ' upwards';
else
    ax = 2;
    appendText = ' downwards';
end

folder = [baseFolder2 appendText];
metadataFName = [folder filesep 'trimmed_cutinfo_cut_' handles.cutNumber '.txt'];
imFName = [folder filesep 'trimmed_stack_cut_' handles.cutNumber '.tif'];

handles.movieFrames{ax} = makeMovieOfProcessedData(imFName, metadataFName, handles);

busyDlg(busyOutput);

guidata(hObject, handles);


% --------------------------------------------------------------------
function menuViewSaveMovie_Callback(hObject, eventdata, handles)
% hObject    handle to menuViewSaveMovie (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
busyOutput = busyDlg();
baseFolder2 = [handles.baseFolder filesep handles.date ', Embryo ' handles.embryoNumber];
if gca == handles.axUpFirstFrame
    ax = 1;
    appendText = ' upwards';
else
    ax = 2;
    appendText = ' downwards';
end

folder = [baseFolder2 appendText];
metadataFName = [folder filesep 'trimmed_cutinfo_cut_' handles.cutNumber '.txt'];
imFName = [folder filesep 'trimmed_stack_cut_' handles.cutNumber '.tif'];

[fileName,pathName,~] = uiputfile('*.avi','Choose AVI filename...',...
    [folder filesep 'Movie of processed membrane movement, date = ', handles.date ...
    ', embryo = ' handles.embryoNumber ', cut = ' handles.cutNumber appendText '.avi']);

if fileName ~= 0
    handles.movieFrames{ax} = makeMovieOfProcessedData(imFName, metadataFName, handles, [pathName fileName]);
end
    
busyDlg(busyOutput);

guidata(hObject, handles);

% --------------------------------------------------------------------
function menuSaveMovie_Callback(hObject, eventdata, handles)
% hObject    handle to menuSaveMovie (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fps = 15;
busyOutput = busyDlg();
baseFolder2 = [handles.baseFolder filesep handles.date ', Embryo ' handles.embryoNumber];
if gca == handles.axUpFirstFrame
    ax = 1;
    appendText = ' upwards';
else
    ax = 2;
    appendText = ' downwards';
end

folder = [baseFolder2 appendText];
metadataFName = [folder filesep 'trimmed_cutinfo_cut_' handles.cutNumber '.txt'];
imFName = [folder filesep 'trimmed_stack_cut_' handles.cutNumber '.tif'];
[fileName,pathName,~] = uiputfile('*.avi','Choose AVI filename...',...
    [folder filesep 'Movie of processed membrane movement, date = ', handles.date ...
    ', embryo = ' handles.embryoNumber ', cut = ' handles.cutNumber appendText '.avi']);

makeMovieOfProcessedData(imFName, metadataFName, [pathName fileName], handles.movieFrames{ax}, fps);
busyDlg(busyOutput);


% --- Executes on key press with focus on figure1 or any of its controls.
function figure1_WindowKeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
% disp(eventdata.Key);
% disp(eventdata.Character);
% disp(eventdata.Modifier);

if strcmp(eventdata.Key, 'c')
    % run code to compare geometrical and actual midlines
    compareMidlines(handles);
end

if strcmp(eventdata.Key, 'm')
    % run code to determine geometrical midlines
    determineGeometricalMidline(handles);
end

if strcmp(eventdata.Key, 'l')
   if strcmp(handles.currentDir, 'up')
       ax = handles.axUpSelectedKym;
   else
       ax = handles.axDownSelectedKym;
   end
   menuOverlayFitLine_Callback(hObject, eventdata, handles, ax); 
end

%%
if strcmp(eventdata.Key, 'backslash')
    % get current list data position
    currpos = get(handles.listData, 'Value');
    if currpos ~=1
        set(handles.listData, 'Value', currpos - 1);
        guidata(hObject, handles);
        listData_Callback(handles.listData, eventdata, handles)
    end
end

if strcmp(eventdata.Key, 'slash')
    % get current list data position
    currpos = get(handles.listData, 'Value');
    if currpos ~= length(get(handles.listData, 'String'))
        set(handles.listData, 'Value', currpos + 1);
        guidata(hObject, handles);
        listData_Callback(handles.listData, eventdata, handles)
    end
end
%%

    
    
if strcmp(eventdata.Key, 'f')
    if strcmp(handles.currentDir, 'up')
        axes(handles.axUpSelectedKym);
        axind = 1;
    else
        axes(handles.axDownSelectedKym);
        axind = 2;
    end
            
    if isfield(handles, 'kymIm')
%         if ~isempty(get(handles.kymIm(axind), 'CData'))
            
            [figurePath, handles.currentManualLineSpeed] = manualSpeedFreehand(handles, get(handles.kymIm(axind), 'CData'));
            xposs = get(handles.fitLine(axind), 'XData');
            xpos = max(xposs);
            yposs = (get(handles.fitLine(axind), 'YData'));
            ypos = xposs(xposs == xpos);
            
            handles.fitText(axind) = text(xpos, ypos, {[sprintf('%0.2f', handles.currentManualLineSpeed) ' \mum s^{-1}'], 'R^{2} = '},...
                'Parent', gca, 'Color', 'r', 'FontSize', 10, 'BackgroundColor', 'k');
            %  - update viewer to show new edge and new speed
            [folder,~,~] = fileparts(figurePath);
            [handles, ~, ~] = getQuantitativeKym(handles, folder, get(handles.kymIm(axind), 'XData'),...
                get(handles.kymIm(axind), 'YData'), get(handles.kymIm(axind), 'CData'), 'manual');
            guidata(hObject, handles);
            
            %  - add extra qclabel to highlight manual speeds, inc. title
            % color
            hObject = handles.menuIncludeManual;
            callback = get(handles.menuIncludeManual, 'Callback');
            callback(hObject, eventdata);
            
%         end
    end
end

if strcmp(eventdata.Key, 'e')
    if strcmp(handles.currentDir, 'up')
        axes(handles.axUpSelectedKym);
    else
        axes(handles.axDownSelectedKym);
    end
    callback = get(handles.menuOverlayEdge, 'Callback');
    callback(handles.menuOverlayEdge, []);
end

if strcmp(eventdata.Key, 'g')
    if strcmp(handles.currentDir, 'up')
        axes(handles.axUpSelectedKym);
    else
        axes(handles.axDownSelectedKym);
    end
%     handles = genericInclude(handles, 'Good', handles.currentDir, handles.currentPosition);
    hObject = handles.menuInclude;
    callback = get(handles.menuInclude, 'Callback');
    handles = callback(handles.menuInclude, []);

end

if strcmp(eventdata.Key, 'u')
    if strcmp(handles.currentDir, 'up')
        axes(handles.axUpSelectedKym);
    else
        axes(handles.axDownSelectedKym);
    end
    %% Toggle MISASSIGNED label
%     handles = genericInclude(handles, 'Misassigned edge', handles.currentDir, handles.currentPosition);
    callback = get(handles.menuIncludeMisassigned, 'Callback');
    handles = callback(handles.menuIncludeMisassigned, []);
end

if strcmp(eventdata.Key, 'n')
    if strcmp(handles.currentDir, 'up')
        axes(handles.axUpSelectedKym);
    else
        axes(handles.axDownSelectedKym);
    end
    %% Toggle NOISE label
    callback = get(handles.menuIncludeNoise, 'Callback');
    handles = callback(handles.menuIncludeNoise, []);
end

if strcmp(eventdata.Key, 'p')
    if strcmp(handles.currentDir, 'up')
        axes(handles.axUpFirstFrame);
    else
        axes(handles.axDownFirstFrame);
    end
    callback = get(handles.menuViewMovie, 'Callback');
    callback(handles.menuViewMovie, []);
end

if strcmp(eventdata.Key, 'uparrow')
    handles.currentDir = 'up';
    axes(handles.axUpSpeedVPosition);
    guidata(hObject, handles);
end

if strcmp(eventdata.Key, 'downarrow')
    handles.currentDir = 'down';
    axes(handles.axDownSpeedVPosition);
    guidata(hObject, handles);
end

if strcmp(eventdata.Key, 'rightarrow')
    if strcmp(handles.currentDir, 'up')
        axes(handles.axUpSpeedVPosition);
        ax = 1;
    else
        axes(handles.axDownSpeedVPosition);
        ax = 2;
    end
    % identify current point, and therefore point to the right
    xpos = handles.currentPosition;
    x = abs(handles.poss{ax} - xpos);

    closest = find(x == min(x));

    if (handles.poss{ax}(2) - handles.poss{ax}(1)) > 0
        delta = 1;
    else
        delta = -1;
    end

    if (closest + delta) > 0 && (closest + delta) <= length(handles.poss{ax})
        handles = move_selected_point(closest + delta);
    end
    
    guidata(hObject, handles);
    
end

if strcmp(eventdata.Key, 'leftarrow')
    if strcmp(handles.currentDir, 'up')
        axes(handles.axUpSpeedVPosition);
        ax = 1;
    else
        axes(handles.axDownSpeedVPosition);
        ax = 2;
    end
    % identify current point, and therefore point to the right
    xpos = handles.currentPosition;
    x = abs(handles.poss{ax} - xpos);

    closest = find(x == min(x));
    
    if (handles.poss{ax}(2) - handles.poss{ax}(1)) > 0
        delta = -1;
    else
        delta = 1;
    end

    if (closest + delta) > 0 && (closest + delta) <= length(handles.poss{ax})
        handles = move_selected_point(closest + delta);
    end
    
    guidata(hObject, handles);
end

if strcmp(eventdata.Key, 'd')
    if isfield(handles, 'currentDir')
        if strcmp(eventdata.Modifier, 'shift')
            showDamageIcon('none', handles);  
            handles.currentDamageSide = '';
            handles.damagedSideList{get(handles.listData, 'Value')} = '';
        else

                showDamageIcon(handles.currentDir, handles);  
                handles.currentDamageSide = handles.currentDir;
                handles.damagedSideList{get(handles.listData, 'Value')} = handles.currentDir;

        end

        % set appropriate lines in included data, this side damaged to 'yes'
        filt = strcmp({handles.includedData.date}, num2str(handles.date)) & strcmp({handles.includedData.embryoNumber}, num2str(handles.embryoNumber)) ...
            & ([handles.includedData.cutNumber] == str2double(handles.cutNumber)) & strcmp({handles.includedData.direction}, handles.currentDir);
        filt2 = strcmp({handles.includedData.date}, num2str(handles.date)) & strcmp({handles.includedData.embryoNumber}, num2str(handles.embryoNumber)) ...
            & ([handles.includedData.cutNumber] == str2double(handles.cutNumber)) & ~strcmp({handles.includedData.direction}, handles.currentDir);

        temp = {handles.includedData.thisSideDamaged};
        y = cell(1);
        n = cell(1);
        y{1} = 'yes';
        n{1} = 'no';
        temp(filt) = y;
        temp(filt2) = n;
        if strcmp(eventdata.Modifier, 'shift')
            temp(filt | filt2) = '';
        end

        for ind = 1:length(temp)
            handles.includedData(ind).thisSideDamaged = temp{ind};
        end

        guidata(hObject, handles);
    end
    
end

% --------------------------------------------------------------------
function menuImportInclusion_Callback(hObject, eventdata, handles)
% hObject    handle to menuImportInclusion (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
busyOutput = busyDlg();
reply = 'Yes';
if isfield(handles, 'includedData')
    if ~isempty(handles.includedData)
        reply = questdlg('Overwrite unsaved inclusion data?', 'Are you sure?', 'Yes', 'No', 'No');
    end
end

if strcmp(reply, 'Yes')
    handles.includedData = [];

    [fname, pname, ~] = uigetfile('*.xls;*.xlsx', 'Choose an exisiting kymograph inclusion file...');
    
    if fname ~= 0
        filepath = [pname fname];
        % deal with fact that PC and Mac save first (unnamed) Excel sheet
        % with different default names
        [~, sheets] = xlsfinfo(filepath);
        if (sum(strcmp(sheets, 'MATLAB')) > 0)
            sh = 'MATLAB';
        else
            sh = 'Sheet1';
        end
        [~,~,dummy] = xlsread(filepath, sh);

        handles.includedData = cell2struct(dummy(2:end, :)', dummy(1,:)', 1);
    
    
        % ensure that dates are in string format in order that comparisons work
        % later...
        for ind = 1:length(handles.includedData)
            handles.includedData(ind).date = num2str(handles.includedData(ind).date);
            handles.includedData(ind).embryoNumber = num2str(handles.includedData(ind).embryoNumber);
            if ischar(handles.includedData(ind).kymPosition)
                handles.includedData(ind).kymPosition = str2double(handles.includedData(ind).kymPosition);
            end
            if ischar(handles.includedData(ind).cutNumber)
                handles.includedData(ind).cutNumber = str2double(handles.includedData(ind).cutNumber);
            end
        end

        ids = {handles.includedData.ID};
        for ind = 1:length(ids)
            r  = regexp(ids{ind}, '-', 'split');
            ids2{ind} = sprintf('%s-%s-%s', r{1}, r{2}, r{3});
        end

        [~, ia, ic] = unique(ids2, 'stable');

        for ind = 1:max(ic)
            if ischar(handles.includedData(ia(ind)).thisSideDamaged)
                if strcmp(handles.includedData(ia(ind)).thisSideDamaged, 'yes')
                    handles.damagedSideList{ind} = handles.includedData(ia(ind)).direction;
                    out = 'yes';
                elseif strcmp(handles.includedData(ia(ind)).thisSideDamaged, 'no')
                    ud = {'up' 'down'};
                    handles.damagedSideList{ind} = ud{~strcmp(ud, handles.includedData(ia(ind)).direction)};
                    out = 'no';
                else
                    handles.damagedSideList{ind} = [];
                    out = '';
                end
            elseif isnan(handles.includedData(ia(ind)).thisSideDamaged)
                handles.damagedSideList{ind} = [];
                out = '';
            end

            % then update included data to ensure consistency...
            % hacky and horribly slow
            temp = strcmp({handles.includedData.ID}, [ids2{ia(ind)} '-' handles.includedData(ia(ind)).direction]);
            for nind = 1:length(temp)
                if temp(nind)
                    handles.includedData(nind).thisSideDamaged = out;
                end
            end

        end

        % update to show damage side icon for current view
        showDamageIcon(handles.damagedSideList(get(handles.listData, 'Value')), handles)   

        directions = {'up' 'down'};
        for hind = 1:2
            handles.qcColor{hind} = generateQCColorArray(handles, handles.qcColor{hind}, directions{hind});
            updateMyScatterColors(handles.qcScatter{hind}, handles.qcColor{hind});
        end

        set(handles.menuUpdateAllSpeeds, 'Enable', 'on');
    end
end

busyDlg(busyOutput);

guidata(hObject, handles);


% --------------------------------------------------------------------
function menuAbout_Callback(hObject, eventdata, handles)
% hObject    handle to menuAbout (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

msgbox(sprintf('Software version: %0.1f', handles.softwareVersion), 'About', 'help');



% --------------------------------------------------------------------
function menuFitType_Callback(hObject, eventdata, handles)
% hObject    handle to menuFitType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuLinearFit_Callback(hObject, eventdata, handles)
% hObject    handle to menuLinearFit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('lin fit');
if strcmp(get(hObject, 'Checked'), 'off')
    set(hObject, 'Checked', 'on');
    set(handles.menuExpFit, 'Checked', 'off');
    
    handles.linTexpF = true;
    
    guidata(hObject, handles);
    
    callback = get(handles.listData, 'Callback');
    callback(handles.listData, []);
    
end
    


% --------------------------------------------------------------------
function menuExpFit_Callback(hObject, eventdata, handles)
% hObject    handle to menuExpFit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('exp fit');
if strcmp(get(hObject, 'Checked'), 'off')
    set(hObject, 'Checked', 'on');
    set(handles.menuLinearFit, 'Checked', 'off');
    
    handles.linTexpF = false;
    
    guidata(hObject, handles);
    
    callback = get(handles.listData, 'Callback');
    callback(handles.listData, []);
    
end


% --------------------------------------------------------------------
function menuViewerOptions_Callback(hObject, eventdata, handles)
% hObject    handle to menuViewerOptions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --------------------------------------------------------------------
function menuManualSpeedDetermination_Callback(hObject, eventdata, handles)
% hObject    handle to menuManualSpeedDetermination (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuSaveManualSpeed_Callback(hObject, eventdata, handles)
% hObject    handle to menuSaveManualSpeed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isfield(handles, 'manualLine')
   
    if gca == handles.axUpSelectedKym
        direction = 'up';
        ax = 1;
    else
        direction = 'down';
        ax = 2;
    end

   pos = handles.manualLine.getPosition;
   handles.currentManualLineSpeed = (pos(1,2) - pos(2,2))/(pos(1,1) - pos(2,1));
   
   indices = checkIfStored(handles, direction);
   if sum(indices) > 0
      handles.includedData(indices(1)).manualSpeed = handles.currentManualLineSpeed;
   end
   
   id = [handles.date '-' handles.embryoNumber '-' handles.cutNumber '-' direction '-' handles.currentKymInd];
   
   handles.manualSpeeds = [handles.manualSpeeds; {id handles.currentManualLineSpeed}];
   
end

guidata(hObject, handles)


% --------------------------------------------------------------------
function menuPreCutExport_Callback(hObject, eventdata, handles)
% hObject    handle to menuPreCutExport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmp(get(handles.menuZoomToggle, 'Checked'), 'on')
    zoomState = true;
else
    zoomState = false;
end
% 
% if zoomState
%     set(handles.menuPreCutExportLabels, 'Enable', 'on');
% else
%     set(handles.menuPreCutExportLabels, 'Enable', 'off');
% end

%for now, only allow export of full size image...
if ~zoomState
    set(handles.menuPreCutExportLabels,'Enable', 'off');
    set(handles.menuPreCutExportNoLabels, 'Enable', 'on');
else
    set(handles.menuPreCutExportLabels,'Enable', 'off');
    set(handles.menuPreCutExportNoLabels, 'Enable', 'off');
end

% --------------------------------------------------------------------
function menuPreCutExportLabels_Callback(hObject, eventdata, handles)
% hObject    handle to menuPreCutExportLabels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuPreCutExportNoLabels_Callback(hObject, eventdata, handles)
% hObject    handle to menuPreCutExportNoLabels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% start busy
busyOutput = busyDlg();

pname = uigetdir(handles.baseFolder, 'Choose a folder to save figures...');

if pname

    ax = gca;
    newfh = figure('Visible', 'off');
    newax = copyobj(ax, newfh);
    T = get(newax, 'TightInset');
%     set(newax, 'Position', [T(1) T(2) 1-T(1)-T(3) 1-T(2)-T(4)]);
    set(newfh, 'Units', 'normalized');
    set(newax, 'OuterPosition', [0 0 1 1]);
    axis equal tight;
    colormap gray;
    txth = findobj(newax, 'Type', 'Text');
    
    % get rid of labels if they exist
    if ~isempty(txth)
        delete(txth);
    end

%     dtstr = datestr(now);
%     dtstr = regexprep(dtstr,':','_');

    if ax == handles.axUpFirstFrame
        direction = 'up';
        ind = 1;
    else
        direction = 'down';
        ind = 2;
    end
    
    fname = ['Pre-cut figure, scalebar=20um, ' handles.date '-E' handles.embryoNumber '-C' handles.cutNumber '-' direction];
    set(newfh, 'Name', fname);

    set(newfh, 'Color', [1 1 1]);
    
    savefig(newfh, [pname filesep fname '.fig']);
    set(gcf,'PaperPositionMode','auto');
    set(gcf,'InvertHardcopy','off')

    print(newfh, [pname filesep fname '.png'], '-dpng', '-r600', '-loose');
    
    %get rid of scalebar if it exists...
    
    % zoom in...
    zBox = handles.zoomBoxLTBR(ind,:);
    padding=round(5/handles.umPerPixel);
    set(newax, 'XLim', [max(zBox(1)-padding,1) min(zBox(3)+padding,512)]);
    set(newax, 'YLim', [max(zBox(2)-padding,1) min(zBox(4)+padding,512)]);
    
    % add new scale bar...
    scx = [min(zBox(3)+padding,512) - 10 - padding   min(zBox(3)+padding,512) - 10];
    scy = [min(zBox(4)+padding,512)-10 min(zBox(4)+padding,512)-10];
    scline = line(scx, scy, 'Color', 'w', 'LineWidth',3);
    fname = ['Cropped pre-cut figure, scalebar=5um, ' handles.date '-E' handles.embryoNumber '-C' handles.cutNumber '-' direction];
    set(newfh, 'Name', fname);
    
    savefig(newfh, [pname filesep fname '.fig']);
    set(gcf,'PaperPositionMode','auto');
    set(gcf,'InvertHardcopy','off')

    print(newfh, [pname filesep fname '.png'], '-dpng', '-r600', '-loose');

    close(newfh);
    
end

busyDlg(busyOutput);


% --------------------------------------------------------------------
function menuSetLineThickness_Callback(hObject, eventdata, handles)
% hObject    handle to menuSetLineThickness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

prompt = 'Line width for kymograph axis thickness:';
dlg_title = 'Set line width...';
num_lines = 1;
default_val = num2str(handles.kymAxisThickness);
answer = inputdlg(prompt, dlg_title, num_lines, {default_val});

handles.kymAxisThickness = str2double(answer);

axs = {handles.axUpFirstFrame; handles.axDownFirstFrame};

for ax_ind = 1:length(axs)
    cut_line = findobj('Parent', axs{ax_ind}, 'type', 'line', 'Color', 'b');
    kym_lines = findobj('Parent', axs{ax_ind}, 'type', 'line', 'Color', 'r');

    for kl_ind = 1:length(kym_lines)

        set(kym_lines(kl_ind), 'LineWidth', handles.kymAxisThickness);

    end
    
    set(cut_line, 'LineWidth', round((3/2) * handles.kymAxisThickness));
end

guidata(hObject, handles);

function edgeSide = upperOrLowerEdge(paddedMembrane, kymograph)

% compare mean pixel values above and below the edge all the way along, and
% choose which edge by which has more brighter sides - this is better than
% comparing averages of all pixels above/below since it will deal better
% with anomalously high pixels. 

upperEdge = 0;
lowerEdge = 0;
isEdge = sum(paddedMembrane,1);

for j = 1:size(paddedMembrane, 2)
    
    if isEdge(j) > 0
        
        col = paddedMembrane(:,j);
        edgeVertPos = find(col);
        
        upperAverage = mean(kymograph((max(1, edgeVertPos - 5)):edgeVertPos,j));
        lowerAverage = mean(kymograph(edgeVertPos:min(size(kymograph,1),edgeVertPos + 5),j));
        
        if upperAverage > lowerAverage
            lowerEdge = lowerEdge + 1;
        else
            upperEdge = upperEdge + 1;
        end
        
    end
    
end

if upperEdge > lowerEdge
    edgeSide = 'upper';
else
    edgeSide = 'lower';
end


% --------------------------------------------------------------------
function menuExport_Callback(hObject, eventdata, handles)
% hObject    handle to menuExport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function handles = menuIncludeNoise_Callback(hObject, eventdata, handles)
% hObject    handle to menuIncludeNoise (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Return warning/break if metadata hasn't been loaded yet...
if ~isfield(handles, 'experimentMetadata')
    msgbox('You need to load metadata before trying to include data for export!');
    return;
end

%% clear other checkboxes
menuHs = get(get(hObject, 'Parent'), 'Children');
for menuH = menuHs
    set(menuH, 'Checked', 'off');
end
set(hObject, 'Checked', 'on');

if gca == handles.axUpSelectedKym
    direction = 'up';
    ax = 1;
else
    direction = 'down';
    ax = 2;
end

handles = genericInclude(handles, get(hObject, 'Label'), direction, handles.currentPosition);

% Make this bit verbose for greater accessbility later...
if strcmp(get(hObject, 'Label'), 'Misassigned edge')
    set(handles.kymTitle{ax}, 'BackgroundColor', [0 1 1]);
elseif strcmp(get(hObject, 'Label'), 'Noise')
    set(handles.kymTitle{ax}, 'BackgroundColor', [1 0 0]);
elseif strcmp(get(hObject, 'Label'), 'Good')
    set(handles.kymTitle{ax}, 'BackgroundColor', [0 1 0]);
elseif strcmp(get(hObject, 'Label'), 'Manual')
    set(handles.kymTitle{ax}, 'BackgroundColor', [0 0 1]);
end

handles.qcColor{ax} = generateQCColorArray(handles, handles.qcColor{ax}, direction);
updateMyScatterColors(handles.qcScatter{ax}, handles.qcColor{ax});

guidata(hObject, handles);

% --------------------------------------------------------------------
function handles = menuIncludeMisassigned_Callback(hObject, eventdata, handles)
% hObject    handle to menuIncludeMisassigned (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Return warning/break if metadata hasn't been loaded yet...
if ~isfield(handles, 'experimentMetadata')
    msgbox('You need to load metadata before trying to include data for export!');
    return;
end

%% clear other checkboxes
menuHs = get(get(hObject, 'Parent'), 'Children');
for menuH = menuHs
    set(menuH, 'Checked', 'off');
end
set(hObject, 'Checked', 'on');

if gca == handles.axUpSelectedKym
    direction = 'up';
    ax = 1;
else
    direction = 'down';
    ax = 2;
end

handles = genericInclude(handles, get(hObject, 'Label'), direction, handles.currentPosition);

% Make this bit verbose for greater accessbility later...
if strcmp(get(hObject, 'Label'), 'Misassigned edge')
    set(handles.kymTitle{ax}, 'BackgroundColor', [0 1 1]);
elseif strcmp(get(hObject, 'Label'), 'Noise')
    set(handles.kymTitle{ax}, 'BackgroundColor', [1 0 0]);
elseif strcmp(get(hObject, 'Label'), 'Good')
    set(handles.kymTitle{ax}, 'BackgroundColor', [0 1 0]);
elseif strcmp(get(hObject, 'Label'), 'Manual')
    set(handles.kymTitle{ax}, 'BackgroundColor', [0 0 1]);
end

handles.qcColor{ax} = generateQCColorArray(handles, handles.qcColor{ax}, direction);
updateMyScatterColors(handles.qcScatter{ax}, handles.qcColor{ax});

guidata(hObject, handles);


% --------------------------------------------------------------------
function menuHelp_Callback(hObject, eventdata, handles)
% hObject    handle to menuHelp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function showDamageIcon(direction, handles)

if strcmp(direction, 'up')
    imagesc(handles.laserIcon, 'Parent', handles.axUpDamage);
    axis(handles.axUpDamage, 'image');
    set(handles.axUpDamage, 'XTick', [], 'YTick', [], 'Color', 'none');
    cla(handles.axDownDamage, 'reset');
    set(handles.axDownDamage, 'XTick', [], 'YTick', [], 'Color', 'none');
    disp(get(handles.axDownDamage, 'XColor'));
elseif strcmp(direction, 'down')
    imagesc(handles.laserIcon, 'Parent', handles.axDownDamage);
    axis image;
    set(handles.axDownDamage, 'XTick', [], 'YTick', [], 'Color', 'none');
    cla(handles.axUpDamage, 'reset');
    set(handles.axUpDamage, 'XTick', [], 'YTick', [], 'Color', 'none');
else
    cla(handles.axUpDamage, 'reset');
    set(handles.axUpDamage, 'XTick', [], 'YTick', [], 'Color', 'none');
    cla(handles.axDownDamage, 'reset');
    set(handles.axDownDamage, 'XTick', [], 'YTick', [], 'Color', 'none');
end


% --------------------------------------------------------------------
function menuIncludeManual_Callback(hObject, eventdata, handles)
% hObject    handle to menuIncludeManual (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% hObject    handle to menuIncludeMisassigned (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Return warning/break if metadata hasn't been loaded yet...
if ~isfield(handles, 'experimentMetadata')
    msgbox('You need to load metadata before trying to include data for export!');
    return;
end

%% clear other checkboxes
menuHs = get(get(hObject, 'Parent'), 'Children');
for menuH = menuHs
    set(menuH, 'Checked', 'off');
end
set(hObject, 'Checked', 'on');

if strcmp(handles.currentDir, 'up')
    direction = 'up';
    ax = 1;
else
    direction = 'down';
    ax = 2;
end

handles = genericInclude(handles, get(hObject, 'Label'), direction, handles.currentPosition);

% Make this bit verbose for greater accessbility later...
if strcmp(get(hObject, 'Label'), 'Misassigned edge')
    set(handles.kymTitle{ax}, 'BackgroundColor', [0 1 1]);
elseif strcmp(get(hObject, 'Label'), 'Noise')
    set(handles.kymTitle{ax}, 'BackgroundColor', [1 0 0]);
elseif strcmp(get(hObject, 'Label'), 'Good')
    set(handles.kymTitle{ax}, 'BackgroundColor', [0 1 0]);
elseif strcmp(get(hObject, 'Label'), 'Manual')
    set(handles.kymTitle{ax}, 'BackgroundColor', [0 0 1]);
end

handles.qcColor{ax} = generateQCColorArray(handles, handles.qcColor{ax}, direction);
updateMyScatterColors(handles.qcScatter{ax}, handles.qcColor{ax});

guidata(hObject, handles);


% --------------------------------------------------------------------
function menuUpdateAllSpeeds_Callback(hObject, eventdata, handles)
% hObject    handle to menuUpdateAllSpeeds (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% start busy
busyOutput = busyDlg();

ids = {handles.includedData.ID};

for id = unique(ids)
    
    filt = ~strcmp({handles.includedData.userQCLabel}, 'no edge') & ...
    ~strcmp({handles.includedData.userQCLabel}, 'not QCd') & ...
    strcmp(ids, id);

    if sum(filt) > 0
        lines = handles.includedData(filt);
        fpath = [handles.baseFolder filesep ...
            lines(1).date ', Embryo ' lines(1).embryoNumber ' ' lines(1).direction 'wards' filesep ...
            lines(1).date ', Embryo ' lines(1).embryoNumber ', Cut ' num2str(lines(1).cutNumber) ...
            ', Speed against cut position ' lines(1).direction 'wards'];
        
        h = openfig(fpath, 'new', 'invisible');
        ax = get(h, 'Children');
        dataObjs = get(ax, 'Children');
        speeds = get(dataObjs, 'YData');
        poss = get(dataObjs, 'XData');
        close(h);
        
        baseFolder2 = [handles.baseFolder filesep handles.date ', Embryo ' handles.embryoNumber];
        folder = [baseFolder2 ' downwards'];
        mdfpath = [handles.baseFolder filesep ...
            lines(1).date ', Embryo ' lines(1).embryoNumber ' ' lines(1).direction 'wards' filesep ...
            filesep 'trimmed_cutinfo_cut_' handles.cutNumber '.txt'];
        x1 = getNumericMetadataFromText(mdfpath, 'metadata.cutMetadata.startPositionX');
        x2 = getNumericMetadataFromText(mdfpath, 'metadata.cutMetadata.stopPositionX');
        y1 = getNumericMetadataFromText(mdfpath, 'metadata.cutMetadata.startPositionY');
        y2 = getNumericMetadataFromText(mdfpath, 'metadata.cutMetadata.stopPositionY');
        cutLength = sqrt( (x1 - x2)^2 + (y1 - y2)^2 ) * handles.umPerPixel;
        cutDuration = getNumericMetadataFromText(mdfpath, 'metadata.cutMetadata.time');
        
        for ind = 1:length(poss)
            filt2 = ~strcmp({handles.includedData.userQCLabel}, 'no edge') & ...
                ~strcmp({handles.includedData.userQCLabel}, 'not QCd') & ...
                strcmp(ids, id) & (round(100 * [handles.includedData.kymPosition]) == round( 100 * poss(ind)));
            if sum(filt2) > 0
                handles.includedData(filt2).speed = speeds(ind);
                handles.includedData(filt2).cutLength = cutLength;
                handles.includedData(filt2).cutDuration = cutDuration;
            end
        end
        
    end

end
    
busyDlg(busyOutput);
guidata(hObject, handles);    

% -------------------------------------------------------------------------
function saveTempVars(handles)

tDir = handles.tempFilePath;
if tDir(end) ~= filesep
    tDir = [tDir filesep];
end
ts = strrep(handles.initTimeStamp, ':', '_');
save([tDir ts ' viewerMainTempVars.mat'], 'handles');



% --------------------------------------------------------------------
function menuRescue_Callback(hObject, eventdata, handles)
% hObject    handle to menuRescue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[varsfname, varspname] = uigetfile('*.mat', 'Choose temp vars file...', tempdir);

% stop if cancel clicked
if isequal(varsfname, 0)
    return;
end

temp = load([varspname filesep varsfname]);

currentIncDataStore = handles.includedData;
handles.includedData = temp.handles.includedData;

exportWizard_Callback(hObject, eventdata, handles);

handles.includedData = currentIncDataStore;


% --------------------------------------------------------------------
function menuGeomMidline_Callback(hObject, eventdata, handles)
% hObject    handle to menuGeomMidline (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
determineGeometricalMidline(handles);

function determineGeometricalMidline(handles)

% check whether inclusion data exists for this data
position = handles.positionsAlongLine(1);
indices = checkIfStored(handles, 'up', position);
if sum(indices > 0)
    uiwait(geometricalMidlineRotation(handles));
    geometricalMidlineBasalSurfaceDrawing(handles);
    geometricalMidlineClassificationAndExport(handles);
else
    msgbox('No inclusion data present for this cut!');
end

function hFig = geometricalMidlineBasalSurfaceDrawing(handles)
% function that takes rotated image, windows it according to (rotated) cut
% axis and prompts the user to draw first one basal surface then tother. 

handles = guidata(handles.figure1);
% rotate image, cut line and patch showing where 'up' kymographs lie...
theta = -degtorad(handles.rotationAngle);
rotMat = [cos(theta) -sin(theta);...
    sin(theta) cos(theta)];

% do verbose to check everything is working properly....
a = [handles.cut_line_x(1); handles.cut_line_y(1)] - size(handles.rotationI)'/2;
b = rotMat * a;
c = size(handles.rotationI)'/2 + b;
a2 = [handles.cut_line_x(2); handles.cut_line_y(2)] - size(handles.rotationI)'/2;
b2 = rotMat * a2;
c2 = size(handles.rotationI)'/2 + b2;

rot_cut_x = [c(1) c2(1)];
rot_cut_y = [c(2) c2(2)];

handles.rotationI = imrotate(handles.rotationI, handles.rotationAngle, 'crop');

handles.basalDrawingFig = figure('menu','none', 'Units', 'normalized',...
    'Position', [0.05 0.05 0.9 0.9], ...
    'Name', 'Draw the first basal membrane...', ...
    'NumberTitle', 'off');
    hFig = handles.basalDrawingFig;
handles.hAx = axes('Parent',handles.hFig);
imagesc(handles.rotationI, 'Parent', handles.hAx);
set(handles.hAx, 'XTick', [], 'YTick', []);
axis equal tight; 
colormap gray; 
h_cutline = line(rot_cut_x, rot_cut_y, 'Parent', handles.hAx, ...
    'MarkerEdgeColor', 'g', 'LineWidth', 2, 'LineStyle', 'none', ...
    'MarkerSize', 10, 'Marker', '+');
set(handles.hAx, 'XLim', [1 size(handles.rotationI, 2)], ...
    'YLim', [min(rot_cut_y) - 0.2 * (max(rot_cut_y) - min(rot_cut_y)) ...
    max(rot_cut_y) + 0.2 * (max(rot_cut_y) - min(rot_cut_y))]);
guidata(gcf, handles);  
tempLine1 = line([1 size(handles.rotationI, 2)], ...
    [max(rot_cut_y) + 0.1 * (max(rot_cut_y) - min(rot_cut_y)) ...
    max(rot_cut_y) + 0.1 * (max(rot_cut_y) - min(rot_cut_y))], 'Color', 'r', ...
    'LineStyle', '--');
tempLine2 = line([1 size(handles.rotationI, 2)], ...
    [min(rot_cut_y) - 0.1 * (max(rot_cut_y) - min(rot_cut_y)) ...
    min(rot_cut_y) - 0.1 * (max(rot_cut_y) - min(rot_cut_y))], 'Color', 'r', ...
    'LineStyle', '--');

% to achieve correct fits, need to fit data such that y is independent var
M1 = imfreehand('Closed', false);
P01 = M1.getPosition;
P01(P01(:,2) > ( max(rot_cut_y) + 0.1 * (max(rot_cut_y) - min(rot_cut_y))), :) = [];
P01(P01(:,2) < ( min(rot_cut_y) - 0.1 * (max(rot_cut_y) - min(rot_cut_y))), :) = [];
l1 = fit(P01(:,2), P01(:,1), 'poly1');

    yf1 = [min(P01(:,2)) max(P01(:,2))];
    xf1 = l1.p1.*yf1 + l1.p2;

hl1 = line(xf1, yf1, 'Color', 'r', 'LineWidth', 1.5);

set(handles.basalDrawingFig, 'Name', 'Draw the second basal membrane...');
M2 = imfreehand('Closed', false);
P02 = M2.getPosition;
P02(P02(:,2) > ( max(rot_cut_y) + 0.1 * (max(rot_cut_y) - min(rot_cut_y))), :) = [];
P02(P02(:,2) < ( min(rot_cut_y) - 0.1 * (max(rot_cut_y) - min(rot_cut_y))), :) = [];
l2 = fit(P02(:,2), P02(:,1), 'poly1');
    
    yf2 = [min(P02(:,2)) max(P02(:,2))];
    xf2 = l2.p1.*yf2 + l2.p2;

hl2 = line(xf2, yf2, 'Color', 'r', 'LineWidth', 1.5); 

hgml = line( (xf1 + xf2)/2, (yf1 + yf2)/2, 'Color', 'g', 'LineWidth', 1.5);

% show full image
set(handles.hAx, 'XLim', [1 size(handles.rotationI, 2)], ...
    'YLim', [1 size(handles.rotationI, 1)]);

% overlay patch that designated "up" direction
% "up" lines are held in first row of kymLines structure
set(handles.basalDrawingFig,...
    'Name', ...
    sprintf('Figure showing fitted geometrical midline and patch showing "up" direction: %s_E%sC%s',...
    handles.date, handles.embryoNumber, handles.cutNumber));
kymLines = [get(handles.kymLines(1,1)); get(handles.kymLines(1,end))];
X = [kymLines(1).XData fliplr(kymLines(2).XData)];
Y = [kymLines(1).YData fliplr(kymLines(2).YData)];

hp = patch(X, Y, 'r', 'EdgeColor', 'r', 'FaceAlpha', 0.05);
origin = [size(handles.rotationI)/2 0];
ax = [0 0 1];
rotate(hp, ax, -handles.rotationAngle, origin);

delete(tempLine1);
delete(tempLine2);

guidata(handles.figure1, handles);


function geometricalMidlineClassificationAndExport(handles)

handles = guidata(handles.figure1);
% Prompt user to classify which side is longer
answer = questdlg(sprintf('Cells on "up" side are...? \n\n Close this window to discard'), ...
    'Classify results...', ...
    'Longer', 'Shorter', 'Neither', ...
    'Neither');

if ~isempty(answer)
    
    % Save tiff of image
    [fname, pname] = uiputfile('*.png', ...
        'Choose location to save classification image...', ...
        [handles.baseFolder filesep strrep(datestr(now), ':', '') ' geometrical midline classification ' ...
        sprintf('%s_E%sC%s', handles.date, handles.embryoNumber, handles.cutNumber) '.png']);

    if (fname ~= 0) 
        print(handles.basalDrawingFig, [pname fname], '-dpng', '-r300');
        savefig(gcf, [pname fname '.fig']);
    end

    % Fill in inclusion data accordingly
    filt = strcmp({handles.includedData.date}, handles.date) & ...
        strcmp({handles.includedData.embryoNumber}, handles.embryoNumber) &...
        ([handles.includedData.cutNumber] == str2double(handles.cutNumber)) & ...
        strcmp({handles.includedData.direction}, 'up');
    filt2 = strcmp({handles.includedData.date}, handles.date) & ...
        strcmp({handles.includedData.embryoNumber}, handles.embryoNumber) &...
        ([handles.includedData.cutNumber] == str2double(handles.cutNumber)) & ...
        strcmp({handles.includedData.direction}, 'down');
    switch answer
        case 'Longer'
            handles.currentLongerSide = 'up';
            for ind = find(filt)
                handles.includedData(ind).thisSideLonger = 'yes';
            end
            for ind = find(filt2)
                handles.includedData(ind).thisSideLonger = 'no';
            end
        case 'Shorter'
            handles.currentLongerSide = 'down';
            for ind = find(filt)
                handles.includedData(ind).thisSideLonger = 'no';
            end
            for ind = find(filt2)
                handles.includedData(ind).thisSideLonger = 'yes';
            end
        case 'Neither'
            handles.currentLongerSide = 'neither';
            for ind = find(filt)
                handles.includedData(ind).thisSideLonger = 'equal';
            end
            for ind = find(filt2)
                handles.includedData(ind).thisSideLonger = 'equal';
            end
        otherwise
            handles.currentLongerSide = [];
    end   
    
end

close(handles.basalDrawingFig);
guidata(gcf, handles);  


function hFig = geometricalMidlineRotation(handles)
% function which generates a figure prompting for rotation of the image so
% that anterior-posterior axis lies vertically. 
    
handles.rotationI = getimage(handles.axUpFirstFrame);

% setup GUI 
handles.hFig = figure('menu','none', 'Units', 'normalized',...
    'Position', [0.05 0.05 0.9 0.9], ...
    'Name', 'Rotate until the anterior-posterior axis is vertical...', ...
    'NumberTitle', 'off');
hFig = handles.hFig;
handles.hAx = axes('Parent',handles.hFig);
handles.hSlider = uicontrol('Parent', handles.hFig, 'Style','slider', 'Value',0, 'Min',0,...
    'Max',360, 'SliderStep',[1 5]./360, ...
    'Units', 'normalized', ...
    'Position',[0.3 0.01 0.4 0.05], 'Callback',@geoMidlineRotationSlider);
uicontrol('Style', 'pushbutton', 'Units', 'normalized',...
    'Position', [0.8 0.01 0.1 0.05], 'String', 'Done rotating!', ...
    'Callback', @geoMidlineRotationButton);
handles.hEdit = uicontrol('Style', 'Edit', 'Units', 'normalized', ... 
    'Position', [0.7 0.01 0.1 0.05], 'String', '0', ...
    'Callback', @geoMidlineRotationText);
imagesc(handles.rotationI, 'Parent', handles.hAx);
set(handles.hAx, 'XTick', [], 'YTick', []);
axis equal tight; 
colormap gray; 
handles.rotationAngle = 0;
rotCutLine = line(handles.cut_line_x, handles.cut_line_y, 'Parent', handles.hAx, ...
    'MarkerEdgeColor', 'g', 'LineWidth', 2, 'LineStyle', 'none', ...
    'MarkerSize', 10, 'Marker', '+');
vertLine = line([size(handles.rotationI,2)/2 size(handles.rotationI,2)/2], ...
    [1 size(handles.rotationI,1)], 'Color', 'r', 'LineStyle', '--');
guidata(gcf, handles);  

function geoMidlineRotationButton(hObject, eventdata, handles)

handles = guidata(hObject); 
guidata(handles.figure1, handles);
close(handles.hFig);

function geoMidlineRotationText(hObject, eventdata, handles)

handles = guidata(hObject);
try
    % bring angle into range [0, 360]
    th = round(str2double(get(hObject, 'String')));
    th = rem(th, 360);
    if th < 0
        th = 360 + th;
    end
    set(hObject, 'String', num2str(th));
    handles.rotationAngle = th;
    set(handles.hSlider, 'Value', handles.rotationAngle);
    imagesc(imrotate(handles.rotationI, handles.rotationAngle, 'crop'), 'Parent', handles.hAx);
    set(handles.hAx, 'XTick', [], 'YTick', []);
    axis equal tight; 
    colormap gray;
    rotCutLine = line(handles.cut_line_x, handles.cut_line_y, 'Parent', handles.hAx, ...
    'MarkerEdgeColor', 'g', 'LineWidth', 2, 'LineStyle', 'none', ...
        'MarkerSize', 10, 'Marker', '+');
    origin = [size(handles.rotationI)/2 0];
    ax = [0 0 1];
    rotate(rotCutLine, ax, -handles.rotationAngle, origin);
    vertLine = line([size(handles.rotationI,2)/2 size(handles.rotationI,2)/2], ...
    [1 size(handles.rotationI,1)], 'Color', 'r', 'LineStyle', '--');
catch
    set(hObject, 'String', num2str(handles.rotationAngle));
end
guidata(gcf, handles);
    

function geoMidlineRotationSlider(hObject, eventdata, handles)

handles = guidata(hObject);
handles.rotationAngle = round(get(hObject, 'Value'));
set(handles.hEdit, 'String', num2str(handles.rotationAngle));
imagesc(imrotate(handles.rotationI, handles.rotationAngle, 'crop'), 'Parent', handles.hAx);
set(handles.hAx, 'XTick', [], 'YTick', []);
axis equal tight; 
colormap gray; 
rotCutLine = line(handles.cut_line_x, handles.cut_line_y, 'Parent', handles.hAx, ...
    'MarkerEdgeColor', 'g', 'LineWidth', 2, 'LineStyle', 'none', ...
    'MarkerSize', 10, 'Marker', '+');
origin = [size(handles.rotationI)/2 0];
ax = [0 0 1];
rotate(rotCutLine, ax, -handles.rotationAngle, origin);
vertLine = line([size(handles.rotationI,2)/2 size(handles.rotationI,2)/2], ...
    [1 size(handles.rotationI,1)], 'Color', 'r', 'LineStyle', '--');

guidata(gcf, handles);


% --------------------------------------------------------------------
function menuCompareMidlines_Callback(hObject, eventdata, handles)
% hObject    handle to menuCompareMidlines (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
compareMidlines(handles);


function compareMidlines(handles)
% check whether inclusion data exists for this data
position = handles.positionsAlongLine(1);
indices = checkIfStored(handles, 'up', position);
if sum(indices > 0)
    uiwait(geometricalMidlineRotation(handles));
    geometricalMidlineBasalSurfaceDrawing(handles);
    actualMidlineDrawing(handles);
else
    msgbox('No inclusion data present for this cut!');
end


function actualMidlineDrawing(handles)

% hide all aspects of the figure apart from the image data
handles = guidata(handles.figure1);
kids = get(handles.hAx, 'Children');
types = get(kids, 'Type');
set(kids(~strcmp(types, 'image')), 'Visible', 'off');

% window the axes so that only the relevant part of the embryo is shown
cutLine = get(kids(end-1));
xs = round(cutLine.XData);
ys = round(cutLine.YData);
set(handles.hAx, 'XLim', [1 size(handles.rotationI, 2)], ...
    'YLim', [(min(ys) - 0.2 * (max(ys) - min(ys))) ...
    (max(ys) +  0.2 * (max(ys) - min(ys)))]);
tempLine1 = line([1 size(handles.rotationI, 2)], ...
    [max(ys) + 0.1 * (max(ys) - min(ys)) ...
    max(ys) + 0.1 * (max(ys) - min(ys))], 'Color', 'r', ...
    'LineStyle', '--');
tempLine2 = line([1 size(handles.rotationI, 2)], ...
    [min(ys) - 0.1 * (max(ys) - min(ys)) ...
    min(ys) - 0.1 * (max(ys) - min(ys))], 'Color', 'r', ...
    'LineStyle', '--');

% draw the actual midline
set(handles.basalDrawingFig, 'Name', 'Draw actual midline...');
M = imfreehand('Closed', false);

% interpolate along the drawn midline and the previously determined
% geometrical midline, taking 100 points to assess mean and sd in offset
% between the two
realMidline = M.getPosition;
realMidlineX = realMidline(:,1);
realMidlineY = realMidline(:,2);
geoMidlineX = get(kids(2), 'XData');
geoMidlineY = get(kids(2), 'YData');
m = (geoMidlineY(1) - geoMidlineY(2))/(geoMidlineX(1) - geoMidlineX(2));
c = geoMidlineY(1) - m * geoMidlineX(1);

% % first, trim any overhang on the line that extends furtherst up...
% if max(realMidlineY) > max(geoMidlineY)
%     realMidlineX(realMidlineY > max(geoMidlineY)) = [];
%     realMidlineY(realMidlineY > max(geoMidlineY)) = [];
% else
%     geoMidlineX(geoMidlineY == max(geoMidlineY)) = (max(realMidlineY) - c) / m;
%     geoMidlineY(geoMidlineY == max(geoMidlineY)) = max(realMidlineY);
% end 
% 
% % then trim the any overhang from the line that extends furthest down...
% if min(realMidlineY) < min(geoMidlineY)
%     realMidlineX(realMidlineY < min(geoMidlineY)) = [];
%     realMidlineY(realMidlineY < min(geoMidlineY)) = [];
% else
%     geoMidlineX(geoMidlineY == min(geoMidlineY)) = (min(realMidlineY) - c) / m;
%     geoMidlineY(geoMidlineY == min(geoMidlineY)) = min(realMidlineY);
% end

% trim the real midline to the same y extent as the geometrical midline
realMidlineY(realMidlineY > ( max(ys) + 0.1 * (max(ys) - min(ys)))) = [];
realMidlineY(realMidlineY < ( min(ys) - 0.1 * (max(ys) - min(ys)))) = [];

% then interpolate the drawn line to give 100 points between the new limits
geoMidlineY = linspace(min(geoMidlineY), max(geoMidlineY), 100);
geoMidlineX = (geoMidlineY - c) ./ m;
[~,ia,~] = unique(realMidlineY);
realMidlineY = realMidlineY(ia);
realMidlineX = realMidlineX(ia);
realMidlineX = pchip(realMidlineY, realMidlineX, geoMidlineY);
realMidlineY = geoMidlineY;

% then calculate differences, mean and sd
handles.meanDifferenceGeometricalActualMidline = mean(realMidlineX - geoMidlineX) * handles.umPerPixel;
handles.sdDifferenceGeometricalActualMidline = std(realMidlineX - geoMidlineX) * handles.umPerPixel;

% Fill in inclusion data accordingly
filt = strcmp({handles.includedData.date}, handles.date) & ...
    strcmp({handles.includedData.embryoNumber}, handles.embryoNumber) &...
    ([handles.includedData.cutNumber] == str2double(handles.cutNumber));

for ind = find(filt)
    handles.includedData(ind).meanDifferenceGeometricalActualMidline = ...
        handles.meanDifferenceGeometricalActualMidline;
    handles.includedData(ind).sdDifferenceGeometricalActualMidline = ...
        handles.sdDifferenceGeometricalActualMidline;
end

delete(tempLine1);
delete(tempLine2);

guidata(handles.figure1, handles);
% close(hFig);

% sanity check - show real and geometrical midline overlaid on same image
set(handles.basalDrawingFig, 'Name', 'User-defined "real" midline in red, geometrical midline in green');
set(handles.hAx, 'XLim', [1 size(handles.rotationI, 2)], ...
    'YLim', [1 size(handles.rotationI, 1)]);
set(kids(2), 'Visible', 'on');
line(realMidlineX', realMidlineY', 'Color', 'r', 'LineWidth', 1.5);
delete(M);
% Save tiff of image
[fname, pname] = uiputfile('*.png', ...
    'Choose location to save image...', ...
    [handles.baseFolder filesep strrep(datestr(now), ':', '') ' geometrical midline vs real midline ' ...
    sprintf('%s_E%sC%s', handles.date, handles.embryoNumber, handles.cutNumber) '.png']);

if (fname ~= 0) 
    print(handles.basalDrawingFig, [pname fname], '-dpng', '-r300');
end