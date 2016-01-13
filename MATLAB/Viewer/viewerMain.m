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

% Last Modified by GUIDE v2.5 10-Jan-2016 23:27:52

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

% Choose default command line output for viewerMain
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

funcPath = [pwd filesep '..'];
addpath(funcPath);

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

default_folder = 'C:\Users\Doug\Desktop\test';
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

    folders = dir([base_folder filesep '*upwards']);

    for fInd = 1:length(folders)

        s = dir([base_folder filesep folders(fInd).name filesep 'trimmed_cutinfo_cut_*.txt']);

        for cInd = 1:length(s)

            cutNumber = sscanf(s(cInd).name, 'trimmed_cutinfo_cut_%d.txt');
            ex = '(?<date>\d+), Embryo (?<embryoNumber>\w+) upwards';
            out = regexp(folders(fInd).name, ex, 'names');

            dataList = [dataList; cellstr(sprintf('Date = %s, Embryo = %s, Cut = %d', ...
                out.date, out.embryoNumber, cutNumber))];

        end

    end

    set(handles.listData, 'String', dataList);

    guidata(hObject, handles);

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

figFilePaths = [cellstr([handles.baseFolder filesep dt ', Embryo ' embryoNumber ' upwards' filesep dt ', Embryo ' embryoNumber ', Cut ' cutNumber ', Speed against cut position upwards.fig']);...
    cellstr([handles.baseFolder filesep dt ', Embryo ' embryoNumber ' downwards' filesep dt ', Embryo ' embryoNumber ', Cut ' cutNumber ', Speed against cut position downwards.fig'])];

handles.date = dt;
handles.cutNumber = cutNumber;
handles.embryoNumber = embryoNumber;

axHandles = [handles.axUpSpeedVPosition; handles.axDownSpeedVPosition]; 
titleAppendices = {'upwards'; 'downwards'};

% buttonDownFcns = {{@axUpSpeedVPosition_ButtonDownFcn, handles};...
%     {@axDownSpeedVPosition_ButtonDownFcn, handles}};

for ind = 1:length(axHandles)
    
    fpath = figFilePaths{ind};
    h = openfig(fpath, 'new', 'invisible');
    ax = get(h, 'Children');
    dataObjs = get(ax, 'Children');
    handles.speeds{ind} = get(dataObjs, 'YData');
    handles.poss{ind} = get(dataObjs, 'XData');
    
    handles.plotHandles{ind} = plot(axHandles(ind), handles.poss{ind}, handles.speeds{ind}, 'x-');
    xlab = 'Kymograph position along cut, \mum';
    ylab = 'Membrane speed, \mum s^{-1}';
    xlabel(axHandles(ind), xlab);
    ylabel(axHandles(ind), ylab);
    title(axHandles(ind), sprintf('%s, Embryo %s, Cut %s, %s', dt, embryoNumber, cutNumber, titleAppendices{ind}));
      
end

%% Get and plot first frames and relevant lines

figFilePaths = [cellstr([handles.baseFolder filesep dt ', Embryo ' embryoNumber ' upwards' filesep dt ', Embryo ' embryoNumber ', Cut ' cutNumber ', 5 s pre-cut upwards.fig']);...
    cellstr([handles.baseFolder filesep dt ', Embryo ' embryoNumber ' downwards' filesep dt ', Embryo ' embryoNumber ', Cut ' cutNumber ', 5 s pre-cut downwards.fig'])];

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
    line(cut_line_x, cut_line_y, 'Parent', axHandles(ind), 'Color', 'c', ...
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
            'Parent', axHandles(ind), 'Color', 'r', 'LineStyle', '--');
    end
    
    
    offset = handles.umPerPixel * sqrt((x(1,1) - cut_line_x(1))^2 + (y(1,1) - cut_line_y(1))^2);
    handles.positionsAlongLine = fliplr(-handles.umPerPixel * sqrt((x(1,end) - x(1,:)).^2 + (y(1,end) - y(1,:)).^2) + offset);
    handles.zoomBoxLTBR(ind,:) = [min(x(:)) min(y(:)) max(x(:)) max(y(:))];
    handles.kymLines(ind,:) = kym_lines;
    
    set(imH, 'UIContextMenu', handles.menuPreCutFig);
    set(handles.menuZoomToggle, 'Checked', 'off')
    
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
    kym_lines = handles.kymLines(ind,:);
    
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
set(handles.listData, 'Enable', 'on');
busyOutput = busyDlg();
set(handles.listData, 'Enable', 'off');
baseFolder2 = [handles.baseFolder filesep handles.date ', Embryo ' handles.embryoNumber];
    
if gca == handles.axUpSpeedVPosition
    ax = 1;
    appendText = ' upwards';
    kym_ax = handles.axUpSelectedKym;
    direction = 'up';
else
    ax = 2;
    appendText = ' downwards';
    kym_ax = handles.axDownSelectedKym;
    direction = 'down';
end

folder = [baseFolder2 appendText];

h = findobj('Parent', gca);

for ind = 1:length(h)
    if (get(h(ind), 'Color') == [1 0 0])
        delete(h(ind));
    end
end

a = get(gca, 'CurrentPoint');
xpos = a(1,1);
x = abs(handles.poss{ax} - xpos);

closest = find(x == min(x));

hold on
plot(handles.poss{ax}(closest), handles.speeds{ax}(closest), 'o', 'Color', 'r');
hold off

for kymInd = 1:length(handles.kymLines(ax,:))
    if kymInd == closest
        set(handles.kymLines(ax, closest), 'Color', 'g');
    else
        set(handles.kymLines(ax, kymInd), 'Color', 'r');
    end
end


%% Get relevant kymograph file and plot
filepath = [folder filesep 'trimmed_cutinfo_cut_' handles.cutNumber '.txt'];
pos_along_cut = getKymPosMetadataFromText(filepath);
kym_ind = find((round(100*pos_along_cut)/100) == (round(100*handles.poss{ax}(closest))/100)) - 2;
handles.currentKymInd = kym_ind;

fpath = [folder filesep handles.date ', Embryo ' handles.embryoNumber ...
    ', Cut ' handles.cutNumber ', Kymograph index along cut = ' num2str(kym_ind)...
    appendText '.fig'];
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

handles.currentPosition = handles.poss{ax}(closest);
handles.currentSpeed = handles.speeds{ax}(closest);

fpath = [folder filesep handles.date ', Embryo ' handles.embryoNumber ...
    ', Cut ' handles.cutNumber ', Kymograph index along cut = ' num2str(kym_ind)...
   ' - quantitative kymograph.fig'];
h = openfig(fpath, 'new', 'invisible');
fAx = get(h, 'Children');
dataObjs = get(fAx, 'Children');

% TODO: get data on frames/second from metadata
xoffset = (max(find(sum(im(:,25:30),1)==0))-2)*0.2;
y=get(dataObjs{1}(1), 'YData');
x=get(dataObjs{1}(1), 'XData');
x = x + xoffset;
x = [x(1) x(end)];
y = [y(1) y(end)];

set(handles.kymIm(ax), 'UIContextMenu', handles.menuSelectedKymFig);

% handles.kymIm(ax) = imH;

fitLineState = get(handles.menuOverlayFitLine, 'Checked');
membraneOverlayState = get(handles.menuOverlayEdge, 'Checked');


% TODO: get data on frames/second and pre- and post-cut time from metadata
membrane = get(dataObjs{2}, 'CData');
prePad = zeros(size(membrane, 1), 5/0.2 + 2);
postPad = zeros(size(membrane, 1), 10/.2 - size(membrane, 2) - 1);
handles.paddedMembrane{ax} = [prePad membrane postPad];

% if(~strcmp(membraneOverlayState, 'on'))
    imshow(colBg, RI, 'Parent', kym_ax);
    handles.kymIm(ax) = imshow(im, RI, [min(im(:)) max(im(:))], 'Parent', kym_ax);
if(~strcmp(membraneOverlayState, 'on'))    
    set(handles.kymIm(ax), 'AlphaData', 1-handles.paddedMembrane{ax}/2);
else
    set(handles.kymIm(ax), 'AlphaData', 1);
end
    hold(kym_ax, 'off');
    set(handles.kymIm(ax), 'UIContextMenu', handles.menuSelectedKymFig);
% end

handles.fitLine(ax) = line(x, y, 'Parent', kym_ax, 'Color', 'r');
handles.fitText(ax) = text(x(2)+1, y(2), [sprintf('%0.2f', handles.speeds{ax}(closest)) ' \mum s^{-1}'],...
    'Parent', kym_ax, 'Color', 'r', 'FontSize', 10, 'BackgroundColor', 'k');

if(~strcmp(fitLineState, 'on'))
    set(handles.fitLine(ax), 'Visible', 'off');
    set(handles.fitText(ax), 'Visible', 'off');
end

if sum(checkIfStored(handles, direction)) > 0 
    set(handles.kymTitle{ax}, 'BackgroundColor', [0 1 0]);
else
    set(handles.kymTitle{ax}, 'BackgroundColor', 'none');
end

busyDlg(busyOutput);
set(handles.listData, 'Enable', 'on');

guidata(hObject, handles);


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
reply = questdlg('Create a new output file, or append output to an existing file?', ...
    'Create/append?', 'Create new', 'Append', 'Create new');

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

busyOutput = busyDlg();
set(handles.listData, 'Enable', 'off');

headerLine = fields(handles.includedData)';
data = struct2cell(handles.includedData)';
xlswrite(outputName, [headerLine; data]);

if includeStats
    %% get list of kymograph IDs
    [uniqueKymIDs,ia,ic]  = unique(data(:, strcmp(headerLine, 'ID')),'stable');
    
    %% for each kymograph, isolate the  relevant data rows and calculate stats
    for ind = 1:max(ic)
        mu(ind) = mean([data{ic == ind, strcmp(headerLine, 'speed')}]);
        sd(ind) = std([data{ic == ind, strcmp(headerLine, 'speed')}]);
        mx(ind) = max([data{ic == ind, strcmp(headerLine, 'speed')}]);
        med(ind) = median([data{ic == ind, strcmp(headerLine, 'speed')}]);
    end
    
    %% turn off "add sheet" warnings...
    wid = 'MATLAB:xlswrite:AddSheet';
    warning('off', wid);
    
    mudata = data(ia, :);
    mudata(:, strcmp(headerLine, 'speed')) = num2cell(mu);
    xlswrite(outputName, [headerLine; mudata], 'Mean speeds, ums^-1');
    
    sddata = data(ia, :);
    sddata(:, strcmp(headerLine, 'speed')) = num2cell(sd);
    xlswrite(outputName, [headerLine; sddata], 'SD on speeds, ums^-1');
    
    mxdata = data(ia, :);
    mxdata(:, strcmp(headerLine, 'speed')) = num2cell(mx);
    xlswrite(outputName, [headerLine; mxdata], 'Max speeds, ums^-1');
    
    meddata = data(ia, :);
    meddata(:, strcmp(headerLine, 'speed')) = num2cell(med);
    xlswrite(outputName, [headerLine; meddata], 'Median speeds, ums^-1');
    
end
   
busyDlg(busyOutput);
set(handles.listData, 'Enable', 'on');
    
    

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
    set(handles.menuOverlayFitLine, 'Checked', 'off');
    set(handles.fitLine(ax), 'Visible', 'off');
    set(handles.fitText(ax), 'Visible', 'off');
else
    set(handles.menuOverlayFitLine, 'Checked', 'on');
    set(handles.fitLine(ax), 'Visible', 'on');
    set(handles.fitText(ax), 'Visible', 'on');
end

guidata(hObject, handles);

% --------------------------------------------------------------------
function menuSelectedKymFig_Callback(hObject, eventdata, handles)
% hObject    handle to menuSelectedKymFig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if (gca == handles.axUpSelectedKym)
    ax = 1;
elseif (gca == handles.axDownSelectedKym)
    ax = 2;
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

if ischar(get(handles.kymTitle{ax}, 'BackgroundColor'))
    if strcmp(get(handles.kymTitle{ax}, 'BackgroundColor'), 'none')
        set(handles.menuInclude, 'Checked', 'off');
    end
else
    set(handles.menuInclude, 'Checked', 'on');
end

guidata(hObject, handles);

% --------------------------------------------------------------------
function menuOverlayEdge_Callback(hObject, eventdata, handles)
% hObject    handle to menuOverlayEdge (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

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

guidata(hObject, handles);

% --------------------------------------------------------------------
function menuManualLine_Callback(hObject, eventdata, handles)
% hObject    handle to menuManualLine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuRepositionLine_Callback(hObject, eventdata, handles)
% hObject    handle to menuRepositionLine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


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
if isfield(handles, 'includedData')
    if ~isempty(handles.includedData)
        reply = questdlg('Discard data currently set as "included" for export?', ...
            'Discard data - are you sure?', 'OK', 'Cancel', 'Cancel');
    end
end

if strcmp(reply, 'OK')

    busyOutput = busyDlg();
    set(handles.listData, 'Enable', 'off');

    [fname, pname,~]= uigetfile('*.xlsx', 'Choose the xlsx file containing the experiment metadata...', sf);
    handles.metadataPath = [pname, fname];

    if ischar(handles.metadataPath)
        handles.experimentMetadata = getExperimentMetadata(handles.metadataPath);
    end

    busyDlg(busyOutput);
    set(handles.listData, 'Enable', 'on');

    handles.includedData = [];

end
    
guidata(hObject, handles);

function indices = checkIfStored(handles, direction)
% Check whether currently selected kymograph data has been stored for
% export

if isstruct(handles.includedData)
    stored = struct2cell(handles.includedData);
    f = fields(handles.includedData);
    dates = {stored(strcmp(f, 'date'), :)};
    embryoNs = {stored(strcmp(f, 'embryoNumber'), :)};
    cutNs = cell2mat(stored(strcmp(f, 'cutNumber'), :));
    directions = {stored(strcmp(f, 'direction'), :)}; 
    positions = cell2mat(stored(strcmp(f, 'kymPosition'), :));

    indices = strcmp(dates{1}, handles.date) & strcmp(embryoNs{1}, handles.embryoNumber) & ...
        (cutNs == str2double(handles.cutNumber)) & strcmp(directions{1}, direction) & ...
        positions == handles.currentPosition;
else
    indices = 0;
end

disp(indices);

% --------------------------------------------------------------------
function menuInclude_Callback(hObject, eventdata, handles)
% hObject    handle to menuInclude (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% Check state of checkbox
if strcmp(get(hObject, 'checked'), 'on')
    set(hObject, 'checked', 'off')
else
    set(hObject, 'checked', 'on')
end

if gca == handles.axUpSelectedKym
    direction = 'up';
    ax = 1;
else
    direction = 'down';
    ax = 2;
end

%% Check if current date/embryo/cut/direction/position is stored yet
indices = checkIfStored(handles, direction);

%% If not, store in includedData structure along with metadata
if sum(indices) == 0 && strcmp(get(hObject, 'checked'), 'on')
    
    % Find the relevant experiment metadata fields...
    expMeta = struct2cell(handles.experimentMetadata);
    expMetaFields = fields(handles.experimentMetadata);
    
    dates = {expMeta(strcmp(expMetaFields, 'date'), :)};
    embryoNs = {expMeta(strcmp(expMetaFields, 'embryoNumber'), :)};
    cutNs = {expMeta(strcmp(expMetaFields, 'cutNumber'), :)};
    
    expMetaIndices = strcmp(dates{1}, handles.date) & strcmp(embryoNs{1}, handles.embryoNumber) & ...
        (cell2mat(cutNs{1}) == str2double(handles.cutNumber));
    
    incData = handles.experimentMetadata(expMetaIndices);
    incData.ID = [handles.date '-' handles.embryoNumber '-' handles.cutNumber '-' direction];
    incData.kymPosition = handles.currentPosition;
    incData.speed = handles.currentSpeed;
    incData.direction = direction;
    
    handles.includedData = [handles.includedData; incData];
    
    set(handles.kymTitle{ax}, 'BackgroundColor', [0 1 0]);
        
end

%% Deal with case when kymograph has been selected but user has changed mind...
if sum(indices > 0) && strcmp(get(hObject, 'checked'), 'off')
   %% remove data from handles.includedData based on indices vector 
   set(handles.kymTitle{ax}, 'BackgroundColor', 'none');
   handles.includedData(indices) = [];
end

guidata(hObject, handles);
    
