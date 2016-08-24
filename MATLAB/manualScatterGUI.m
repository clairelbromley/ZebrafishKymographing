function varargout = manualScatterGUI(varargin)
% MANUALSCATTERGUI MATLAB code for manualScatterGUI.fig
%      MANUALSCATTERGUI, by itself, creates a new MANUALSCATTERGUI or raises the existing
%      singleton*.
%
%      H = MANUALSCATTERGUI returns the handle to a new MANUALSCATTERGUI or the handle to
%      the existing singleton*.
%
%      MANUALSCATTERGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MANUALSCATTERGUI.M with the given input arguments.
%
%      MANUALSCATTERGUI('Property','Value',...) creates a new MANUALSCATTERGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before manualScatterGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to manualScatterGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help manualScatterGUI

% Last Modified by GUIDE v2.5 23-Aug-2016 16:39:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @manualScatterGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @manualScatterGUI_OutputFcn, ...
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


% --- Executes just before manualScatterGUI is made visible.
function manualScatterGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to manualScatterGUI (see VARARGIN)

% Choose default command line output for manualScatterGUI
handles.output = hObject;

% get inputs
handles.stack = varargin{1};
% handles.md = varargin{2};
% handles.uo = varargin{3};
handles.cut_frame_ind = varargin{2};

% set outputs
handles.frameMask = zeros(1,10);

% show frames
allAx = findall(gcf, 'type', 'axes');
dispAx = allAx(1);
allAx(1) = []; % get rid of large viewing axis from list of axes

% handles.stack = handles.stack(:,:,(handles.md.cutFrame - 3):handles.md.cutFrame + 6);
handles.stack = handles.stack(:,:,(handles.cut_frame_ind - 3):handles.cut_frame_ind + 6);
cmin = min(handles.stack(:));
cmax = max(handles.stack(:));
clims =[cmin cmax];

for i=length(allAx):-1:1
    h = imagesc(squeeze(handles.stack(:,:,11-i)), 'Parent', allAx(i));
%     set(h, 'HitTest', 'off');
%     set(h, 'ButtonDownFcn', 'disp(''hello'')');
    set(h, 'ButtonDownFcn', @genericAxisClick);
    set(allAx(i), 'XTick', []);
    set(allAx(i), 'YTick', []);
    set(allAx(i), 'CLim', clims);
    title(allAx(i), sprintf('Frame %d', handles.cut_frame_ind - 4 + (11-i)));
    colormap gray;
    axis equal tight;
end

imagesc(squeeze(handles.stack(:,:,1)), 'Parent', dispAx);
set(dispAx, 'XTick', []);
set(dispAx, 'YTick', []);
axis equal tight;
title(dispAx, sprintf('Frame %d', handles.cut_frame_ind - 3));

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes manualScatterGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = manualScatterGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
varargout{2} = handles.frameMask;


% --- Executes on button press in okButton.
function okButton_Callback(hObject, eventdata, handles)
% hObject    handle to okButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(gcf);

function genericAxisClick(hObject, eventdata, handles)
    
    handles = guidata(gcf);
%     axHandle = gca;
    % generalise for case in which hotkey is pressed rather than mouse...
    allAx = findall(gcf, 'type', 'axes');
    kids = [];
    for i = 1:length(allAx)
        kids = [kids; get(allAx(i), 'Children')];
    end
    axHandle = allAx(kids == hObject); 
    
    % determine which axis was clicked
    allAx = findall(gcf, 'type', 'axes');
    dispAx = allAx(1);
    allAx(1) = []; % get rid of large viewing axis
    axInd = 10:-1:1;
    selectedAxInd = axInd(allAx == axHandle);
    
    % determine whether click was with right or left mouse button - if
    % left, then simply display the image in the preview pane. If right,
    % toggle whether to remove frame from analysis. 
    if strcmp(get(gcf, 'SelectionType'), 'normal')  % left click...
        imagesc(squeeze(handles.stack(:,:,selectedAxInd)), 'Parent', dispAx);

        set(dispAx, 'XTick', []);
        set(dispAx, 'YTick', []);
        axis equal tight;
        title(dispAx, sprintf('Frame %d', handles.cut_frame_ind - 4 + (selectedAxInd)));
        
    else
        a = get(allAx(10 - selectedAxInd + 1));
        if handles.frameMask(10 - selectedAxInd)
            handles.frameMask(10 - selectedAxInd) = false;
            set(a.Title, 'Color', [0 0 0]);
        else
            handles.frameMask(10 - selectedAxInd) = true;
            set(a.Title, 'Color', [1 0 0]);
        end
    end
%     set(axHandle, 'Color', [1 0 0]);
    
%     disp(selectedAxInd);
    guidata(gcbo, handles);


% 
% % --- Executes on mouse press over axes background.
% function axes1_ButtonDownFcn(hObject, eventdata, handles)
% % hObject    handle to axes1 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% % genericAxisClick(hObject);
% genericAxisClick();
