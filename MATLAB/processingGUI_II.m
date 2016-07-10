function varargout = processingGUI_II(varargin)
% PROCESSINGGUI_II MATLAB code for processingGUI_II.fig
%      PROCESSINGGUI_II, by itself, creates a new PROCESSINGGUI_II or raises the existing
%      singleton*.
%
%      H = PROCESSINGGUI_II returns the handle to a new PROCESSINGGUI_II or the handle to
%      the existing singleton*.
%
%      PROCESSINGGUI_II('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PROCESSINGGUI_II.M with the given input arguments.
%
%      PROCESSINGGUI_II('Property','Value',...) creates a new PROCESSINGGUI_II or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before processingGUI_II_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to processingGUI_II_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help processingGUI_II

% Last Modified by GUIDE v2.5 10-Jul-2016 17:16:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @processingGUI_II_OpeningFcn, ...
                   'gui_OutputFcn',  @processingGUI_II_OutputFcn, ...
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


% --- Executes just before processingGUI_II is made visible.
function processingGUI_II_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to processingGUI_II (see VARARGIN)

% Choose default command line output for processingGUI_II
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes processingGUI_II wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = processingGUI_II_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in dataTypePopup.
function dataTypePopup_Callback(hObject, eventdata, handles)
% hObject    handle to dataTypePopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns dataTypePopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from dataTypePopup


% --- Executes during object creation, after setting all properties.
function dataTypePopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dataTypePopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
