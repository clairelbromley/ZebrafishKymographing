function varargout = cziFig(varargin)
% CZIFIG MATLAB code for cziFig.fig
%      CZIFIG, by itself, creates a new CZIFIG or raises the existing
%      singleton*.
%
%      H = CZIFIG returns the handle to a new CZIFIG or the handle to
%      the existing singleton*.
%
%      CZIFIG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CZIFIG.M with the given input arguments.
%
%      CZIFIG('Property','Value',...) creates a new CZIFIG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before cziFig_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to cziFig_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help cziFig

% Last Modified by GUIDE v2.5 02-May-2016 22:31:54

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @cziFig_OpeningFcn, ...
                   'gui_OutputFcn',  @cziFig_OutputFcn, ...
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


% --- Executes just before cziFig is made visible.
function cziFig_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to cziFig (see VARARGIN)

% Choose default command line output for cziFig
handles.output = hObject;

dummy = [mfilename('fullpath') '.m'];
currdir = fileparts(dummy);
funcPath = [currdir filesep '..'];
addpath(genpath(currdir));
addpath(funcPath);

handles.params.date = '020516';
handles.params.embryoNumber = 1;
handles.params.cutStartX = 1;
handles.params.cutStartY = 1;
handles.params.cutEndX = 50;
handles.params.cutEndY = 50;
handles.params.pixelSize = 1;
handles.params.frameTime = 1000;

set(handles.axImage, 'XTick', []);
set(handles.axImage, 'YTick', []);

updateUIParams(handles.params)

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes cziFig wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = cziFig_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function updateUIParams(params)
    
handles = guidata(gcf);

set(handles.txtDate, 'String', params.date);
set(handles.txtENumber, 'String', num2str(params.embryoNumber));
set(handles.txtPixelSize, 'String', num2str(params.pixelSize));
set(handles.txtFrameTime, 'String', num2str(params.frameTime));
set(handles.txtStartX, 'String', num2str(params.cutStartX));
set(handles.txtEndX, 'String', num2str(params.cutEndX));
set(handles.txtStartY, 'String', num2str(params.cutStartY));
set(handles.txtEndY, 'String', num2str(params.cutEndY));

   
% --- handle errors. 
function errorHandler(ME)

if ischar(ME)
    uiwait(errordlg(ME, 'Error!', 'modal'));
else
    uiwait(errordlg(ME.message, 'Error!', 'modal'));
    rethrow(ME);
end

% --- Executes on button press in buttonCancel.
function buttonCancel_Callback(hObject, eventdata, handles)
% hObject    handle to buttonCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in buttonSave.
function buttonSave_Callback(hObject, eventdata, handles)
% hObject    handle to buttonSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in buttonSaveNext.
function buttonSaveNext_Callback(hObject, eventdata, handles)
% hObject    handle to buttonSaveNext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in buttonBrowseImagePath.
function buttonBrowseImagePath_Callback(hObject, eventdata, handles)
% hObject    handle to buttonBrowseImagePath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(gcf);

[fname, pname, ~] = uigetfile('*.czi');

set(handles.txtImagePath, 'String', [pname fname]);
imagePathChanged({[pname fname]});


function txtImagePath_Callback(hObject, eventdata, handles)
% hObject    handle to txtImagePath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtImagePath as text
%        str2double(get(hObject,'String')) returns contents of txtImagePath as a double
% Choose default command line output for cziFig
handles = guidata(gcf);

input = get(hObject,'String');
display(input);

imagePathChanged(input);

% Update handles structure
guidata(hObject, handles);

% --- handles changes to image path independently of source of change. 
function imagePathChanged(new_image_path)
handles = guidata(gcf);

% make sure UI reflects underlying data
set(handles.txtImagePath, 'String', new_image_path);

% check that path is a .czi file
[~,~,ext] = fileparts(new_image_path{1});
if ~strcmp(ext, '.czi')
    errorHandler('Image must be CZI format!');
else
    try
        % load first frame to image preview pane
%         data = bfopen(new_image_path{1});
%         omeMeta = data{1,4};
%         im = data{1}{1};
        % don't load whole series yet...
        reader = bfGetReader(new_image_path{1});
        omeMeta = reader.getMetadataStore();
        im = bfGetPlane(reader, 1);
        
        imagesc(im);
        colormap gray;
        set(gca, 'XTick', []);
        set(gca, 'YTick', []);
        
        % figure out and populate default parameters
        handles.params.pixelSize = double(omeMeta.getPixelsPhysicalSizeX(0).value(ome.units.UNITS.MICROM));
        handles.params.frameTime = double(omeMeta.getPlaneDeltaT(0, 1).value()) - double(omeMeta.getPlaneDeltaT(0, 0).value());
        updateUIParams(handles.params);
        
        
    catch ME
        errorHandler(ME);
        
    end
        
end


% --- Executes during object creation, after setting all properties.
function txtImagePath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtImagePath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtDate_Callback(hObject, eventdata, handles)
% hObject    handle to txtDate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtDate as text
%        str2double(get(hObject,'String')) returns contents of txtDate as a double


% --- Executes during object creation, after setting all properties.
function txtDate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtDate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtENumber_Callback(hObject, eventdata, handles)
% hObject    handle to txtENumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtENumber as text
%        str2double(get(hObject,'String')) returns contents of txtENumber as a double


% --- Executes during object creation, after setting all properties.
function txtENumber_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtENumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtFrameTime_Callback(hObject, eventdata, handles)
% hObject    handle to txtFrameTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtFrameTime as text
%        str2double(get(hObject,'String')) returns contents of txtFrameTime as a double


% --- Executes during object creation, after setting all properties.
function txtFrameTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtFrameTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtPixelSize_Callback(hObject, eventdata, handles)
% hObject    handle to txtPixelSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtPixelSize as text
%        str2double(get(hObject,'String')) returns contents of txtPixelSize as a double


% --- Executes during object creation, after setting all properties.
function txtPixelSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtPixelSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtSaveRoot_Callback(hObject, eventdata, handles)
% hObject    handle to txtSaveRoot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtSaveRoot as text
%        str2double(get(hObject,'String')) returns contents of txtSaveRoot as a double


% --- Executes during object creation, after setting all properties.
function txtSaveRoot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtSaveRoot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in buttonBrowseSaveRoot.
function buttonBrowseSaveRoot_Callback(hObject, eventdata, handles)
% hObject    handle to buttonBrowseSaveRoot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function txtStartX_Callback(hObject, eventdata, handles)
% hObject    handle to txtStartX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtStartX as text
%        str2double(get(hObject,'String')) returns contents of txtStartX as a double


% --- Executes during object creation, after setting all properties.
function txtStartX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtStartX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtStartY_Callback(hObject, eventdata, handles)
% hObject    handle to txtStartY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtStartY as text
%        str2double(get(hObject,'String')) returns contents of txtStartY as a double


% --- Executes during object creation, after setting all properties.
function txtStartY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtStartY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtEndX_Callback(hObject, eventdata, handles)
% hObject    handle to txtEndX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtEndX as text
%        str2double(get(hObject,'String')) returns contents of txtEndX as a double


% --- Executes during object creation, after setting all properties.
function txtEndX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtEndX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtEndY_Callback(hObject, eventdata, handles)
% hObject    handle to txtEndY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtEndY as text
%        str2double(get(hObject,'String')) returns contents of txtEndY as a double


% --- Executes during object creation, after setting all properties.
function txtEndY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtEndY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function menuFile_Callback(hObject, eventdata, handles)
% hObject    handle to menuFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuSelectFolder_Callback(hObject, eventdata, handles)
% hObject    handle to menuSelectFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
