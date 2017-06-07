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

% Last Modified by GUIDE v2.5 07-Jun-2017 20:42:34

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
out=regexp(currdir,'\','split');
c = cell(1, length(out));
c(:) = {filesep};
addpath(genpath(strjoin(strcat(out(1:end-1), c(1:end-1)), '')));
% addpath(genpath(funcPath));

handles.lowMemMask = [];
handles.lastLowMemMask = [];

handles.params.date = '230514';
handles.params.embryoNumber = 1;
handles.params.cutStartX = 1;
handles.params.cutStartY = 1;
handles.params.cutEndX = 50;
handles.params.cutEndY = 50;
handles.params.pixelSize = 1;
handles.params.frameTime = 1;
handles.params.kymSpacing = 1;
handles.params.currZPlane = 1;
handles.params.currCPlane = 1;
handles.params.zPlanes = 10;
handles.params.channels = 2;
handles.params.firstFrame = 1;
handles.params.lastFrame = 50;
handles.params.sequenceLength = 50;
handles.params.currTPlane = 1;
handles.params.analysisTime = 20 * handles.params.frameTime;
handles.params.multipageTiffBeforeTimeS = 30;
handles.params.multipageTiffAfterTimeS = 30;

handles.params.dir = [0 1]; % up

handles.params.speedInUmPerMinute = false;
handles.params.kernelSize = 50;
handles.params.kymWidth = 5;
handles.params.kymLength = 75;

set(handles.axImage, 'XTick', []);
set(handles.axImage, 'YTick', []);

updateUIParams(handles.params);

[y, Fs] = audioread([currdir filesep 'finished.wav']);
handles.player = audioplayer(y, Fs);

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

function params = updateUIParams(params)
    
handles = guidata(gcf);

set(handles.txtDate, 'String', params.date);
set(handles.txtENumber, 'String', num2str(params.embryoNumber));
set(handles.txtPixelSize, 'String', num2str(params.pixelSize));
set(handles.txtFrameTime, 'String', num2str(params.frameTime));
% set(handles.txtStartX, 'String', num2str(params.cutStartX));
% set(handles.txtEndX, 'String', num2str(params.cutEndX));
% set(handles.txtStartY, 'String', num2str(params.cutStartY));
% set(handles.txtEndY, 'String', num2str(params.cutEndY));
% set(handles.txtKymSpacingUm, 'String', num2str(params.kymSpacing));
set(handles.txtCPlaneDisplay, 'String', sprintf('(%d/%d)', params.currCPlane, params.channels));
set(handles.txtZPlaneDisplay, 'String', sprintf('(%d/%d)', params.currZPlane, params.zPlanes));
set(handles.txtFirstFrameDisplay, 'String', sprintf('(%d/%d)', params.firstFrame, params.sequenceLength));
set(handles.txtLastFrameDisplay, 'String', sprintf('(%d/%d)', params.lastFrame, params.sequenceLength));
set(handles.txtAnalysisTimeDisplay, 'String', sprintf('(%0.2f)', params.analysisTime))

set(handles.scrollZPlane, 'Max', params.zPlanes);
set(handles.scrollZPlane, 'Min', 1);
set(handles.scrollZPlane, 'Value', params.currZPlane);
if params.zPlanes > 1
    sstep = params.zPlanes - 1;
else
    sstep = 1;
end
set(handles.scrollZPlane, 'SliderStep', [(1/sstep) (1/sstep)]);

set(handles.scrollFirstFrame, 'Max', params.sequenceLength);
set(handles.scrollFirstFrame, 'Value', params.firstFrame);
set(handles.scrollFirstFrame, 'Min', 1);
if params.sequenceLength > 1
    sstep = params.sequenceLength - 1;
else
    sstep = 1;
end
set(handles.scrollFirstFrame, 'SliderStep', [(1/sstep) (1/sstep)]);

set(handles.scrollLastFrame, 'Max', params.sequenceLength);
set(handles.scrollLastFrame, 'Value', params.lastFrame);
set(handles.scrollLastFrame, 'Min', 1);
set(handles.scrollLastFrame, 'SliderStep', [(1/sstep) (1/sstep)]);

set(handles.scrollAnalysisTime, 'Min', params.frameTime);
set(handles.scrollAnalysisTime, 'Max', params.sequenceLength * params.frameTime);
set(handles.scrollAnalysisTime, 'Value', params.analysisTime);
set(handles.scrollAnalysisTime, 'SliderStep', [(1/sstep) (1/sstep)]);

set(handles.scrollCPlane, 'Min', 1);
set(handles.scrollCPlane, 'Max', params.channels);
set(handles.scrollCPlane, 'Value', params.currCPlane);
if params.channels > 1
    sstep = params.channels - 1;
else
    sstep = 1;
end
set(handles.scrollCPlane, 'SliderStep', [(1/sstep) (1/sstep)]);

guidata(gcf, handles);
 
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
handles = guidata(gcf);
disp('nsda');



% --- Executes on button press in buttonSave.
function buttonSave_Callback(hObject, eventdata, handles)
% hObject    handle to buttonSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in buttonGenerateKym.
function buttonGenerateKym_Callback(hObject, eventdata, handles)
% hObject    handle to buttonGenerateKym (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(gcf);

% ensure that visualised cut position corresponds properly with underlying
% data
% xy = handles.cutLine.getPosition();

% handles.params.cutStartX = round(xy(1,1));
% handles.params.cutEndX = round(xy(2,1));
% handles.params.cutStartY = round(xy(1,2));
% handles.params.cutEndY = round(xy(2,2));
% handles.params.embryoNumber = str2double(get(handles.txtENumber, 'String'))

svRoot = get(handles.txtSaveRoot, 'String');
if ~strcmp(svRoot, 'Enter path...') && isdir(svRoot)

    handles.params = getParams();

    initialString = get(hObject, 'String');
    set(hObject, 'String', 'Working...');
    % set(hObject, 'Enable', 'off');
    drawnow;

    % check all fields are filled in sensibly...

    % generate image data in expected format
    fcell = get(handles.txtImagePath, 'String');
    data = bfopen(fcell{1});
    omeMeta = handles.omeMeta;
    % data = data{1}(1:2:end,1);  % figure out why this line takes only every second frame: doesn't work for midline dynamics stuff...
    data = data{1}(:,1);
    newshape = [size(data{1}, 1), length(data), size(data{1}, 2)];
    data = cell2mat(data);
    data = reshape(data, newshape);
    stack = permute(data, [1 3 2]);

    % trim according to user selection, and forcing a single channel, single z
    % plane
    if (handles.params.CZTOrder(end) == 5) % CZT or ZTC
        substack = stack(:,:, 1:(handles.params.channels * handles.params.zPlanes):(end - ((handles.params.channels * handles.params.zPlanes) - 1)));
    elseif  ((sum(handles.params.CZTOrder == [3 5 4]') / 3) == 1) % CTZ
        substack = stack(:, :, 1:handles.params.channels:(handles.params.channels * handles.params.sequenceLength));
    elseif  ((sum(handles.params.CZTOrder == [4 5 3]') / 3) == 1) % ZTC
        substack = stack(:, :, 1:handles.params.zPlanes:(handles.params.zPlanes * handles.params.sequenceLength));
    else % TCZ or TZC
        substack = stack(:, :, 1:handles.params.sequenceLength);
    end

    stack = substack(:,:,(handles.params.firstFrame : handles.params.lastFrame));

    % pad 100 pixels on each side...
    newstack = zeros(size(stack, 1) + 200, size(stack, 2) + 200, size(stack, 3));
    newstack(100:99 + size(stack, 1), 100:99 + size(stack, 2), :) = stack;
    stack = newstack;
    clear newstack;

    % get (OME) metadata from data
    curr_metadata = getMetadataFromOME(omeMeta, handles.params);
    curr_metadata.acqMetadata.cycleTime = str2num(get(handles.txtFrameTime, 'String'));

    clear data;

    userOptions = getUserOptions(handles);

    %DEBUG w/SMALL MEDIAN FILTER
    userOptions.medianFiltKernelSize = handles.params.kernelSize;
    userOptions.kym_width = handles.params.kymWidth;
    userOptions.kym_length = handles.params.kymLength;
    userOptions.showKymographOverlapOverlay = true;
    userOptions.kymSpacingUm = str2double(get(handles.txtKymSpacingUm, 'String'));
    userOptions.speedInUmPerMinute = handles.params.speedInUmPerMinute;



    userOptions.timeBeforeCut = 0;
    userOptions.timeAfterCut = (handles.params.lastFrame - handles.params.firstFrame) * handles.params.frameTime;
    userOptions.quantAnalysisTime = handles.params.analysisTime;


    for dind = handles.params.dir

        userOptions.kymDownOrUp = dind;

        %% Pre-process images in stack
        curr_metadata.kym_region = placeKymographs(curr_metadata, userOptions);
        [trim_stack, curr_metadata] = kymographPreprocessing(stack, curr_metadata, userOptions);

        %% Plot and save kymographs
        kymographs = plotAndSaveKymographsSlow(trim_stack, curr_metadata, userOptions);
        results = extractQuantitativeKymographData(kymographs, curr_metadata, userOptions);
        
        close(userOptions.figHandle);

    end

    % play completion sound
    try
        play(handles.player);
    catch
        beep;
    end
    uiwait(msgbox('I''m done!x'));
    stop(handles.player);

    set(hObject, 'String', initialString);
    set(hObject, 'Enable', 'on');
else
    msgbox('Please check save root!');
end

function userOptions = getUserOptions(handles)

    userOptions = UserOptions();
    userOptions.outputFolder = get(handles.txtSaveRoot, 'String');
    if strcmp(get(handles.menuLumenOpening, 'Checked'), 'on')
        userOptions.lumenOpening = true;        % allow edges of duration >0.33 quant analysis time to be identified as real. 
    end

function params = getParams()

handles = guidata(gcf);

xy = handles.cutLine.getPosition();

params.date = get(handles.txtDate, 'String');
params.embryoNumber = str2num(get(handles.txtENumber, 'String'));
params.cutStartX = round(xy(1,1));
params.cutEndX = round(xy(2,1));
params.cutStartY = round(xy(1,2));
params.cutEndY = round(xy(2,2));
params.pixelSize = str2num(get(handles.txtPixelSize, 'String'));
params.frameTime = str2num(get(handles.txtFrameTime, 'String'));
if get(handles.radioUp, 'Value')
    params.dir = 1;
elseif get(handles.radioDown, 'Value')
    params.dir = 0;
elseif get(handles.radioBoth, 'Value');
    params.dir = [0 1];
end
params.firstFrame = get(handles.scrollFirstFrame, 'Value');
params.lastFrame = get(handles.scrollLastFrame, 'Value');
params.analysisTime = get(handles.scrollAnalysisTime, 'Value');
params.kymSpacingUm = str2num(get(handles.txtKymSpacingUm, 'String'));
params.speedInUmPerMinute = strcmp(get(handles.menuUmPerMin, 'Checked'), 'on');
params.kernelSize = handles.params.kernelSize;
params.kymWidth = handles.params.kymWidth;
params.kymLength = handles.params.kymLength;
params.zPlanes = handles.params.zPlanes;
params.sequenceLength = handles.params.sequenceLength;
params.channels = handles.params.channels;
params.CZTOrder = handles.params.CZTOrder;

% --- Executes on button press in buttonBrowseImagePath.
function buttonBrowseImagePath_Callback(hObject, eventdata, handles)
% hObject    handle to buttonBrowseImagePath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(gcf);

[fname, pname, ~] = uigetfile({'*.czi'; '*.tif'; '*.tiff'});

set(handles.txtImagePath, 'String', [pname fname]);
handles = imagePathChanged({[pname fname]}, hObject);

handles.cutLine = imline(handles.axImage, [handles.params.cutStartX handles.params.cutEndX], ...
            [handles.params.cutStartY handles.params.cutEndY]);
cut_line_len = sqrt((handles.params.cutStartX - handles.params.cutEndX)^2 + ...
    (handles.params.cutStartY - handles.params.cutEndY)^2);
set(handles.cutLine, 'ButtonDownFcn', {@cutLine_ButtonDownFcn, handles})

addNewPositionCallback(handles.cutLine,@updateLinePos);

% handles.params = params;

% Update handles structure
guidata(hObject, handles);

set(handles.txtCurrentLineUm, 'String', sprintf('Current line length = %0.2f um', cut_line_len* handles.params.pixelSize));


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

imagePathChanged(input, hObject);

handles.cutLine = imline(handles.axImage, [handles.params.cutStartX handles.params.cutEndX], ...
            [handles.params.cutStartY handles.params.cutEndY]);
set(handles.cutLine, 'ButtonDownFcn', {@cutLine_ButtonDownFcn, handles})

addNewPositionCallback(handles.cutLine,updateLinePos);

% Update handles structure
guidata(hObject, handles);

% --- handles changes to image path independently of source of change. 
function handles = imagePathChanged(new_image_path, hObject)
handles = guidata(gcf);

% check that new image path is a character string, anc dialog hasn't been
% cancelled
if ischar(new_image_path{1})
    % make sure UI reflects underlying data
    set(handles.txtImagePath, 'String', new_image_path);

    % check that path is a .czi file
    [pathstr,~,ext] = fileparts(new_image_path{1});
    if ~strcmp(ext, '.czi') && ~strcmp(ext, '.tif')
        % TODO: add functionality for TIFF import. 
        errorHandler('Image must be CZI/OME-TIFF format!');
    else
        try
            % load first frame to image preview pane
    %         data = bfopen(new_image_path{1});
    %         omeMeta = data{1,4};
    %         im = data{1}{1};
            % don't load whole series yet...
            handles.reader = bfGetReader(new_image_path{1});
            
            if strcmp(ext, '.tif')
                answer = questdlg('Extract metadata from CZI or populate manually?', 'Select metadata location...', 'CZI', 'Manual entry', 'CZI');
                if strcmp(answer, 'CZI')
                    [metaFName, metaPName, ~] = uigetfile('*.czi', 'Locate the original .czi file for metadata...', pathstr);
                    metareader = bfGetReader([metaPName filesep metaFName]);
                    omeMeta = metareader.getMetadataStore();
                    set(handles.menuBleachPower, 'Enable', 'on');
                else
                    % generate figure for input of metadata
                    metaOut = uiMetaInput(new_image_path{1}, handles.reader);
                    omeMeta = metaOut.omeMeta;
                end
            else
                omeMeta = handles.reader.getMetadataStore();
                set(handles.menuBleachPower, 'Enable', 'on');
            end
            
            handles.omeMeta = omeMeta;
            handles.currentDispFrame = 1;
            im = bfGetPlane(handles.reader, 1);
            padim = zeros(size(im, 1)+200, size(im, 2)+200);
            padim(100:99+size(im, 1), 100:99+size(im, 2)) = im;
            im = padim;
            clear padim; 
            
            handles.currentIm = im;
            
            imagesc(im, 'Parent', handles.axImage);
            colormap gray;
            set(gca, 'XTick', []);
            set(gca, 'YTick', []);
            axis equal tight;

             % figure out and populate default parameters
            handles.params.pixelSize = double(omeMeta.getPixelsPhysicalSizeX(0).value(ome.units.UNITS.MICROM));
            handles.params.sequenceLength = double(omeMeta.getPixelsSizeT(0).getValue());
            handles.params.firstFrame = 1;
            handles.params.lastFrame = handles.params.sequenceLength;
            handles.params.zPlanes = double(omeMeta.getPixelsSizeZ(0).getValue());
            handles.params.channels = double(omeMeta.getPixelsSizeC(0).getValue());
            dimOrder = char(omeMeta.getPixelsDimensionOrder(0).getValue());
            handles.params.CZTOrder = [regexp(dimOrder, 'C'); regexp(dimOrder, 'Z'); regexp(dimOrder, 'T')];
            if strcmp(dimOrder(end), 'T')
                handles.params.frameTime = double(omeMeta.getPlaneDeltaT(0, 1 + (handles.params.zPlanes - 1) + (handles.params.channels - 1)).value()) - double(omeMeta.getPlaneDeltaT(0, 0).value());
            elseif (strcmp(dimOrder(2), 'T') && strcmp(dimOrder(1), 'C'))
                handles.params.frameTime = double(omeMeta.getPlaneDeltaT(0, 1 + (handles.params.channels - 1)).value()) - double(omeMeta.getPlaneDeltaT(0, 0).value());
            elseif (strcmp(dimOrder(2), 'T') && strcmp(dimOrder(1), 'Z'))
                handles.params.frameTime = double(omeMeta.getPlaneDeltaT(0, 1 + (handles.params.zPlanes - 1)).value()) - double(omeMeta.getPlaneDeltaT(0, 0).value());
            else
                handles.params.frameTime = double(omeMeta.getPlaneDeltaT(0, 1).value()) - double(omeMeta.getPlaneDeltaT(0, 0).value());
            end
            handles.params.analysisTime = handles.params.frameTime * 20;
            if handles.reader.getGlobalMetadata.containsKey('Information|Document|CreationDate #1')
                handles.params.date = handles.reader.getGlobalMetadata.get('Information|Document|CreationDate #1');
                A = sscanf(handles.params.date, '%d-%d-%dT%s');
                handles.params.date = sprintf('%02d%02d%02d', A(3), A(2), A(1)-2000);   % assumes images taken this century - seems reasonable :)
            else
                handles.params.date = datestr(now, 'dddmmyy');
            end
%             guidata(hObject, handles);
            handles.params = updateUIParams(handles.params);
            
            handles.currentMask = zeros([size(im) handles.params.zPlanes]);
            handles.lastMask = handles.currentMask;

        catch ME
            errorHandler(ME);

        end

    end

end
    
% Update handles structure
guidata(hObject, handles);


function cutLine_ButtonDownFcn(hObject, eventdata, handles)
% handles = guidata(gcf);
disp('button down!');
   

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
% hObject    handle to buttonBrowseImagePath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(gcf);

filename = get(handles.txtImagePath, 'String');
if iscell(filename)
    filename = filename{1};
end
[default_folder ,~,~] = fileparts(filename) 
pname = uigetdir(default_folder);

set(handles.txtSaveRoot, 'String', pname);

% Update handles structure
guidata(hObject, handles);


function txtStartX_Callback(hObject, eventdata, handles)
% hObject    handle to txtStartX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtStartX as text
%        str2double(get(hObject,'String')) returns contents of txtStartX as a double

handles = guidata(gcf);
% handles.params.cutStartX = str2double(get(hObject, 'String'));
% set(hObject, 'Enable', 'inactive');
xy = handles.cutLine.getPosition();
xy(1,1) = str2double(get(hObject, 'String'));
handles.cutLine.setPosition(xy);

guidata(hObject, handles);


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
handles = guidata(gcf);
% handles.params.cutStartY = str2double(get(hObject, 'String'));
% set(hObject, 'Enable', 'inactive');
xy = handles.cutLine.getPosition();
xy(1,2) = str2double(get(hObject, 'String'));
handles.cutLine.setPosition(xy);

guidata(hObject, handles);


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
handles = guidata(gcf);
% handles.params.cutEndX = str2double(get(hObject, 'String'));
% set(hObject, 'Enable', 'inactive');
xy = handles.cutLine.getPosition();
xy(2,1) = str2double(get(hObject, 'String'));
handles.cutLine.setPosition(xy);

guidata(hObject, handles);

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
handles = guidata(gcf);
% handles.params.cutEndY = str2double(get(hObject, 'String'));
% set(hObject, 'Enable', 'inactive');
xy = handles.cutLine.getPosition();
xy(2,2) = str2double(get(hObject, 'String'));
handles.cutLine.setPosition(xy);

guidata(hObject, handles);

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
function menuOptions_Callback(hObject, eventdata, handles)
% hObject    handle to menuOptions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuSelectUnits_Callback(hObject, eventdata, handles)
% hObject    handle to menuSelectUnits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on mouse press over axes background.
function axImage_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if (get(handles.chkExclusionMask, 'Value') == 1)

    % get current mask to modify
    exclude_mask_temp = squeeze(handles.currentMask(:, :, handles.params.currZPlane));
    
    % get current displayed image
    curr_im_obj = findobj('Type', 'image', 'Parent', handles.axImage);
    im = get(curr_im_obj, 'CData');
    
    % get freehand selection:
    M = imfreehand(gca, 'Closed', 1);
    exclude_mask_temp = exclude_mask_temp + M.createMask;
    
    lowMemMaskTemp.mask = M;
    lowMemMaskTemp.z = handles.params.currZPlane;
    lowMemMaskTemp.t = handles.params.currTPlane;
    
    handles.lowMemMask = [handles.lowMemMask; lowMemMaskTemp];

    % put temp mask into right page of multipage mask
    handles.lastMask  = handles.currentMask;
    handles.currentMask(:, :, handles.params.currZPlane) = exclude_mask_temp;

    % apply mask to displayed image and re-display
%     im(logical(exclude_mask_temp)) = 0;
    im = applyLowMemMaskToImage(im, handles);
    set(curr_im_obj, 'CData', im, 'HitTest', 'off', 'ButtonDownFcn', {@axImage_ButtonDownFcn, hObject, eventdata, handles});
%     h = imagesc(im, 'Parent', handles.axImage,'HitTest', 'off', 'ButtonDownFcn', {@axImage_ButtonDownFcn, hObject, eventdata, handles});
    set(handles.axImage, 'ButtonDownFcn', {@axImage_ButtonDownFcn, handles});
    delete(M);
    
end

guidata(hObject, handles);

function im = applyLowMemMaskToImage(im, handles)

    % extract subset of masks that apply to the current Z, T frames
    ts = [handles.lowMemMask.t];
    zs = [handles.lowMemMask.z];
    submasks = handles.lowMemMask((ts == handles.params.currTPlane) & ((zs == handles.params.currZPlane)));
    
    % loop through subset to generate a binary mask image
    binMask = zeros(size(im));
    for m = submasks.mask
        
        binMask = binMask + m.createMask;
        
    end
    
    % apply to image
    im(logical(binMask)) = 0;
    

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over txtStartX.
function txtStartX_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to txtStartX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(gcf);
set(handles.txtStartX, 'Enable', 'on');

if isfield(handles, 'cutLine')
    xy = handles.cutLine.getPosition();
    handles.params.cutStartX = round(xy(1,1));
    handles.params.cutEndX = round(xy(2,1));
    handles.params.cutStartY = round(xy(1,2));
    handles.params.cutEndY = round(xy(2,2));
    guidata(hObject, handles);
    handles.params = updateUIParams(handles.params);
end

guidata(hObject, handles);


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over txtEndX.
function txtEndX_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to txtEndX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(gcf);
set(handles.txtEndX, 'Enable', 'on');

if isfield(handles, 'cutLine')
    xy = handles.cutLine.getPosition();
    handles.params.cutStartX = round(xy(1,1));
    handles.params.cutEndX = round(xy(2,1));
    handles.params.cutStartY = round(xy(1,2));
    handles.params.cutEndY = round(xy(2,2));
    guidata(hObject, handles);
    handles.params = updateUIParams(handles.params);
end

guidata(hObject, handles);


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over txtStartY.
function txtStartY_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to txtStartY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(gcf);
set(handles.txtStartY, 'Enable', 'on');

if isfield(handles, 'cutLine')
    xy = handles.cutLine.getPosition();
    handles.params.cutStartX = round(xy(1,1));
    handles.params.cutEndX = round(xy(2,1));
    handles.params.cutStartY = round(xy(1,2));
    handles.params.cutEndY = round(xy(2,2));
    guidata(hObject, handles);
    handles.params = updateUIParams(handles.params);
end

guidata(hObject, handles);


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over txtEndY.
function txtEndY_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to txtEndY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(gcf);

if isfield(handles, 'cutLine')
    xy = handles.cutLine.getPosition();
    handles.params.cutStartX = round(xy(1,1));
    handles.params.cutEndX = round(xy(2,1));
    handles.params.cutStartY = round(xy(1,2));
    handles.params.cutEndY = round(xy(2,2));
    guidata(hObject, handles);
    handles.params = updateUIParams(handles.params);
end

guidata(hObject, handles);


% --- Executes when selected object is changed in panelKymDir.
function panelKymDir_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in panelKymDir 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)

switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
    case 'radioUp'
        handles.params.dir = 1;
    case 'radioDown'
        handles.params.dir = 0;
    case 'radioBoth'
        handles.params.dir = [0 1];
    
end


function updateLinePos(hObject, eventdata)

handles = guidata(gcf);

set(handles.txtStartX, 'String', num2str(hObject(1)));
set(handles.txtEndX, 'String', num2str(hObject(2)));
set(handles.txtStartY, 'String', num2str(hObject(3)));
set(handles.txtEndY, 'String', num2str(hObject(4)));

cut_line_len = sqrt((hObject(1) - hObject(2))^2 + ...
    (hObject(3) - hObject(4))^2);
set(handles.txtCurrentLineUm, 'String', sprintf('Current line length = %0.2f um', cut_line_len * handles.params.pixelSize));


function txtKymSpacingUm_Callback(hObject, eventdata, handles)
% hObject    handle to txtKymSpacingUm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtKymSpacingUm as text
%        str2double(get(hObject,'String')) returns contents of txtKymSpacingUm as a double
handles = guidata(gcf);
handles.params.kymSpacingUm = str2num(get(hObject, 'String'));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function txtKymSpacingUm_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtKymSpacingUm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function scrollFirstFrame_Callback(hObject, eventdata, handles)
% hObject    handle to scrollFirstFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Coerce values here to prevent seeing disconcerting behaviour associated
% with changing slider min and max dynamically. 

handles = guidata(gcf);

new_first_frame = round(get(hObject, 'Value'));

if new_first_frame >= handles.params.lastFrame
    new_first_frame = handles.params.lastFrame - 1;
    set(hObject, 'Value', new_first_frame);
end

if (handles.params.lastFrame - new_first_frame) * handles.params.frameTime < handles.params.analysisTime
    handles.params.analysisTime = (handles.params.lastFrame - new_first_frame) * handles.params.frameTime;
    set(handles.scrollAnalysisTime, 'Value', handles.params.analysisTime);
end

handles.params.firstFrame = new_first_frame;
handles.params.currTPlane = new_first_frame;
handles.params = updateUIParams(handles.params);

% handles.currentDispFrame = new_first_frame * handles.params.channels;
handles.currentDispFrame = handles.reader.getIndex(handles.params.currZPlane - 1, ...
    handles.params.currCPlane - 1, handles.params.currTPlane - 1) + 1;

% updateDisplayImage(handles.currentDispFrame, hObject, handles);

im = bfGetPlane(handles.reader, handles.currentDispFrame);
padim = zeros(size(im, 1)+200, size(im, 2)+200);
padim(100:99+size(im, 1), 100:99+size(im, 2)) = im;
im = padim;
clear padim; 
handles.currentIm = im;
im(logical(squeeze(handles.currentMask(:, :,...
 handles.params.currZPlane)))) = 0;

curr_im_obj = findobj('Type', 'image', 'Parent', handles.axImage);
set(curr_im_obj, 'CData', im);

if ( get(handles.chkExclusionMask, 'Value') == 1 )

    set(curr_im_obj, 'HitTest', 'off', 'ButtonDownFcn', {@axImage_ButtonDownFcn, hObject, eventdata, handles});
    set(handles.axImage, 'ButtonDownFcn', {@axImage_ButtonDownFcn, handles});
    
end

updateUIParams(handles.params);

set(handles.txtWhichFrame, 'String', sprintf('Currently displaying first frame (%d); time span of kymographs is %0.2f s; quantitative analysis over %0.2f s. ',...
    new_first_frame, handles.params.frameTime * (handles.params.lastFrame - new_first_frame), handles.params.analysisTime));
% uistack(handles.cutLine, 'top');

if strcmp(get(handles.menuShowROI, 'checked'), 'on')
%     delete(handles.roiOverlay);
    roiColor = checkRoiColor(handles.currentDispFrame);
    handles.roiOverlay = rectangle('Position', [100 + handles.omeMeta.getRectangleX(0, 0).longValue(), ...
        100 + handles.omeMeta.getRectangleY(0, 0).longValue(), handles.omeMeta.getRectangleWidth(0, 0).longValue(), ...
        handles.omeMeta.getRectangleHeight(0, 0).longValue()], 'Parent', handles.axImage, ...
        'EdgeColor', roiColor);
end

guidata(hObject, handles);

function updateDisplayImage(currentDisplayFrame, hObject, handles)

    im = bfGetPlane(handles.reader, currentDisplayFrame);
    padim = zeros(size(im, 1)+200, size(im, 2)+200);
    padim(100:99+size(im, 1), 100:99+size(im, 2)) = im;
    im = padim;
    clear padim; 
    handles.currentIm = im;
    im(logical(squeeze(handles.currentMask(:, :, currentDisplayFrame)))) = 0;

    % curr_im_obj = get(handles.axImage, 'Children');
    % curr_im_obj = curr_im_obj(2);
    curr_im_obj = findobj('Type', 'image', 'Parent', handles.axImage);
    set(curr_im_obj, 'CData', im);

    if ( get(handles.chkExclusionMask, 'Value') == 1 )

        set(curr_im_obj, 'HitTest', 'off', 'ButtonDownFcn', {@axImage_ButtonDownFcn, hObject, eventdata, handles});
        set(handles.axImage, 'ButtonDownFcn', {@axImage_ButtonDownFcn, handles});
    end
    
    guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function scrollFirstFrame_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scrollFirstFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function scrollLastFrame_Callback(hObject, eventdata, handles)
% hObject    handle to scrollLastFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% Coerce values here to prevent seeing disconcerting behaviour associated
% with changing slider min and max dynamically. 

handles = guidata(gcf);

new_last_frame = round(get(hObject, 'Value'));

if new_last_frame <= handles.params.firstFrame
    new_last_frame = handles.params.firstFrame + 1;
    set(hObject, 'Value', new_last_frame);
end

if (new_last_frame - handles.params.firstFrame) * handles.params.frameTime < handles.params.analysisTime
    handles.params.analysisTime = (new_last_frame - handles.params.firstFrame) * handles.params.frameTime;
    set(handles.scrollAnalysisTime, 'Value', handles.params.analysisTime);
end

handles.params.lastFrame = new_last_frame;
handles.params.currTPlane = new_last_frame;
handles.params = updateUIParams(handles.params);

channel = 1;
handles.currentDispFrame = handles.reader.getIndex(handles.params.currZPlane - 1, ...
    handles.params.currCPlane - 1, handles.params.currTPlane - 1) + 1;
im = bfGetPlane(handles.reader, handles.currentDispFrame);
padim = zeros(size(im, 1)+200, size(im, 2)+200);
padim(100:99+size(im, 1), 100:99+size(im, 2)) = im;
im = padim;
clear padim; 
handles.currentIm = im;
im(logical(squeeze(handles.currentMask(:, :,...
 handles.params.currZPlane)))) = 0;

curr_im_obj = findobj('Type', 'image', 'Parent', handles.axImage);
set(curr_im_obj, 'CData', im);

if ( get(handles.chkExclusionMask, 'Value') == 1 )

    set(curr_im_obj, 'HitTest', 'off', 'ButtonDownFcn', {@axImage_ButtonDownFcn, hObject, eventdata, handles});
    set(handles.axImage, 'ButtonDownFcn', {@axImage_ButtonDownFcn, handles});
    
end

updateUIParams(handles.params);

set(handles.txtWhichFrame, 'String', sprintf('Currently displaying last frame (%d); time span of kymographs is %0.2f s; quantitative analysis over %0.2f s. ',...
    new_last_frame, handles.params.frameTime * (new_last_frame - handles.params.firstFrame), handles.params.analysisTime));

if strcmp(get(handles.menuShowROI, 'checked'), 'on')
%     delete(handles.roiOverlay);
    roiColor = checkRoiColor(handles.currentDispFrame);
    handles.roiOverlay = rectangle('Position', [100 + handles.omeMeta.getRectangleX(0, 0).longValue(), ...
        100 + handles.omeMeta.getRectangleY(0, 0).longValue(), handles.omeMeta.getRectangleWidth(0, 0).longValue(), ...
        handles.omeMeta.getRectangleHeight(0, 0).longValue()], 'Parent', handles.axImage, ...
        'EdgeColor', roiColor);
end

guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function scrollLastFrame_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scrollLastFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function scrollAnalysisTime_Callback(hObject, eventdata, handles)
% hObject    handle to scrollAnalysisTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

handles = guidata(gcf);

new_anal_time = handles.params.frameTime * round(get(hObject, 'Value') / handles.params.frameTime);

if new_anal_time > handles.params.frameTime * ...
        (handles.params.lastFrame - handles.params.firstFrame)
    new_anal_time = handles.params.frameTime * ...
        (handles.params.lastFrame - handles.params.firstFrame);
    set(hObject, 'Value', new_anal_time);
end

handles.params.analysisTime = new_anal_time;
handles.params.currTPlane = round(get(hObject, 'Value') / handles.params.frameTime);
handles.params = updateUIParams(handles.params);


handles.currentDispFrame = handles.reader.getIndex(handles.params.currZPlane - 1, ...
    handles.params.currCPlane - 1, handles.params.currTPlane - 1) + 1;
im = bfGetPlane(handles.reader, handles.currentDispFrame);
padim = zeros(size(im, 1)+200, size(im, 2)+200);
padim(100:99+size(im, 1), 100:99+size(im, 2)) = im;
im = padim;
clear padim; 

handles.currentIm = im;
im(logical(squeeze(handles.currentMask(:, :,...
 handles.params.currZPlane)))) = 0;

curr_im_obj = findobj('Type', 'image', 'Parent', handles.axImage);
set(curr_im_obj, 'CData', im);

if ( get(handles.chkExclusionMask, 'Value') == 1 )

    set(curr_im_obj, 'HitTest', 'off', 'ButtonDownFcn', {@axImage_ButtonDownFcn, hObject, eventdata, handles});
    set(handles.axImage, 'ButtonDownFcn', {@axImage_ButtonDownFcn, handles});
    
end

updateUIParams(handles.params);

set(handles.txtWhichFrame, 'String', sprintf('Currently displaying last analysis frame (%d); time span of kymographs is %0.2f s; quantitative analysis over %0.2f s. ',...
    handles.params.firstFrame + (new_anal_time / handles.params.frameTime), handles.params.frameTime * (handles.params.lastFrame - handles.params.firstFrame), handles.params.analysisTime));

if strcmp(get(handles.menuShowROI, 'checked'), 'on')
%     delete(handles.roiOverlay);
    roiColor = checkRoiColor(handles.currentDispFrame);
    handles.roiOverlay = rectangle('Position', [100 + handles.omeMeta.getRectangleX(0, 0).longValue(), ...
        100 + handles.omeMeta.getRectangleY(0, 0).longValue(), handles.omeMeta.getRectangleWidth(0, 0).longValue(), ...
        handles.omeMeta.getRectangleHeight(0, 0).longValue()], 'Parent', handles.axImage, ...
        'EdgeColor', roiColor);
end

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function scrollAnalysisTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scrollAnalysisTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --------------------------------------------------------------------
function menuUmPerS_Callback(hObject, eventdata, handles)
% hObject    handle to menuUmPerS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(gcf);

disp(get(hObject, 'Checked'));

if strcmp(get(hObject, 'Checked'), 'off')
    set(hObject, 'Checked', 'on');
    handles.params.speedInUmPerMinute = false;
    set(handles.menuUmPerMin, 'Checked', 'off')
end

guidata(hObject, handles);


% --------------------------------------------------------------------
function menuUmPerMin_Callback(hObject, eventdata, handles)
% hObject    handle to menuUmPerMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(gcf);

disp(get(hObject, 'Checked'));

if strcmp(get(hObject, 'Checked'), 'off')
    set(hObject, 'Checked', 'on');
    handles.params.speedInUmPerMinute = false;
    set(handles.menuUmPerS, 'Checked', 'off')
end

guidata(hObject, handles);


% --------------------------------------------------------------------
function menuKernelSize_Callback(hObject, eventdata, handles)
% hObject    handle to menuKernelSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(gcf);

kstr = inputdlg({'Choose median filter kernel size'}, 'Median filter kernel size', 1, {num2str(handles.params.kernelSize)});
if isempty(kstr)
    handles.params.kernelSize = 1;
else
    handles.params.kernelSize = round(str2double(kstr{1}));
end

guidata(hObject, handles);



% --- Executes on button press in chkExclusionMask.
function chkExclusionMask_Callback(hObject, eventdata, handles)
% hObject    handle to chkExclusionMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% im = checkerboard(10, 10);
if ( get(hObject, 'Value') == 1 )
    im = handles.currentIm;
    im(logical(squeeze(handles.currentMask(:, :, handles.params.currZPlane)))) = 0;
%     h = imagesc(im, 'Parent', handles.axImage,'HitTest', 'off', 'ButtonDownFcn', {@axImage_ButtonDownFcn, hObject, eventdata, handles});
    curr_im_obj = findobj('Type', 'image', 'Parent', handles.axImage);
    set(curr_im_obj, 'CData', im, 'HitTest', 'off', 'ButtonDownFcn', {@axImage_ButtonDownFcn, hObject, eventdata, handles});
    set(handles.axImage, 'ButtonDownFcn', {@axImage_ButtonDownFcn, handles});
    axis equal tight;
else
    set(handles.axImage, 'ButtonDownFcn', {});
    im = handles.currentIm;
    im(logical(squeeze(handles.currentMask(:, :, handles.params.currZPlane)))) = 0;
%     h = imagesc(im, 'Parent', handles.axImage,'HitTest', 'off', 'ButtonDownFcn', {});
    curr_im_obj = findobj('Type', 'image', 'Parent', handles.axImage);
    set(curr_im_obj, 'CData', im, 'HitTest', 'off', 'ButtonDownFcn', {});
    axis equal tight;
end

% --------------------------------------------------------------------
function menuUndoMask_Callback(hObject, eventdata, handles)
% hObject    handle to menuUndoMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.currentMask = handles.lastMask;

channel = 1;
handles.currentDispFrame = (handles.params.zPlanes)*(handles.params.channels)*(handles.params.currTPlane - 1) + ...
    (handles.params.channels)*(handles.params.currZPlane - 1) + ...
    (handles.params.channels)*(channel - 1) + 1;
im = bfGetPlane(handles.reader, handles.currentDispFrame);
padim = zeros(size(im, 1)+200, size(im, 2)+200);
padim(100:99+size(im, 1), 100:99+size(im, 2)) = im;
im = padim;
clear padim; 
handles.currentIm = im;
im(logical(squeeze(handles.currentMask(:, :,...
 handles.params.currZPlane)))) = 0;

curr_im_obj = findobj('Type', 'image', 'Parent', handles.axImage);
set(curr_im_obj, 'CData', im);

if ( get(handles.chkExclusionMask, 'Value') == 1 )

    set(curr_im_obj, 'HitTest', 'off', 'ButtonDownFcn', {@axImage_ButtonDownFcn, hObject, eventdata, handles});
    set(handles.axImage, 'ButtonDownFcn', {@axImage_ButtonDownFcn, handles});
    
end

guidata(hObject, handles);




% --------------------------------------------------------------------
function menuFile_Callback(hObject, eventdata, handles)
% hObject    handle to menuFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuLoadMask_Callback(hObject, eventdata, handles)
% hObject    handle to menuLoadMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

reply = questdlg('Replace existing masks?', 'Replace existing masks?', ...
    'No');

if strcmp(reply, 'Yes')
    
    [fname, pname, ~] = uigetfile('*.tif', 'Locate existing mask data to load...');
    
    if (fname ~= -0)
        handles.lastMask = handles.currentMask;
        handles.currentMask = loadMultipageTiff([pname filesep fname]);
        
        im = handles.currentIm;
        im(logical(squeeze(handles.currentMask(:, :, handles.params.currZPlane)))) = 0;
        curr_im_obj = findobj('Type', 'image', 'Parent', handles.axImage);
        set(curr_im_obj, 'CData', im, 'HitTest', 'off', 'ButtonDownFcn', {});
        axis equal tight;
    
    end
end

guidata(hObject, handles);
    

% --------------------------------------------------------------------
function menuSaveMask_Callback(hObject, eventdata, handles)
% hObject    handle to menuSaveMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[fname, pname] = uiputfile('*.tif', 'Choose location to save mask tiff...');

if (fname ~= 0)
    saveMultipageTiff(handles.currentMask, [pname filesep fname]);
    
    [ffname, ppname] = uiputfile('*.tif', 'Choose location to save masked tiff', pname);
    
    if (ffname ~= 0)
        % use bioformats to write data with mask applied to an OME-TIFF
        % with metadata attached. 
        
    end
    
end


% --------------------------------------------------------------------
function menuRemoveMask_Callback(hObject, eventdata, handles)
% hObject    handle to menuRemoveMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

button = questdlg('Are you sure?','Remove all masks?','No');

if strcmp(button, 'Yes')
    curr_im_obj = findobj('Type', 'image', 'Parent', handles.axImage);
    set(curr_im_obj, 'CData', handles.currentIm);

    handles.lastMask = handles.currentMask;
    handles.currentMask = zeros([size(handles.currentIm) handles.params.zPlanes]);
    
    handles.lastLowMemMask = handles.lowMemMask;
    handles.lowMemMask = [];
%     applyLowMemMaskToImage(handles.currentIm, handles);
end

guidata(hObject, handles);

% --- Executes on slider movement.
function scrollZPlane_Callback(hObject, eventdata, handles)
% hObject    handle to scrollZPlane (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(gcf);

handles.params.currZPlane = round(get(hObject, 'Value'));
handles.params = updateUIParams(handles.params);
disp(handles.params.currZPlane);

% display frame
handles.currentDispFrame = handles.reader.getIndex(handles.params.currZPlane - 1, ...
    handles.params.currCPlane - 1, handles.params.currTPlane - 1) + 1;
% handles.currentDispFrame = handles.params.currZPlane;
disp(handles.currentDispFrame);

im = bfGetPlane(handles.reader, handles.currentDispFrame);
padim = zeros(size(im, 1)+200, size(im, 2)+200);
padim(100:99+size(im, 1), 100:99+size(im, 2)) = im;
im = padim;
clear padim; 
handles.currentIm = im;
im(logical(squeeze(handles.currentMask(:, :,...
 handles.params.currZPlane)))) = 0;

curr_im_obj = findobj('Type', 'image', 'Parent', handles.axImage);
set(curr_im_obj, 'CData', im);

if ( get(handles.chkExclusionMask, 'Value') == 1 )

    set(curr_im_obj, 'HitTest', 'off', 'ButtonDownFcn', {@axImage_ButtonDownFcn, hObject, eventdata, handles});
    set(handles.axImage, 'ButtonDownFcn', {@axImage_ButtonDownFcn, handles});
    
end

updateUIParams(handles.params);

guidata(hObject, handles);




% --- Executes during object creation, after setting all properties.
function scrollZPlane_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scrollZPlane (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --------------------------------------------------------------------
function menuShowROI_Callback(hObject, eventdata, handles)
% hObject    handle to menuShowROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = guidata(gcf);

if strcmp(get(hObject, 'checked'), 'off')
    
    set(hObject, 'checked', 'on');

    roiColor = checkRoiColor(handles.params.currTPlane);

    handles.roiOverlay = rectangle('Position', [100 + handles.omeMeta.getRectangleX(0, 0).longValue(), ...
        100 + handles.omeMeta.getRectangleY(0, 0).longValue(), handles.omeMeta.getRectangleWidth(0, 0).longValue(), ...
        handles.omeMeta.getRectangleHeight(0, 0).longValue()], 'Parent', handles.axImage, ...
        'EdgeColor', roiColor);
else
    set(hObject, 'checked', 'off');
    if isfield(handles, 'roiOverlay')
        set(handles.roiOverlay, 'Visible', 'off');
    end
end

guidata(hObject, handles);

function roiColor = checkRoiColor(tPlane)

handles = guidata(gcf);

% check if before or after bleaching frame, and apply colour
% accordingly
bleachStartKey = 'Experiment|AcquisitionBlock|MultiTrackSetup|TrackSetup|BleachSetup|BleachParameterSet|StartNumber #1';
if handles.reader.getGlobalMetadata.containsKey(bleachStartKey)
    if (tPlane >= str2double(handles.reader.getGlobalMetadata.get(bleachStartKey)))
        roiColor = 'c';
    else
        roiColor = 'm';
    end
else
    roiColor = 'm';
end


% --------------------------------------------------------------------
function menuSaveBleachTiff_Callback(hObject, eventdata, handles)
% hObject    handle to menuSaveBleachTiff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = guidata(gcf);

qans = inputdlg({'Number of seconds before bleach to save?',...
    'Number of seconds after bleach to save?'}, 'Multipage tiff options...', ...
    1, {num2str(handles.params.multipageTiffBeforeTimeS), num2str(handles.params.multipageTiffAfterTimeS)});

% deal with case when non-numeric string is entered by accident...
if any(isnan(str2double(qans)))
    msgbox('Please enter only numeric values for the number of seconds either side of the bleach to save!');
    return;
end

% work out what the bleach frame # is...
if handles.reader.getGlobalMetadata.containsKey('Experiment|AcquisitionBlock|MultiTrackSetup|TrackSetup|BleachSetup|BleachParameterSet|StartNumber #1')
    bleachFrame = str2double(handles.reader.getGlobalMetadata.get('Experiment|AcquisitionBlock|MultiTrackSetup|TrackSetup|BleachSetup|BleachParameterSet|StartNumber #1'));
else
    msgbox('No bleach frame detected in metadata!');
    return;
end

    
if ~isempty(qans)
    handles.params.multipageTiffBeforeTimeS = str2double(qans{1});
    handles.params.multipageTiffAfterTimeS = str2double(qans{2});
    
    guidata(gcf, handles);
    
    % deal with case when user-entered # seconds either side of bleach is
    % impossible because it overflows the extent of the stack...
    framesBefore = ceil(handles.params.multipageTiffBeforeTimeS/handles.params.frameTime);
    framesAfter = ceil(handles.params.multipageTiffAfterTimeS/handles.params.frameTime);
    if ( ( (bleachFrame - framesBefore) < 1 ) || ( (bleachFrame + framesAfter) > handles.params.sequenceLength) )
        msgbox('Please choose a time that fits between the bleach frame and the sequence start/end!', 'IMPOSSIBLE!');
        return;
    end

    defPath = get(handles.txtImagePath, 'String');
    defPath = defPath{1};
    [defPath, ~, ~] = fileparts(defPath);
    [fname, pname, ~] = uiputfile('*.tif', 'Choose where to save the output tiff...', [defPath filesep 'bleach tiff.tif']);

    if pname ~= 0 

        RGBim = uint8(zeros(handles.reader.getSizeX+200, handles.reader.getSizeY+200, 3));
        gScale = uint8(zeros(handles.reader.getSizeX+200, handles.reader.getSizeY+200));

        for ind = 1:(framesBefore + framesAfter + 1)

            gScale(100:99 + handles.reader.getSizeX, 100:99 + handles.reader.getSizeY) = ...
                uint8(bfGetPlane(handles.reader, bleachFrame - framesBefore + ind - 1));


            % convert ROI to mask; set these pixels to 1 on first plane of RGBim
            % and 0 on second and third planes. 
            if strcmp(get(handles.menuShowROI, 'checked'), 'on')

                pos = get(handles.roiOverlay, 'Position');
                xs = [pos(1) pos(1)+pos(3) pos(1)+pos(3) pos(1)];
                ys = [pos(2) pos(2) pos(2)+pos(4) pos(2)+pos(4)];
                xs2 = [pos(1)+1 pos(1)+pos(3)-1 pos(1)+pos(3)-1 pos(1)+1];
                ys2 = [pos(2)+1 pos(2)+1 pos(2)+pos(4)-1 pos(2)+pos(4)-1];
                bw1 = poly2mask(xs, ys, handles.reader.getSizeX+200, handles.reader.getSizeY+200);
                bw2 = poly2mask(xs2, ys2, handles.reader.getSizeX+200, handles.reader.getSizeY+200);
                bw = logical(bw1 - bw2);
                
                % show ROI in magenta before bleach, cyan after bleach
                % TODO - vectorise so can be more easily broken out into a
                % function...
                if ind < (framesBefore + 1)
                    gScale(bw) = max(gScale(:));
        %             gScale(bw) = 255;
                    RGBim(:,:,1) = gScale;
                    RGBim(:,:,3) = gScale;
                    gScale(bw) = 0;
                    RGBim(:,:,2) = gScale;
                else
                    gScale(bw) = max(gScale(:));
        %             gScale(bw) = 255;
                    RGBim(:,:,2) = gScale;
                    RGBim(:,:,3) = gScale;
                    gScale(bw) = 0;
                    RGBim(:,:,1) = gScale;
                    
                end
            else
                RGBim(:,:,1) = gScale;
                RGBim(:,:,2) = gScale;
                RGBim(:,:,3) = gScale;
            end

            if ind == 1
                imwrite(RGBim, [pname fname])
            else
                imwrite(RGBim, [pname fname], 'WriteMode','append');
            end

        end

    end
end

guidata(gcf, handles);



% --------------------------------------------------------------------
function menuBleachPower_Callback(hObject, eventdata, handles)
% hObject    handle to menuBleachPower (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

nope = 'NOT FOUND IN METADATA!';
bleachPowerKey = 'Experiment|AcquisitionBlock|MultiTrackSetup|TrackSetup|BleachSetup|BleachParameterSet|Attenuator|Transmission #1';
zoomKey = 'Experiment|AcquisitionBlock|AcquisitionModeSetup|ZoomY #1';
bleachStartKey = 'Experiment|AcquisitionBlock|MultiTrackSetup|TrackSetup|BleachSetup|BleachParameterSet|StartNumber #1';
repeatAfterFramesKey = 'Experiment|AcquisitionBlock|MultiTrackSetup|TrackSetup|BleachSetup|BleachParameterSet|Repeat #1';
noBleachesKey = 'Experiment|AcquisitionBlock|MultiTrackSetup|TrackSetup|BleachSetup|BleachParameterSet|Cycles #1';
pixelDwellKey = 'Information|Image|Channel|LaserScanInfo|PixelTime #1';
ROIXKey = 'Layer|Rectangle|Geometry|Width #1';
ROIYKey = 'Layer|Rectangle|Geometry|Height #1';

str = '';
str = [str sprintf('The bleach power attenuator is set to ')];
if handles.reader.getGlobalMetadata.containsKey(bleachPowerKey)
    str = [str sprintf('%s\n\r', handles.reader.getGlobalMetadata.get(bleachPowerKey))];
else
    str = [str sprintf('%s\n\r', nope)];
end

str = [str 'Zoom is set to '];
if handles.reader.getGlobalMetadata.containsKey(zoomKey)
    str = [str sprintf('%s x\n\r', handles.reader.getGlobalMetadata.get(zoomKey))];
else
    str = [str sprintf('%s\n\r', nope)];
end

str = [str 'Bleach starts at frame '];
if handles.reader.getGlobalMetadata.containsKey(bleachStartKey)
    str = [str sprintf('%s\n\r', handles.reader.getGlobalMetadata.get(bleachStartKey))];
else
    str = [str sprintf('%s\n\r', nope)];
end

str = [str 'Repeat after '];
if handles.reader.getGlobalMetadata.containsKey(repeatAfterFramesKey)
    str = [str sprintf('%s frames\n\r', handles.reader.getGlobalMetadata.get(repeatAfterFramesKey))];
else
    str = [str sprintf('%s\n\r', nope)];
end

str = [str 'Bleach iterations: '];
if handles.reader.getGlobalMetadata.containsKey(noBleachesKey)
    str = [str sprintf('%s\n\r', handles.reader.getGlobalMetadata.get(noBleachesKey))];
else
    str = [str sprintf('%s\n\r', nope)];
end

str = [str 'Pixel dwell time: '];
if handles.reader.getGlobalMetadata.containsKey(pixelDwellKey)
    str = [str sprintf('%0.2f us\n\r', (10^6)*str2double(handles.reader.getGlobalMetadata.get(pixelDwellKey)))];
else
    str = [str sprintf('%s\n\r', nope)];
end

str = [str 'ROI size: '];
if ((handles.reader.getGlobalMetadata.containsKey(ROIXKey)) && (handles.reader.getGlobalMetadata.containsKey(ROIYKey)))
    str = [str sprintf('%0.2fx%0.2f\n\r', str2double(handles.reader.getGlobalMetadata.get(ROIXKey)), str2double(handles.reader.getGlobalMetadata.get(ROIYKey)))];
else
    str = [str sprintf('%s\n\r', nope)];
end

    msgbox(str, 'Selected metadata');




% --------------------------------------------------------------------
function menuKymWidth_Callback(hObject, eventdata, handles)
% hObject    handle to menuKymWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(gcf);

kstr = inputdlg({'Choose kymograph width in pixels'}, 'Kymograph width', 1, {num2str(handles.params.kymWidth)});
if isempty(kstr)
    handles.params.kymWidth = 1;
else
    handles.params.kymWidth = round(str2double(kstr{1}));
end

guidata(hObject, handles);


% --------------------------------------------------------------------
function menuKymAxisLength_Callback(hObject, eventdata, handles)
% hObject    handle to menuKymAxisLength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(gcf);

kstr = inputdlg({'Choose kymograph length in pixels'}, 'Kymograph length', 1, {num2str(handles.params.kymLength)});
if isempty(kstr)
    handles.params.kymLength = 50;
else
    handles.params.kymLength = round(str2double(kstr{1}));
end

guidata(hObject, handles);


% --------------------------------------------------------------------
function menuLumenOpening_Callback(hObject, eventdata, handles)
% hObject    handle to menuLumenOpening (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmp(get(handles.menuLumenOpening, 'Checked'), 'on')
    set(handles.menuLumenOpening, 'Checked', 'off');
    set(handles.menuLumenBasal, 'Enable', 'off');
else
    set(handles.menuLumenOpening, 'Checked', 'on');
    set(handles.menuLumenBasal, 'Enable', 'on');
end


% --------------------------------------------------------------------
function menuLumenBasal_Callback(hObject, eventdata, handles)
% hObject    handle to menuLumenBasal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

thisFigH = gcf;

if strcmp(get(handles.menuLumenBasal, 'Checked'), 'on')
    set(handles.menuLumenBasal, 'Checked', 'off');
else
    
    svRoot = get(handles.txtSaveRoot, 'String');
    if ~strcmp(svRoot, 'Enter path...') && isdir(svRoot)
        set(handles.menuLumenBasal, 'Checked', 'on');

        dum = get(handles.txtImagePath, 'String');
        [basepath, filename, ~] = fileparts(dum{1});
        % get relevant data from the spreadsheet from analysis of apical
        % movements

    %     [~, sh, ~] = xlsfinfo([p f]);
    %     answer = questdlg('Choose the appropriate sheet to use:', ...
    %         'Which sheet?', sh)

        if isfield(handles, 'lumenOpeningXLFile')
            answer = questdlg('Use previous lumen opening analysis spreadsheet?', 'Yes', 'No');
            if strcmp(answer, 'No')
                [f,p,~] = uigetfile({'*.xlsx'; '*.xls'; '*.csv'}, 'Choose spreadsheet with previous apical analysis...', ...
            basepath);
                handles.lumenOpeningXLFile = [p f];
            end
            [~, ~, dum] = xlsread(handles.lumenOpeningXLFile, 2);
        else
            [f,p,~] = uigetfile({'*.xlsx'; '*.xls'; '*.csv'}, 'Choose spreadsheet with previous apical analysis...', ...
                basepath);
            handles.lumenOpeningXLFile = [p f];
            [~, ~, dum] = xlsread(handles.lumenOpeningXLFile, 2);
        end


        expTime = regexp(filename, '__', 'split');
        expTime = expTime{2};
        expTimeStr = [expTime(1:2) expTime(4:5)];
        fileRef = dum(2:end, strcmp(dum(1, :), 'File ref'));
        k = cell(length(fileRef), 1);
        k(:) = {expTimeStr};
        indices = find(~cellfun(@isempty,cellfun(@strfind, fileRef, k, 'UniformOutput', false))) +1;

        % get relevant cut positions - need to figure out which experiment
        % folder (GET THIS FROM DATA LOCATION - ENSURE THAT ALL DATA IS PLACED
        % CONSISTENTLY WRT ANALYSIS and which  subfolder to look in for 
        % trimmed_cut_info
        subfldrs = dir([basepath filesep expTimeStr filesep '*']);
        subfldrs = subfldrs([subfldrs.isdir]);
        subfldrs = subfldrs(3:end);
        
        for subfldr = subfldrs
            userOptions.outputFolder = get(handles.txtSaveRoot, 'String');
            fldr = dir([basepath filesep expTimeStr filesep subfldr.name filesep get(handles.txtDate, 'String') '*']);
            fldr = fldr([fldr.isdir]);
            tcinffile = [basepath filesep expTimeStr filesep subfldr.name filesep fldr.name filesep 'trimmed_cutinfo_cut_1.txt'];
            padxcut = getNumericMetadataFromText(tcinffile, 'metadata.kym_region.xcut'); %+ 100; % account for padding
            padycut = getNumericMetadataFromText(tcinffile, 'metadata.kym_region.ycut'); %+ 100; % account for padding

            % get relevant frames to generate kymographs for based on xstart, end
            % CHECK WHETHER START AND END FRAMES ARE CONSISTENT WHEN GENERATING
            % KYMOGRAPHS - should save this as metadata output from cziFig
            kym_indices_to_keep = dum(indices, strcmp(dum(1, :), 'Kymo index'));
            kym_indices_to_keep = unique([kym_indices_to_keep{:}]);

            hs = get(handles.axImage, 'Children');
            im = get(hs(strcmp(get(hs, 'Type'), 'image')), 'CData');

            curr_metadata = getMetadataFromOME(handles.omeMeta, handles.params);

            userOptions = getUserOptions(handles);
            set(userOptions.figHandle, 'Visible', 'off')
            userOptions.medianFiltKernelSize = handles.params.kernelSize;
            userOptions.kym_width = handles.params.kymWidth;
            userOptions.kym_length = handles.params.kymLength;
            userOptions.showKymographOverlapOverlay = true;
            userOptions.kymSpacingUm = str2double(get(handles.txtKymSpacingUm, 'String'));
            userOptions.speedInUmPerMinute = handles.params.speedInUmPerMinute;

            userOptions.timeBeforeCut = 0;
            userOptions.timeAfterCut = (handles.params.lastFrame - handles.params.firstFrame) * handles.params.frameTime;
            userOptions.quantAnalysisTime = handles.params.analysisTime;
            userOptions.basalMembraneKym = true;


            directions = {true false};
            tempOutputFldr = userOptions.outputFolder;
            for direction = directions
                
                if direction{1}
                        dr = 'upwards';
                else
                    dr = 'downwards';
                end
                
                userOptions.kymDownOrUp = direction{1};
                curr_metadata.kym_region.xcut = getNumericMetadataFromText(tcinffile, 'metadata.kym_region.xcut');
                curr_metadata.kym_region.ycut = getNumericMetadataFromText(tcinffile, 'metadata.kym_region.ycut');
                curr_metadata.kym_region.kym_startx = getNumericMetadataFromText(tcinffile, 'metadata.kym_region.kym_startx');
                curr_metadata.kym_region.kym_endx = getNumericMetadataFromText(tcinffile, 'metadata.kym_region.kym_endx');
                curr_metadata.kym_region.kym_starty = getNumericMetadataFromText(tcinffile, 'metadata.kym_region.kym_starty');
                curr_metadata.kym_region.kym_endy = getNumericMetadataFromText(tcinffile, 'metadata.kym_region.kym_endy');
                curr_metadata.kym_region.deltax = getNumericMetadataFromText(tcinffile, 'metadata.kym_region.deltax');
                curr_metadata.kym_region.deltay = getNumericMetadataFromText(tcinffile, 'metadata.kym_region.deltay');
                curr_metadata.kym_region.pos_along_cut = getNumericMetadataFromText(tcinffile, 'metadata.kym_region.pos_along_cut');

                curr_metadata.acqMetadata.cycleTime = str2num(get(handles.txtFrameTime, 'String'));

    %             beep;
                curr_metadata = manualBasalMembraneKymographPositioning(im, userOptions, curr_metadata);    

%                 xy = [curr_metadata.kym_region.xcut' curr_metadata.kym_region.ycut'];
%                 handles.cutLine.setPosition(xy);
%                 guidata(hObject, handles);
                
                % generate image data in expected format
                fcell = get(handles.txtImagePath, 'String');
                data = bfopen(fcell{1});
                omeMeta = handles.omeMeta;
                % data = data{1}(1:2:end,1);  % figure out why this line takes only every second frame: doesn't work for midline dynamics stuff...
                data = data{1}(:,1);
                newshape = [size(data{1}, 1), length(data), size(data{1}, 2)];
                data = cell2mat(data);
                data = reshape(data, newshape);
                stack = permute(data, [1 3 2]);
                clear data;

                % trim according to user selection, and forcing a single channel, single z
                % plane
                if (handles.params.CZTOrder(end) == 5) % CZT or ZTC
                    substack = stack(:,:, 1:(handles.params.channels * handles.params.zPlanes):(end - ((handles.params.channels * handles.params.zPlanes) - 1)));
                elseif  ((sum(handles.params.CZTOrder == [3 5 4]') / 3) == 1) % CTZ
                    substack = stack(:, :, 1:handles.params.channels:(handles.params.channels * handles.params.sequenceLength));
                elseif  ((sum(handles.params.CZTOrder == [4 5 3]') / 3) == 1) % ZTC
                    substack = stack(:, :, 1:handles.params.zPlanes:(handles.params.zPlanes * handles.params.sequenceLength));
                else % TCZ or TZC
                    substack = stack(:, :, 1:handles.params.sequenceLength);
                end

                stack = substack(:,:,(handles.params.firstFrame : handles.params.lastFrame));

                % pad 100 pixels on each side...
                newstack = zeros(size(stack, 1) + 200, size(stack, 2) + 200, size(stack, 3));
                newstack(100:99 + size(stack, 1), 100:99 + size(stack, 2), :) = stack;
                stack = newstack;
                clear newstack;

    %             userOptions.kymDownOrUp = ~userOptions.kymDownOrUp;

                % get (OME) metadata from data
    %             curr_metadata = getMetadataFromOME(omeMeta, handles.params);
    %             curr_metadata.acqMetadata.cycleTime = str2num(get(handles.txtFrameTime, 'String'));

    %             curr_metadata.kym_region = placeKymographs(curr_metadata, userOptions);

                userOptions.outputFolder = [userOptions.outputFolder filesep expTimeStr ' ' subfldr.name ' membrane edge ' dr];
%                 for direction2 = directions
%                     if (direction2{1})
%                         dr2 = 'upwards';
%                     else
%                         dr2 = 'downwards';
%                     end

%                     userOptions.kymDownOrUp = direction2{1};
%                     strDir = fldr.name;
%                     strDir = regexp(strDir,' ','split');
%                     strDir = strDir{end};
                    apicalDir = logical(getNumericMetadataFromText(tcinffile, 'userOptions.kymDownOrUp'))

%                     if (direction2{1} ~= apicalDir)
%                         % then flip kymograph axes ends to other side of the
%                         % cut axis
%                         dx = curr_metadata.kym_region.kym_endx - curr_metadata.kym_region.kym_startx;
% %                         dy = curr_metadata.kym_region.kym_endy - curr_metadata.kym_region.kym_starty
%                         curr_metadata.kym_region.kym_endx = curr_metadata.kym_region.kym_startx  - dx;
%                         curr_metadata.kym_region.kym_endy = curr_metadata.kym_region.kym_starty  - dy
%                     end

                    [trim_stack, curr_metadata] = kymographPreprocessing(stack, curr_metadata, userOptions);

                    %% Plot and save kymographs
                    kymographs = plotAndSaveKymographsSlow(trim_stack, curr_metadata, userOptions);

                    % Trim kymographs tifs to fit previous timebase and save kymographs with indices matching previous analysis 
                    
                    dir_txt = sprintf('%s, Embryo %s %s basal membrane, %s kymographs, trimmed basal kymograph tiffs', ...
                        curr_metadata.acquisitionDate, curr_metadata.embryoNumber, dr, subfldr.name);
                    pth_txt = [userOptions.outputFolder filesep dir_txt];
                    mkdir(pth_txt);

                    for kym_ind = -1:size(kymographs, 3)-2
                        if sum(kym_indices_to_keep == kym_ind) > 0
                            ssline = dum(indices, :);
                            ssline = ssline(cell2mat(ssline(:, strcmp(dum(1,:), 'Kymo index'))) == kym_ind, :);
                            ssline = ssline(strcmp(ssline(:, strcmp(dum(1,:), 'T long')), 'long'), :);
                            ssline = ssline(1,:);
                            t_start = ssline(strcmp(dum(1,:), 'x start'));
                            t_end = ssline(strcmp(dum(1,:), 'x end'));
                            kym_im = squeeze(kymographs(t_start{1}:t_end{1},:,kym_ind+2));
                            imwrite(uint16(kym_im'), [pth_txt filesep sprintf('%s-facing basal membrane, kymograph index %d.tif', dr, kym_ind)]);
                        end
                    end
%                 end
%             % CLOSE ALL FIGURES APART FROM CZI FIG TO TRY TO ENSURE THAT
%             % HANDLES TO CUT LINE WORK ON NEXT ITERATION
%             fhs = get(0, 'Children');
%             for fh  = fhs
%                 try
%                     close(fh)
%                 end
%             end
%             close(fhs ~= thisFigH);
            
            userOptions.outputFolder = tempOutputFldr;

            end
        end

        disp(dum);
    else
        msgbox('Please check the save directory!');
    end
end
guidata(hObject, handles);


% --- Executes on slider movement.
function scrollCPlane_Callback(hObject, eventdata, handles)
% hObject    handle to scrollCPlane (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(gcf);

handles.params.currCPlane = round(get(hObject, 'Value'));
handles.params = updateUIParams(handles.params);
disp(handles.params.currCPlane);

% handles.currentDispFrame = (handles.params.zPlanes)*(handles.params.channels)*(handles.params.currTPlane - 1) + ...
%     (handles.params.channels)*(handles.params.currZPlane - 1) + ...
%     (handles.params.channels)*(handles.params.currCPlane - 1) + 1;
handles.currentDispFrame = handles.reader.getIndex(handles.params.currZPlane - 1, ...
    handles.params.currCPlane - 1, handles.params.currTPlane - 1) + 1;
% handles.currentDispFrame = handles.params.currZPlane;
disp(handles.currentDispFrame);

im = bfGetPlane(handles.reader, handles.currentDispFrame);
padim = zeros(size(im, 1)+200, size(im, 2)+200);
padim(100:99+size(im, 1), 100:99+size(im, 2)) = im;
im = padim;
clear padim; 
handles.currentIm = im;
im(logical(squeeze(handles.currentMask(:, :,...
 handles.params.currZPlane)))) = 0;

curr_im_obj = findobj('Type', 'image', 'Parent', handles.axImage);
set(curr_im_obj, 'CData', im);

if ( get(handles.chkExclusionMask, 'Value') == 1 )

    set(curr_im_obj, 'HitTest', 'off', 'ButtonDownFcn', {@axImage_ButtonDownFcn, hObject, eventdata, handles});
    set(handles.axImage, 'ButtonDownFcn', {@axImage_ButtonDownFcn, handles});
    
end

updateUIParams(handles.params);

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function scrollCPlane_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scrollCPlane (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
