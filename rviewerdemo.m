function varargout = rviewerdemo(varargin)
% RVIEWERDEMO MATLAB code for rviewerdemo.fig
%      RVIEWERDEMO, by itself, creates a new RVIEWERDEMO or raises the existing
%      singleton*.
%
%      H = RVIEWERDEMO returns the handle to a new RVIEWERDEMO or the handle to
%      the existing singleton*.
%
%      RVIEWERDEMO('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RVIEWERDEMO.M with the given input arguments.
%
%      RVIEWERDEMO('Property','Value',...) creates a new RVIEWERDEMO or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before rviewerdemo_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to rviewerdemo_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
%
%      NOTES ON RVIEWER DEMO
%
%      RViewer is designed such that you don't have to handle its resize or
%      delete callbacks; it registers these itself.  However, in the case
%      of a more complex GUI, you may want your own resize and delete
%      callbacks.  This GUIDE demo shows how a GUI with resize and delete
%      callbacks interoperates with RViewer.  RViewer will take a copy of
%      those function handles and place it within its own callback
%      structure.  If you don't have your own resize or delete callbacks,
%      you don't need to worry about how this happens.  In the simplest
%      case, all you need to do is hand RViewer an axes object to use and
%      it'll handle the rest.  
%
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help rviewerdemo

% Last Modified by GUIDE v2.5 22-Jun-2014 14:34:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @rviewerdemo_OpeningFcn, ...
                   'gui_OutputFcn',  @rviewerdemo_OutputFcn, ...
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



% --- Executes just before rviewerdemo is made visible.
function rviewerdemo_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to rviewerdemo (see VARARGIN)

% Choose default command line output for rviewerdemo
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes rviewerdemo wait for user response (see UIRESUME)
% uiwait(handles.figure1);



% --- Outputs from this function are returned to the command line.
function varargout = rviewerdemo_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes on button press in loadimagebutton.
function loadimagebutton_Callback(hObject, eventdata, handles)
% hObject    handle to loadimagebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
%  This shows how to create an RViewer instance within a GUIDE GUI.  Just
%  create the axes object in GUIDE like normal, and then provide the axes
%  handle to rviewer on creation.  
global RVIEWERSTORED
[filename, pathname] = uigetfile({'*.jpg;*.png', 'JPEG or PNG files'; '*.*', 'All files'}, 'Select image file to open.');
inimage = imread(fullfile(pathname, filename));

% This is the call to create the rviewer instance.  Notice the axes is
% handed in as a second parameter.  Really, this is all you do.  Easy!
RVIEWERSTORED = rviewer(inimage, handles.imageaxes);

% The zoomonclick property is set by the checkbox value here.
RVIEWERSTORED.zoomonclick = get(handles.zoomrecenter, 'Value');


% --- Executes when figure1 is resized.
function figure1_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
%  This is a demo callback for a GUIDE resize.  If you had other resize
%  functionality, it can still go here just like normal.  

disp('GUIDE Resize callback called.');



% --- Executes on button press in dispcallbacks.
function dispcallbacks_Callback(hObject, eventdata, handles)
% hObject    handle to dispcallbacks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
%
%  This will show the current callbacks registered with the figure.  When
%  RViewer is active, these are both changed to the static methods within
%  RViewer.  The previous callbacks are called by these new callbacks, so
%  they still get called, but RViewer also has callbacks that are called. 
if ~isempty(get(handles.figure1, 'ResizeFcn'))
   func2str(get(handles.figure1, 'ResizeFcn'))
end

if ~isempty(get(handles.figure1, 'DeleteFcn'))
   func2str(get(handles.figure1, 'DeleteFcn'))
end



% --- Executes on button press in clearrviewer.
function clearrviewer_Callback(hObject, eventdata, handles)
% hObject    handle to clearrviewer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
%  This unloads the RViewer object, and resets the callbacks to their
%  previous value.
global RVIEWERSTORED
delete(RVIEWERSTORED);



% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
%  A demo deletefcn from GUIDE.
disp('GUIDE Delete callback called.');


% --- Executes on button press in zoomrecenter.
function zoomrecenter_Callback(hObject, eventdata, handles)
% hObject    handle to zoomrecenter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of zoomrecenter
global RVIEWERSTORED

try
   RVIEWERSTORED.zoomonclick = get(hObject, 'Value');
catch
end
