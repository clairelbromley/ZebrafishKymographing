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

% Last Modified by GUIDE v2.5 28-Dec-2015 18:53:56

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
base_folder = uigetdir(default_folder, 'Choose the base folder to populate the data list...');
dataList = cell(0);
handles.baseFolder = base_folder;

folders = dir([base_folder filesep '*upwards']);

for fInd = 1:length(folders)
    
    s = dir([default_folder filesep folders(fInd).name filesep 'trimmed_cutinfo_cut_*.txt']);
    
    for cInd = 1:length(s)
        
        cutNumber = sscanf(s(cInd).name, 'trimmed_cutinfo_cut_%d.txt');
        dt = sscanf(folders(fInd).name, '%d, Embryo *');
        embryoNumber = sscanf(folders(fInd).name, '%*6c, Embryo %2c upwards');
        
        dataList = [dataList; cellstr(sprintf('Date = %d, Embryo = %s, Cut = %d', dt, embryoNumber, cutNumber))];
        
    end
    
end

set(handles.listData, 'String', dataList);

guidata(hObject, handles);
        
        
        


% --- Executes on selection change in listData.
function listData_Callback(hObject, eventdata, handles)
% hObject    handle to listData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

contents = cellstr(get(hObject,'String')); % returns listData contents as cell array
selected = contents{get(hObject,'Value')}; % returns selected item from listData
disp(selected);

%% Get and plot speed vs position
s = regexp(selected, '[=, ]', 'split');
dt = s{4};
embryoNumber = s{9};
cutNumber = s{14};
figFilePaths = [cellstr([handles.baseFolder filesep dt ', Embryo ' embryoNumber ' upwards' filesep dt ', Embryo ' embryoNumber ', Cut ' cutNumber ', Speed against cut position upwards.fig']);...
    cellstr([handles.baseFolder filesep dt ', Embryo ' embryoNumber ' downwards' filesep dt ', Embryo ' embryoNumber ', Cut ' cutNumber ', Speed against cut position downwards.fig'])];

handles.date = dt;
handles.cutNumber = cutNumber;
handles.embryoNumber = embryoNumber;

axHandles = [handles.axUpSpeedVPosition; handles.axDownSpeedVPosition]; 
titleAppendices = {'upwards'; 'downwards'};

buttonDownFcns = {{@axUpSpeedVPosition_ButtonDownFcn, handles};...
    {@axDownSpeedVPosition_ButtonDownFcn, handles}}

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
    
    set(axHandles(ind), 'ButtonDownFcn', {@axUpSpeedVPosition_ButtonDownFcn, handles});
    set(handles.plotHandles{ind}, 'ButtonDownFcn', {@axUpSpeedVPosition_ButtonDownFcn, handles});
       
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

close(h);
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

baseFolder2 = [handles.baseFolder filesep handles.date ', Embryo ' handles.embryoNumber];
    
if gca == handles.axUpSpeedVPosition
    ax = 1;
    appendText = ' upwards';
    kym_ax = handles.axUpSelectedKym;
else
    ax = 2;
    appendText = ' downwards';
    kym_ax = handles.axDownSelectedKym;
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

%% Get relevant kymograph file and plot
filepath = [folder filesep 'trimmed_cutinfo_cut_' handles.cutNumber '.txt'];
pos_along_cut = getKymPosMetadataFromText(filepath);
kym_ind = find((round(100*pos_along_cut)/100) == (round(100*handles.poss{ax}(closest))/100)) - 2;

fpath = [folder filesep handles.date ', Embryo ' handles.embryoNumber ...
    ', Cut ' handles.cutNumber ', Kymograph index along cut = ' num2str(kym_ind)...
    appendText '.fig'];
h = openfig(fpath, 'new', 'invisible');
fAx = get(h, 'Children');
dataObjs = get(fAx, 'Children');
im = get(dataObjs(end), 'CData');
x = get(dataObjs(end), 'XData');
y = get(dataObjs(end), 'YData');

imH = imagesc(x, y, im, 'Parent', kym_ax);
colormap(kym_ax, gray)
xlabel(kym_ax, 'Time relative to cut, s')
ylabel(kym_ax, 'Position relative to cut, \mum')
title_txt = [handles.date ' Embryo ' handles.embryoNumber ', Cut ' handles.cutNumber...
    ',' appendText ' Kymograph position along cut: ' sprintf('%0.2f', handles.poss{ax}(closest)) ' \mum'];
title(kym_ax, title_txt);

disp('nonsense');
