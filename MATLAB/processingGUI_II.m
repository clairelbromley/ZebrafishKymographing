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

% Last Modified by GUIDE v2.5 12-Jul-2016 22:33:02

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



function inputPathText_Callback(hObject, eventdata, handles)
% hObject    handle to inputPathText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of inputPathText as text
%        str2double(get(hObject,'String')) returns contents of inputPathText as a double


% --- Executes during object creation, after setting all properties.
function inputPathText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to inputPathText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in inputPathBrowseButton.
function inputPathBrowseButton_Callback(hObject, eventdata, handles)
% hObject    handle to inputPathBrowseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in outputPathBrowseButton.
function outputPathBrowseButton_Callback(hObject, eventdata, handles)
% hObject    handle to outputPathBrowseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function timeBeforeCutText_Callback(hObject, eventdata, handles)
% hObject    handle to timeBeforeCutText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of timeBeforeCutText as text
%        str2double(get(hObject,'String')) returns contents of timeBeforeCutText as a double


% --- Executes during object creation, after setting all properties.
function timeBeforeCutText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to timeBeforeCutText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function timeAfterCutText_Callback(hObject, eventdata, handles)
% hObject    handle to timeAfterCutText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of timeAfterCutText as text
%        str2double(get(hObject,'String')) returns contents of timeAfterCutText as a double


% --- Executes during object creation, after setting all properties.
function timeAfterCutText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to timeAfterCutText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function quantitativeAnalysisTimeText_Callback(hObject, eventdata, handles)
% hObject    handle to quantitativeAnalysisTimeText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of quantitativeAnalysisTimeText as text
%        str2double(get(hObject,'String')) returns contents of quantitativeAnalysisTimeText as a double


% --- Executes during object creation, after setting all properties.
function quantitativeAnalysisTimeText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to quantitativeAnalysisTimeText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function kymPositioningText_Callback(hObject, eventdata, handles)
% hObject    handle to kymPositioningText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of kymPositioningText as text
%        str2double(get(hObject,'String')) returns contents of kymPositioningText as a double


% --- Executes during object creation, after setting all properties.
function kymPositioningText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to kymPositioningText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function kymWidthText_Callback(hObject, eventdata, handles)
% hObject    handle to kymWidthText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of kymWidthText as text
%        str2double(get(hObject,'String')) returns contents of kymWidthText as a double


% --- Executes during object creation, after setting all properties.
function kymWidthText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to kymWidthText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function kymLengthText_Callback(hObject, eventdata, handles)
% hObject    handle to kymLengthText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of kymLengthText as text
%        str2double(get(hObject,'String')) returns contents of kymLengthText as a double


% --- Executes during object creation, after setting all properties.
function kymLengthText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to kymLengthText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in showOverlaysCheck.
function showOverlaysCheck_Callback(hObject, eventdata, handles)
% hObject    handle to showOverlaysCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of showOverlaysCheck


% --- Executes on button press in preProcessCheck.
function preProcessCheck_Callback(hObject, eventdata, handles)
% hObject    handle to preProcessCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of preProcessCheck


% --- Executes on button press in loadPreprocessedCheck.
function loadPreprocessedCheck_Callback(hObject, eventdata, handles)
% hObject    handle to loadPreprocessedCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of loadPreprocessedCheck


% --- Executes on button press in savePreprocessedCheck.
function savePreprocessedCheck_Callback(hObject, eventdata, handles)
% hObject    handle to savePreprocessedCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of savePreprocessedCheck



function edit10_Callback(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit10 as text
%        str2double(get(hObject,'String')) returns contents of edit10 as a double


% --- Executes during object creation, after setting all properties.
function edit10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox5.
function checkbox5_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox5


% --- Executes on button press in apicalSurfaceFinderLoadCheck.
function apicalSurfaceFinderLoadCheck_Callback(hObject, eventdata, handles)
% hObject    handle to apicalSurfaceFinderLoadCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of apicalSurfaceFinderLoadCheck


% --- Executes on selection change in outputPopup.
function outputPopup_Callback(hObject, eventdata, handles)
% hObject    handle to outputPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns outputPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from outputPopup


% --- Executes during object creation, after setting all properties.
function outputPopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to outputPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
