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

% Last Modified by GUIDE v2.5 27-Dec-2015 12:21:07

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
    
    s = dir([default_folder filesep folders(1).name filesep 'trimmed_cutinfo_cut_*.txt']);
    
    for cInd = 1:length(s)
        
        cutNumber = sscanf(s.name, 'trimmed_cutinfo_cut_%d.txt');
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

axHandles = [handles.axUpSpeedVPosition; handles.axDownSpeedVPosition]; 
titleAppendices = {'upwards'; 'downwards'};

for ind = 1:length(axHandles)
    
    fpath = figFilePaths{ind};
    h = openfig(fpath, 'new', 'invisible');
    ax = get(h, 'Children');
    dataObjs = get(ax, 'Children');
    handles.speeds{ind} = get(dataObjs, 'YData');
    handles.poss{ind} = get(dataObjs, 'XData');
    
    plot(axHandles(ind), handles.poss{ind}, handles.speeds{ind}, 'x-');
    title(axHandles(ind), sprintf('%s, Embryo %s, Cut %s, %s', dt, embryoNumber, cutNumber, titleAppendices{ind}));
   
end

%% Get and plot first frames and relevant lines

figFilePaths = [cellstr([handles.baseFolder filesep dt ', Embryo ' embryoNumber ' upwards' filesep dt ', Embryo ' embryoNumber ', Cut ' cutNumber ', 5 s pre-cut upwards.fig']);...
    cellstr([handles.baseFolder filesep dt ', Embryo ' embryoNumber ' downwards' filesep dt ', Embryo ' embryoNumber ', Cut ' cutNumber ', 5 s pre-cut downwards.fig'])];

axHandles = [handles.axUpFirstFrame; handles.axDownFirstFrame];

for ind = 1:length(axHandles)
    
    fpath = figFilePaths{ind};
    h = openfig(fpath, 'new', 'invisible');
    ax = get(h, 'Children');
    dataObjs = get(ax, 'Children');
    im = get(dataObjs(end), 'CData');
    
    imagesc(im, 'Parent', axHandles(ind));
    colormap(axHandles(ind), gray)
    
    set(axHandles(ind), 'XTick', []);
    set(axHandles(ind), 'YTick', []);
 
    %% scale bar...
    sc_line_x = get(dataObjs(2), 'XData');
    sc_line_y = get(dataObjs(2), 'YData');
    line(sc_line_x, sc_line_y, 'Parent', axHandles(ind), 'Color', 'w', ...
        'LineWidth', 3);
    
    %% cut line...
    cut_line_x = get(dataObjs(end-1), 'XData');
    cut_line_y = get(dataObjs(end-1), 'YData');
    line(cut_line_x, cut_line_y, 'Parent', axHandles(ind), 'Color', 'c', ...
        'LineWidth', 1);
    
    %% kymograph lines...   
    kym_lines = zeros(1,length(dataObjs)-4);
    for lInd = 3:(length(dataObjs)-2)
        kym_lines(lInd) = line(get(dataObjs(lInd), 'XData'), get(dataObjs(lInd), 'YData'), ...
            'Parent', axHandles(ind), 'Color', 'r', 'LineStyle', '--');
    end
    
    
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
