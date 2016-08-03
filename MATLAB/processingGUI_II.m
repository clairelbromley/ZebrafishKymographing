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

% Last Modified by GUIDE v2.5 03-Aug-2016 06:35:55

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

handles.userOptions = UserOptions();

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



function outputFolderText_Callback(hObject, eventdata, handles)
% hObject    handle to outputFolderText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of outputFolderText as text
%        str2double(get(hObject,'String')) returns contents of outputFolderText as a double


% --- Executes during object creation, after setting all properties.
function outputFolderText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to outputFolderText (see GCBO)
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
handles = guidata(gcf);

handles.userOptions.timeBeforeCut = str2double(get(hObject, 'String'));

guidata(hObject, handles);


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
handles = guidata(gcf);

handles.userOptions.timeAfterCut = str2double(get(hObject, 'String'));

guidata(hObject, handles);


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
handles = guidata(gcf);

handles.userOptions.quantAnalysisTime = str2double(get(hObject, 'String'));

guidata(hObject, handles);

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

handles = guidata(gcf);

if get(handles.fixedNumberRadio, 'Value')
    
    handles.userOptions.number_kym  = str2double(get(hObect, 'String'));
    
else
    
    handles.userOptions.kymSpacingUm = str2double(get(hObect, 'String'));
    
end

guidata(hObject, handles);


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

handles = guidata(gcf);

handles.userOptions.kym_width = str2double(get(hObject, 'String'));

guidata(hObject, handles);




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

handles = guidata(gcf);

handles.userOptions.kym_length = str2double(get(hObject, 'String'));

guidata(hObject, handles);


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
handles = guidata(gcf);

handles.userOptions.showKymographOverlapOverlay = get(hObject, 'Value');

guidata(hObject, handles);



% --- Executes on button press in preProcessCheck.
function preProcessCheck_Callback(hObject, eventdata, handles)
% hObject    handle to preProcessCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(gcf);

handles.userOptions.preProcess = get(hObject, 'Value');

guidata(hObject, handles);


% --- Executes on button press in loadPreprocessedCheck.
function loadPreprocessedCheck_Callback(hObject, eventdata, handles)
% hObject    handle to loadPreprocessedCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(gcf);

handles.userOptions.loadPreprocessedImages = get(hObject, 'Value');

guidata(hObject, handles);


% --- Executes on button press in savePreprocessedCheck.
function savePreprocessedCheck_Callback(hObject, eventdata, handles)
% hObject    handle to savePreprocessedCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(gcf);

handles.userOptions.savePreprocessed = get(hObject, 'Value');

guidata(hObject, handles);


function medianFilterText_Callback(hObject, eventdata, handles)
% hObject    handle to medianFilterText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(gcf);

handles.userOptions.medianFiltKernelSize = str2double(get(hObject, 'String'));

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function medianFilterText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to medianFilterText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in removeCutFramesCheck.
function removeCutFramesCheck_Callback(hObject, eventdata, handles)
% hObject    handle to removeCutFramesCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(gcf);

handles.userOptions.removeCutFrames = get(hObject, 'Value');

guidata(hObject, handles);


% --- Executes on button press in apicalSurfaceFinderLoadCheck.
function apicalSurfaceFinderLoadCheck_Callback(hObject, eventdata, handles)
% hObject    handle to apicalSurfaceFinderLoadCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(gcf);

handles.userOptions.usePreviouslySavedApicalSurfacePos = get(hObject, 'Value');

guidata(hObject, handles);



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



function scalebarLengthText_Callback(hObject, eventdata, handles)
% hObject    handle to scalebarLengthText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of scalebarLengthText as text
%        str2double(get(hObject,'String')) returns contents of scalebarLengthText as a double


% --- Executes during object creation, after setting all properties.
function scalebarLengthText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scalebarLengthText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox7.
function checkbox7_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox7


% --- Executes on button press in shortCutCheck.
function shortCutCheck_Callback(hObject, eventdata, handles)
% hObject    handle to shortCutCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(gcf);

handles.userOptions.flip90DegForShortCuts = get(hObject, 'Value');

guidata(hObject, handles);


% --- Executes on button press in forceRangesCheck.
function forceRangesCheck_Callback(hObject, eventdata, handles)
% hObject    handle to forceRangesCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of forceRangesCheck



function forceMinPosText_Callback(hObject, eventdata, handles)
% hObject    handle to forceMinPosText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of forceMinPosText as text
%        str2double(get(hObject,'String')) returns contents of forceMinPosText as a double


% --- Executes during object creation, after setting all properties.
function forceMinPosText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to forceMinPosText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function forceMaxPosText_Callback(hObject, eventdata, handles)
% hObject    handle to forceMaxPosText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of forceMaxPosText as text
%        str2double(get(hObject,'String')) returns contents of forceMaxPosText as a double


% --- Executes during object creation, after setting all properties.
function forceMaxPosText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to forceMaxPosText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function forceMinSpeedText_Callback(hObject, eventdata, handles)
% hObject    handle to forceMinSpeedText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of forceMinSpeedText as text
%        str2double(get(hObject,'String')) returns contents of forceMinSpeedText as a double


% --- Executes during object creation, after setting all properties.
function forceMinSpeedText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to forceMinSpeedText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function forceMaxSpeedText_Callback(hObject, eventdata, handles)
% hObject    handle to forceMaxSpeedText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of forceMaxSpeedText as text
%        str2double(get(hObject,'String')) returns contents of forceMaxSpeedText as a double


% --- Executes during object creation, after setting all properties.
function forceMaxSpeedText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to forceMaxSpeedText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in goButton.
function goButton_Callback(hObject, eventdata, handles)
% hObject    handle to goButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = guidata(gcf);

if get(handles.upAndDownRadio, 'Value')
    
%     kymographUpDownWrapper(
    % refactor kymographUpDownWrapper to take a UserOptions object as an
    % argument
    
else
    kymographBase(this.userOptions);
end


% --- Executes when selected object is changed in apicalSurfaceFinderPanel.
function apicalSurfaceFinderPanel_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in apicalSurfaceFinderPanel 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(gcf);

if get(handles.apicalSurfaceFinderOffRadio, 'Value')
    handles.userOptions.manualOrAutoApicalSurfaceFinder = 'off';
elseif get(handles.apicalSurfaceFinderManualRadio, 'Value')
    handles.userOptions.manualOrAutoApicalSurfaceFinder = 'manual';
elseif get(handles.apicalSurfaceFinderAutoRadio, 'Value')
    handles.userOptions.manualOrAutoApicalSurfaceFinder = 'auto';
end
        
guidata(hObject, handles);


% --- Executes when selected object is changed in kymographPositioningPanel.
function kymographPositioningPanel_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in kymographPositioningPanel 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(gcf);

if get(handles.fixedSpacingRadio, 'Value')
    set(handles.kymPositionLabel, 'String', 'Spacing (um):');
    handles.userOptions.fixedNumberOrFixedSpacing = true;
    set(handles.kymPositioningText, 'String', num2str(handles.userOptions.kymSpacingUm));
elseif get(handles.fixedNumberRadio, 'Value')
    set(handles.kymPositionLabel, 'String', '# of kymos:');
    handles.userOptions.fixedNumberOrFixedSpacing = false;
    set(handles.kymPositioningText, 'String', num2str(handles.userOptions.number_kym));
end
        
guidata(hObject, handles);
