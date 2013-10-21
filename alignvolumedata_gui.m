function varargout = alignvolumedata_gui(varargin)

% function varargout = alignvolumedata_gui(varargin)
%
% this function is for internal use only.

% INTERNAL USE:
% varargin:
%   figref: handle of a figure window
%   figtgt: handle of a figure window
%   figoly: handle of a figure window
%   volref: handle to image object
%   voltgt: handle to image object
%   vololy: handle to image object
%   ttlref: handle to title text object
%   ttltgt: handle to title text object
%   ttloly: handle to title text object
%       tr: a transformation struct (but can be [])
%
% ALIGNVOLUMEDATA_GUI M-file for alignvolumedata_gui.fig
%      ALIGNVOLUMEDATA_GUI, by itself, creates a new ALIGNVOLUMEDATA_GUI or raises the existing
%      singleton*.
%
%      H = ALIGNVOLUMEDATA_GUI returns the handle to a new ALIGNVOLUMEDATA_GUI or the handle to
%      the existing singleton*.
%
%      ALIGNVOLUMEDATA_GUI('Property','Value',...) creates a new ALIGNVOLUMEDATA_GUI using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to alignvolumedata_gui_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      ALIGNVOLUMEDATA_GUI('CALLBACK') and ALIGNVOLUMEDATA_GUI('CALLBACK',hObject,...) call the
%      local function named CALLBACK in ALIGNVOLUMEDATA_GUI.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help alignvolumedata_gui

% Last Modified by GUIDE v2.5 19-Jan-2006 12:31:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @alignvolumedata_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @alignvolumedata_gui_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
                   'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Outputs from this function are returned to the command line.
function varargout = alignvolumedata_gui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% INITIALIZATION

% --- Executes just before alignvolumedata_gui is made visible.
function alignvolumedata_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for alignvolumedata_gui
handles.output = hObject;

global AV_REFSIZE AV_REFLENGTHS AV_TGTSIZE AV_TGTLENGTHS AV_REFRANGE AV_TGTRANGE;

% handle input
handles.figref = varargin{1};  % saving this is redundant, but oh well
handles.figtgt = varargin{2};  % saving this is redundant, but oh well
handles.figoly = varargin{3};  % saving this is redundant, but oh well
handles.volref = varargin{4};
handles.voltgt = varargin{5};
handles.vololy = varargin{6};
handles.ttlref = varargin{7};
handles.ttltgt = varargin{8};
handles.ttloly = varargin{9};
handles.initialtr = varargin{10};
handles.axref = get(handles.figref,'CurrentAxes');
handles.axtgt = get(handles.figtgt,'CurrentAxes');
handles.axoly = get(handles.figoly,'CurrentAxes');

% do some figure related stuff (need to do in this file because handlekey is local)
set(hObject,'KeyPressFcn',@handlekey);
set(handles.figref,'KeyPressFcn',@handlekey);
set(handles.figtgt,'KeyPressFcn',@handlekey);
set(handles.figoly,'KeyPressFcn',@handlekey);

% do some calcs
if isfield(handles.initialtr,'extra')  % DEPRECATED
  handles.guitr = handles.initialtr.extra;  % this is the tr that is relevant to the gui
else
  handles.guitr = handles.initialtr;
end

% OLD
% % internal constants/calculations
% [handles.settingsfile] = alignvolumedata_constants('settingsfile');

% load settings, transforming the preference settings into internal format
handles.settings = alignvolumedata_transformpreferences(alignvolumedata_loadsettings({},0));

% records
if isempty(handles.guitr)
  handles.txval = (1+AV_REFSIZE(1)*AV_REFLENGTHS(1))/2;
  handles.tyval = (1+AV_REFSIZE(2)*AV_REFLENGTHS(2))/2;
  handles.tzval = (1+AV_REFSIZE(3)*AV_REFLENGTHS(3))/2;
  handles.rxval = 0;
  handles.ryval = 0;
  handles.rzval = 0;
  handles.esxval = 1;
  handles.esyval = 1;
  handles.eszval = 1;
  handles.etxval = 0;
  handles.etyval = 0;
  handles.etzval = 0;
  handles.ehxval = 0;
  handles.ehyval = 0;
  handles.ehzval = 0;
else
  [handles.txval,handles.tyval,handles.tzval] = separate(handles.guitr.trans);
  [handles.rxval,handles.ryval,handles.rzval] = separate(handles.guitr.rot);
  [handles.esxval,handles.esyval,handles.eszval] = separate(handles.guitr.extrascale);
  [handles.etxval,handles.etyval,handles.etzval] = separate(handles.guitr.extratrans);
  [handles.ehxval,handles.ehyval,handles.ehzval] = separate(handles.guitr.extrashear);
end
handles.stepval = 1;
handles.stepval2 = .01;
handles.sliceval = round(AV_TGTSIZE/2);
handles.slicestepval = [1 1 1];
handles.rotationsval = [0 0 0];

% init gui stuff
  % well, do those that depend on guitr first
if ~isempty(handles.guitr)
  set(handles.flipx,'Value',handles.guitr.flip(1));
  set(handles.flipy,'Value',handles.guitr.flip(2));
  set(handles.flipz,'Value',handles.guitr.flip(3));
  set(handles.reorder,'Value',permutation2idx(handles.guitr.reorder,3));
  set(handles.rorder,'Value',permutation2idx(handles.guitr.rotorder,3));
  set(handles.ehxf,'Value',handles.guitr.extrashearflag(1));
  set(handles.ehyf,'Value',handles.guitr.extrashearflag(2));
  set(handles.ehzf,'Value',handles.guitr.extrashearflag(3));
end
set(handles.tx,'String',num2str(handles.txval));
set(handles.ty,'String',num2str(handles.tyval));
set(handles.tz,'String',num2str(handles.tzval));
set(handles.rx,'String',num2str(handles.rxval));
set(handles.ry,'String',num2str(handles.ryval));
set(handles.rz,'String',num2str(handles.rzval));
set(handles.esx,'String',num2str(handles.esxval));
set(handles.esy,'String',num2str(handles.esyval));
set(handles.esz,'String',num2str(handles.eszval));
set(handles.etx,'String',num2str(handles.etxval));
set(handles.ety,'String',num2str(handles.etyval));
set(handles.etz,'String',num2str(handles.etzval));
set(handles.ehx,'String',num2str(handles.ehxval));
set(handles.ehy,'String',num2str(handles.ehyval));
set(handles.ehz,'String',num2str(handles.ehzval));
set(handles.slicedim,'Value',3);
sliceset_Callback([],[],handles);
set(handles.step,'String',num2str(handles.stepval));
set(handles.step2,'String',num2str(handles.stepval2));

% more inits
handles.sliceaverageval = 1;

% even more inits
set([handles.refcontrastmin handles.refcontrastmax],'Min',AV_REFRANGE(1));
set([handles.refcontrastmin handles.refcontrastmax],'Max',AV_REFRANGE(2));
set([handles.targetcontrastmin handles.targetcontrastmax],'Min',AV_TGTRANGE(1));
set([handles.targetcontrastmin handles.targetcontrastmax],'Max',AV_TGTRANGE(2));
[handles.refcontrastminval,handles.refcontrastmaxval] = separate(AV_REFRANGE);
[handles.targetcontrastminval,handles.targetcontrastmaxval] = separate(AV_TGTRANGE);
set(handles.refcontrastmin,'Value',handles.refcontrastminval);
set(handles.refcontrastmax,'Value',handles.refcontrastmaxval);
set(handles.targetcontrastmin,'Value',handles.targetcontrastminval);
set(handles.targetcontrastmax,'Value',handles.targetcontrastmaxval);

% initialize status string
set(handles.status,'String','status: ready');

% save
guidata(handles.output, handles);

% UIWAIT makes alignvolumedata_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);

%%%%%%%%%%%%%%%%%%%%%%%%%%% ALIGNMENT

function flipx_Callback(hObject, eventdata, handles)
redraw_Callback(handles.redraw, eventdata, handles,1);

function flipy_Callback(hObject, eventdata, handles)
redraw_Callback(handles.redraw, eventdata, handles,1);

function flipz_Callback(hObject, eventdata, handles)
redraw_Callback(handles.redraw, eventdata, handles,1);

function reorder_Callback(hObject, eventdata, handles)
redraw_Callback(handles.redraw, eventdata, handles,1);

function tx_Callback(hObject, eventdata, handles)
val = str2double(get(hObject,'String'));
if isnan(val)
  set(hObject,'String',num2str(handles.txval));
else
  handles.txval = val;
  redraw_Callback(handles.redraw, eventdata, handles,1);
end

function ty_Callback(hObject, eventdata, handles)
val = str2double(get(hObject,'String'));
if isnan(val)
  set(hObject,'String',num2str(handles.tyval));
else
  handles.tyval = val;
  redraw_Callback(handles.redraw, eventdata, handles,1);
end

function tz_Callback(hObject, eventdata, handles)
val = str2double(get(hObject,'String'));
if isnan(val)
  set(hObject,'String',num2str(handles.tzval));
else
  handles.tzval = val;
  redraw_Callback(handles.redraw, eventdata, handles,1);
end

function rorder_Callback(hObject, eventdata, handles)
redraw_Callback(handles.redraw, eventdata, handles,1);

function rx_Callback(hObject, eventdata, handles)
val = str2double(get(hObject,'String'));
if isnan(val)
  set(hObject,'String',num2str(handles.rxval));
else
  handles.rxval = mod4(val,360);
  set(hObject,'String',num2str(handles.rxval));
  redraw_Callback(handles.redraw, eventdata, handles,1);
end

function ry_Callback(hObject, eventdata, handles)
val = str2double(get(hObject,'String'));
if isnan(val)
  set(hObject,'String',num2str(handles.ryval));
else
  handles.ryval = mod4(val,360);
  set(hObject,'String',num2str(handles.ryval));
  redraw_Callback(handles.redraw, eventdata, handles,1);
end

function rz_Callback(hObject, eventdata, handles)
val = str2double(get(hObject,'String'));
if isnan(val)
  set(hObject,'String',num2str(handles.rzval));
else
  handles.rzval = mod4(val,360);
  set(hObject,'String',num2str(handles.rzval));
  redraw_Callback(handles.redraw, eventdata, handles,1);
end

function esx_Callback(hObject, eventdata, handles)
val = str2double(get(hObject,'String'));
if isnan(val) || val == 0
  set(hObject,'String',num2str(handles.esxval));
else
  handles.esxval = val;
  redraw_Callback(handles.redraw, eventdata, handles,1);
end

function esy_Callback(hObject, eventdata, handles)
val = str2double(get(hObject,'String'));
if isnan(val) || val == 0
  set(hObject,'String',num2str(handles.esyval));
else
  handles.esyval = val;
  redraw_Callback(handles.redraw, eventdata, handles,1);
end

function esz_Callback(hObject, eventdata, handles)
val = str2double(get(hObject,'String'));
if isnan(val) || val == 0
  set(hObject,'String',num2str(handles.eszval));
else
  handles.eszval = val;
  redraw_Callback(handles.redraw, eventdata, handles,1);
end

function ehx_Callback(hObject, eventdata, handles)
val = str2double(get(hObject,'String'));
if isnan(val)
  set(hObject,'String',num2str(handles.ehxval));
else
  handles.ehxval = val;
  redraw_Callback(handles.redraw, eventdata, handles,1);
end

function ehy_Callback(hObject, eventdata, handles)
val = str2double(get(hObject,'String'));
if isnan(val)
  set(hObject,'String',num2str(handles.ehyval));
else
  handles.ehyval = val;
  redraw_Callback(handles.redraw, eventdata, handles,1);
end

function ehz_Callback(hObject, eventdata, handles)
val = str2double(get(hObject,'String'));
if isnan(val)
  set(hObject,'String',num2str(handles.ehzval));
else
  handles.ehzval = val;
  redraw_Callback(handles.redraw, eventdata, handles,1);
end

function ehxf_Callback(hObject, eventdata, handles)
redraw_Callback(handles.redraw, eventdata, handles,1);

function ehyf_Callback(hObject, eventdata, handles)
redraw_Callback(handles.redraw, eventdata, handles,1);

function ehzf_Callback(hObject, eventdata, handles)
redraw_Callback(handles.redraw, eventdata, handles,1);

function etx_Callback(hObject, eventdata, handles)
val = str2double(get(hObject,'String'));
if isnan(val)
  set(hObject,'String',num2str(handles.etxval));
else
  handles.etxval = val;
  redraw_Callback(handles.redraw, eventdata, handles,1);
end

function ety_Callback(hObject, eventdata, handles)
val = str2double(get(hObject,'String'));
if isnan(val)
  set(hObject,'String',num2str(handles.etyval));
else
  handles.etyval = val;
  redraw_Callback(handles.redraw, eventdata, handles,1);
end

function etz_Callback(hObject, eventdata, handles)
val = str2double(get(hObject,'String'));
if isnan(val)
  set(hObject,'String',num2str(handles.etzval));
else
  handles.etzval = val;
  redraw_Callback(handles.redraw, eventdata, handles,1);
end

function txdown_Callback(hObject, eventdata, handles)
handles.txval = handles.txval - handles.stepval;
set(handles.tx,'String',num2str(handles.txval));
redraw_Callback(handles.redraw, eventdata, handles,1);

function txup_Callback(hObject, eventdata, handles)
handles.txval = handles.txval + handles.stepval;
set(handles.tx,'String',num2str(handles.txval));
redraw_Callback(handles.redraw, eventdata, handles,1);

function tydown_Callback(hObject, eventdata, handles)
handles.tyval = handles.tyval - handles.stepval;
set(handles.ty,'String',num2str(handles.tyval));
redraw_Callback(handles.redraw, eventdata, handles,1);

function tyup_Callback(hObject, eventdata, handles)
handles.tyval = handles.tyval + handles.stepval;
set(handles.ty,'String',num2str(handles.tyval));
redraw_Callback(handles.redraw, eventdata, handles,1);

function tzdown_Callback(hObject, eventdata, handles)
handles.tzval = handles.tzval - handles.stepval;
set(handles.tz,'String',num2str(handles.tzval));
redraw_Callback(handles.redraw, eventdata, handles,1);

function tzup_Callback(hObject, eventdata, handles)
handles.tzval = handles.tzval + handles.stepval;
set(handles.tz,'String',num2str(handles.tzval));
redraw_Callback(handles.redraw, eventdata, handles,1);

function rxdown_Callback(hObject, eventdata, handles)
handles.rxval = mod4(handles.rxval - handles.stepval,360);
set(handles.rx,'String',num2str(handles.rxval));
redraw_Callback(handles.redraw, eventdata, handles,1);

function rxup_Callback(hObject, eventdata, handles)
handles.rxval = mod4(handles.rxval + handles.stepval,360);
set(handles.rx,'String',num2str(handles.rxval));
redraw_Callback(handles.redraw, eventdata, handles,1);

function rydown_Callback(hObject, eventdata, handles)
handles.ryval = mod4(handles.ryval - handles.stepval,360);
set(handles.ry,'String',num2str(handles.ryval));
redraw_Callback(handles.redraw, eventdata, handles,1);

function ryup_Callback(hObject, eventdata, handles)
handles.ryval = mod4(handles.ryval + handles.stepval,360);
set(handles.ry,'String',num2str(handles.ryval));
redraw_Callback(handles.redraw, eventdata, handles,1);

function rzdown_Callback(hObject, eventdata, handles)
handles.rzval = mod4(handles.rzval - handles.stepval,360);
set(handles.rz,'String',num2str(handles.rzval));
redraw_Callback(handles.redraw, eventdata, handles,1);

function rzup_Callback(hObject, eventdata, handles)
handles.rzval = mod4(handles.rzval + handles.stepval,360);
set(handles.rz,'String',num2str(handles.rzval));
redraw_Callback(handles.redraw, eventdata, handles,1);

function esxdown_Callback(hObject, eventdata, handles)
handles.esxval = choose(handles.esxval - handles.stepval2 == 0,-handles.stepval2,handles.esxval - handles.stepval2);    %,.01);
set(handles.esx,'String',num2str(handles.esxval));
redraw_Callback(handles.redraw, eventdata, handles,1);

function esxup_Callback(hObject, eventdata, handles)
handles.esxval = choose(handles.esxval + handles.stepval2 == 0,handles.stepval2,handles.esxval + handles.stepval2);
set(handles.esx,'String',num2str(handles.esxval));
redraw_Callback(handles.redraw, eventdata, handles,1);

function esydown_Callback(hObject, eventdata, handles)
handles.esyval = choose(handles.esyval - handles.stepval2 == 0,-handles.stepval2,handles.esyval - handles.stepval2);  %,.01);
set(handles.esy,'String',num2str(handles.esyval));
redraw_Callback(handles.redraw, eventdata, handles,1);

function esyup_Callback(hObject, eventdata, handles)
handles.esyval = choose(handles.esyval + handles.stepval2 == 0,handles.stepval2,handles.esyval + handles.stepval2);
set(handles.esy,'String',num2str(handles.esyval));
redraw_Callback(handles.redraw, eventdata, handles,1);

function eszdown_Callback(hObject, eventdata, handles)
handles.eszval = choose(handles.eszval - handles.stepval2 == 0,-handles.stepval2,handles.eszval - handles.stepval2);  %,.01);
set(handles.esz,'String',num2str(handles.eszval));
redraw_Callback(handles.redraw, eventdata, handles,1);

function eszup_Callback(hObject, eventdata, handles)
handles.eszval = choose(handles.eszval + handles.stepval2 == 0,handles.stepval2,handles.eszval + handles.stepval2);
set(handles.esz,'String',num2str(handles.eszval));
redraw_Callback(handles.redraw, eventdata, handles,1);

function ehxdown_Callback(hObject, eventdata, handles)
handles.ehxval = handles.ehxval - handles.stepval2;
set(handles.ehx,'String',num2str(handles.ehxval));
redraw_Callback(handles.redraw, eventdata, handles,1);

function ehxup_Callback(hObject, eventdata, handles)
handles.ehxval = handles.ehxval + handles.stepval2;
set(handles.ehx,'String',num2str(handles.ehxval));
redraw_Callback(handles.redraw, eventdata, handles,1);

function ehydown_Callback(hObject, eventdata, handles)
handles.ehyval = handles.ehyval - handles.stepval2;
set(handles.ehy,'String',num2str(handles.ehyval));
redraw_Callback(handles.redraw, eventdata, handles,1);

function ehyup_Callback(hObject, eventdata, handles)
handles.ehyval = handles.ehyval + handles.stepval2;
set(handles.ehy,'String',num2str(handles.ehyval));
redraw_Callback(handles.redraw, eventdata, handles,1);

function ehzdown_Callback(hObject, eventdata, handles)
handles.ehzval = handles.ehzval - handles.stepval2;
set(handles.ehz,'String',num2str(handles.ehzval));
redraw_Callback(handles.redraw, eventdata, handles,1);

function ehzup_Callback(hObject, eventdata, handles)
handles.ehzval = handles.ehzval + handles.stepval2;
set(handles.ehz,'String',num2str(handles.ehzval));
redraw_Callback(handles.redraw, eventdata, handles,1);

function etxdown_Callback(hObject, eventdata, handles)
handles.etxval = handles.etxval - handles.stepval;
set(handles.etx,'String',num2str(handles.etxval));
redraw_Callback(handles.redraw, eventdata, handles,1);

function etxup_Callback(hObject, eventdata, handles)
handles.etxval = handles.etxval + handles.stepval;
set(handles.etx,'String',num2str(handles.etxval));
redraw_Callback(handles.redraw, eventdata, handles,1);

function etydown_Callback(hObject, eventdata, handles)
handles.etyval = handles.etyval - handles.stepval;
set(handles.ety,'String',num2str(handles.etyval));
redraw_Callback(handles.redraw, eventdata, handles,1);

function etyup_Callback(hObject, eventdata, handles)
handles.etyval = handles.etyval + handles.stepval;
set(handles.ety,'String',num2str(handles.etyval));
redraw_Callback(handles.redraw, eventdata, handles,1);

function etzdown_Callback(hObject, eventdata, handles)
handles.etzval = handles.etzval - handles.stepval;
set(handles.etz,'String',num2str(handles.etzval));
redraw_Callback(handles.redraw, eventdata, handles,1);

function etzup_Callback(hObject, eventdata, handles)
handles.etzval = handles.etzval + handles.stepval;
set(handles.etz,'String',num2str(handles.etzval));
redraw_Callback(handles.redraw, eventdata, handles,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%% DISPLAY

function sliceset_Callback(hObject, eventdata, handles)

% this is a fake callback.
% we get the GUI ready to go.
%
% we don't save handles, no need.

global AV_TGTSIZE;

sd = get(handles.slicedim,'Value');
set(handles.slice,'String',num2str(handles.sliceval(sd)));
mx = AV_TGTSIZE(sd);
if mx==1
  set(handles.slicebar,'Enable','off');
else
  set(handles.slicebar,'Enable','on');
  set(handles.slicebar,'Min',1);
  set(handles.slicebar,'Max',mx);
  set(handles.slicebar,'SliderStep',[1 handles.slicestepval(sd)]/(mx-1));
end
set(handles.slicebar,'Value',handles.sliceval(sd));
set(handles.slicestep,'String',num2str(handles.slicestepval(sd)));

%%%%

function slicedim_Callback(hObject, eventdata, handles)
sliceset_Callback([],[],handles);
redraw_Callback(handles.redraw, eventdata, handles);

function slice_Callback(hObject, eventdata, handles)
global AV_TGTSIZE;
sd = get(handles.slicedim,'Value');
val = str2double(get(hObject,'String'));
if isnan(val) || ~all(isint(val)) || val < 1 || val > AV_TGTSIZE(sd)
  set(hObject,'String',num2str(handles.sliceval(sd)));
else
  handles.sliceval(sd) = val;
  set(handles.slicebar,'Value',handles.sliceval(sd));
  redraw_Callback(handles.redraw, eventdata, handles);
end

function slicebar_Callback(hObject, eventdata, handles)
sd = get(handles.slicedim,'Value');
handles.sliceval(sd) = round(get(hObject,'Value'));  % not sure if rounding is necessary
set(handles.slice,'String',num2str(handles.sliceval(sd)));
redraw_Callback(handles.redraw,eventdata,handles);

function slicestep_Callback(hObject, eventdata, handles)
sd = get(handles.slicedim,'Value');
val = str2double(get(hObject,'String'));
if isnan(val) || ~all(isint(val)) || val<=0
  set(handles.slicestep,'String',num2str(handles.slicestepval(sd)));
else
  handles.slicestepval(sd) = val;
  sliceset_Callback([],[],handles);
  guidata(handles.output, handles);
end

function sliceaverage_Callback(hObject, eventdata, handles)
val = str2double(get(hObject,'String'));
if isnan(val) || ~all(isint(val)) || val==0
  set(handles.sliceaverage,'String',num2str(handles.sliceaverageval));
else
  handles.sliceaverageval = val;
  redraw_Callback(handles.redraw, eventdata, handles);
end

function rotateccw_Callback(hObject, eventdata, handles)
sd = get(handles.slicedim,'Value');
handles.rotationsval(sd) = mod(handles.rotationsval(sd) + 1,4);
redraw_Callback(handles.redraw, eventdata, handles);

function rotatecw_Callback(hObject, eventdata, handles)
sd = get(handles.slicedim,'Value');
handles.rotationsval(sd) = mod(handles.rotationsval(sd) - 1,4);
redraw_Callback(handles.redraw, eventdata, handles);

function interp_Callback(hObject, eventdata, handles)
redraw_Callback(handles.redraw, eventdata, handles,1);

function overlaymode_Callback(hObject, eventdata, handles)
redraw_Callback(handles.redraw, eventdata, handles,0,1);

function overlaymain_Callback(hObject, eventdata, handles)
switch get(hObject,'String')
case 'ref'
  set(hObject,'String','target');
case 'target'
  set(hObject,'String','ref');
end
redraw_Callback(handles.redraw, eventdata, handles,0,1);

function step_Callback(hObject, eventdata, handles)
val = str2double(get(hObject,'String'));
if isnan(val) || val <= 0
  set(hObject,'String',num2str(handles.stepval));
else
  handles.stepval = val;
  guidata(handles.output, handles);
end

function step2_Callback(hObject, eventdata, handles)
val = str2double(get(hObject,'String'));
if isnan(val) || val <= 0
  set(hObject,'String',num2str(handles.stepval2));
else
  handles.stepval2 = val;
  guidata(handles.output, handles);
end

function refcontrastmin_Callback(hObject, eventdata, handles)
val = get(hObject,'Value');
if val > get(handles.refcontrastmax,'Value')
  set(hObject,'Value',handles.refcontrastminval);
else
  handles.refcontrastminval = val;
end
redraw_Callback(handles.redraw, eventdata, handles,0,1);

function refcontrastmax_Callback(hObject, eventdata, handles)
val = get(hObject,'Value');
if val < get(handles.refcontrastmin,'Value')
  set(hObject,'Value',handles.refcontrastmaxval);
else
  handles.refcontrastmaxval = val;
end
redraw_Callback(handles.redraw, eventdata, handles,0,1);

function targetcontrastmin_Callback(hObject, eventdata, handles)
val = get(hObject,'Value');
if val > get(handles.targetcontrastmax,'Value')
  set(hObject,'Value',handles.targetcontrastminval);
else
  handles.targetcontrastminval = val;
end
redraw_Callback(handles.redraw, eventdata, handles,0,1);

function targetcontrastmax_Callback(hObject, eventdata, handles)
val = get(hObject,'Value');
if val < get(handles.targetcontrastmin,'Value')
  set(hObject,'Value',handles.targetcontrastmaxval);
else
  handles.targetcontrastmaxval = val;
end
redraw_Callback(handles.redraw, eventdata, handles,0,1);

function redraw_Callback(hObject, eventdata, handles,autoswitch,nochange)

% <autoswitch> (optional) is whether to force the overlay window to show the reference image.
%   defaults to 0.
% <nochange> (optional) is whether to avoid a call to drawvolume.  defaults to 0.
%
% note that we save handles.

global AV_REFRANGE AV_TGTRANGE;

% deal with input
if ~exist('autoswitch','var')
  autoswitch = 0;
end
if ~exist('nochange','var')
  nochange = 0;
end

% deal with status
set(handles.status,'String','status: redrawing...'); drawnow;

% this is very important.
% we may get passed handles data that has not been saved yet.
% if any portion of this routine relies on the global AV_GUI
% to get handles, that data would be obsolete if we didn't save
% handles here.  so let's do it just for peace of mind.
guidata(handles.output, handles);

% deal with autoswitch
if autoswitch && get(handles.overlaymode,'Value')==1 && isequal(get(handles.overlaymain,'String'),'target')
  set(handles.overlaymain,'String','ref');
end

% do it
it = subscript(get(handles.interp,'String'),get(handles.interp,'Value'),1);
sd = get(handles.slicedim,'Value');
tr = alignvolumedata_exporttransformation(0);
omodeval = get(handles.overlaymode,'Value');
omainval = isequal(get(handles.overlaymain,'String'),'target');
% this step could be skipped to avoid reslicing
if ~nochange
  [dummy,dar1] = alignvolumedata_drawvolume(handles.volref,1,it,sd,handles.sliceval,handles.sliceaverageval, ...
    tr,handles.rotationsval,omodeval,omainval);
  [dummy,dar2] = alignvolumedata_drawvolume(handles.voltgt,2,it,sd,handles.sliceval,handles.sliceaverageval, ...
    tr,handles.rotationsval,omodeval,omainval);
  axis(handles.axref,'image','ij');
  axis(handles.axtgt,'image','ij');
  set(handles.axref,'DataAspectRatio',dar1);
  set(handles.axtgt,'DataAspectRatio',dar2);
end
% in all cases, we adjust contrast
set(handles.volref,'CData',normalizerange(get(handles.volref,'UserData'), ...
  double(AV_REFRANGE(1)),double(AV_REFRANGE(2)),handles.refcontrastminval,handles.refcontrastmaxval));
set(handles.voltgt,'CData',normalizerange(get(handles.voltgt,'UserData'), ...
  double(AV_TGTRANGE(1)),double(AV_TGTRANGE(2)),handles.targetcontrastminval,handles.targetcontrastmaxval));
% note that it was important that we adjusted contrast before calling case 3 here.
[dummy,dar3] = alignvolumedata_drawvolume(handles.vololy,3,it,sd,handles.sliceval,handles.sliceaverageval,tr,handles.rotationsval,omodeval,omainval);
axis(handles.axoly,'image','ij');
set(handles.axoly,'DataAspectRatio',dar3);
switch omodeval
case {1 3}
  switch omainval
  case 0
    set(handles.axoly,'CLim',AV_REFRANGE);  % the range for the overlay can change...
  case 1
    set(handles.axoly,'CLim',AV_TGTRANGE);
  end
case 2
  set(handles.axoly,'CLim',AV_REFRANGE);
end

% render
drawnow;

% deal with status
set(handles.status,'String','status: ready'); drawnow;

% save
guidata(handles.output, handles);

function handlekey(hObject, eventdata)

global AV_GUI;

handles = guidata(AV_GUI);  % always use fresh version!
sd = get(handles.slicedim,'Value');
switch get(hObject,'CurrentCharacter')
case '1'
  set(handles.slicedim,'Value',1);
  sliceset_Callback([],[],handles);
  redraw_Callback(handles.redraw, eventdata, handles);
case '2'
  set(handles.slicedim,'Value',2);
  sliceset_Callback([],[],handles);
  redraw_Callback(handles.redraw, eventdata, handles);
case '3'
  set(handles.slicedim,'Value',3);
  sliceset_Callback([],[],handles);
  redraw_Callback(handles.redraw, eventdata, handles);
case 'q'
  txdown_Callback(handles.txdown,[],handles);
case 'w'
  txup_Callback(handles.txup,[],handles);
case 'a'
  tydown_Callback(handles.tydown,[],handles);
case 's'
  tyup_Callback(handles.tyup,[],handles);
case 'z'
  tzdown_Callback(handles.tzdown,[],handles);
case 'x'
  tzup_Callback(handles.tzup,[],handles);
case 'e'
  rxdown_Callback(handles.rxdown,[],handles);
case 'r'
  rxup_Callback(handles.rxup,[],handles);
case 'd'
  rydown_Callback(handles.rydown,[],handles);
case 'f'
  ryup_Callback(handles.ryup,[],handles);
case 'c'
  rzdown_Callback(handles.rzdown,[],handles);
case 'v'
  rzup_Callback(handles.rzup,[],handles);
case 't'
  esxdown_Callback(handles.esxdown,[],handles);
case 'y'
  esxup_Callback(handles.esxup,[],handles);
case 'g'
  esydown_Callback(handles.esydown,[],handles);
case 'h'
  esyup_Callback(handles.esyup,[],handles);
case 'b'
  eszdown_Callback(handles.eszdown,[],handles);
case 'n'
  eszup_Callback(handles.eszup,[],handles);
case 'u'
  etxdown_Callback(handles.etxdown,[],handles);
case 'i'
  etxup_Callback(handles.etxup,[],handles);
case 'j'
  etydown_Callback(handles.etydown,[],handles);
case 'k'
  etyup_Callback(handles.etyup,[],handles);
case 'm'
  etzdown_Callback(handles.etzdown,[],handles);
case ','
  etzup_Callback(handles.etzup,[],handles);
case 'o'
  ehxdown_Callback(handles.ehxdown,[],handles);
case 'p'
  ehxup_Callback(handles.ehxup,[],handles);
case 'l'
  ehydown_Callback(handles.ehydown,[],handles);
case ';'
  ehyup_Callback(handles.ehyup,[],handles);
case '.'
  ehzdown_Callback(handles.ehzdown,[],handles);
case '/'
  ehzup_Callback(handles.ehzup,[],handles);
case '['
  set(handles.slice,'String',num2str(handles.sliceval(sd)-1));  % this assumes sliderstep is like 1
  slice_Callback(handles.slice,[],handles);
case ']'
  set(handles.slice,'String',num2str(handles.sliceval(sd)+1));
  slice_Callback(handles.slice,[],handles);
case '{'
  val = subscript(get(handles.slicebar,'SliderStep'),2)*(get(handles.slicebar,'Max')-get(handles.slicebar,'Min'));
  val = max(handles.sliceval(sd)-val,1);
  set(handles.slice,'String',num2str(val));
  slice_Callback(handles.slice,[],handles);
case '}'
  val = subscript(get(handles.slicebar,'SliderStep'),2)*(get(handles.slicebar,'Max')-get(handles.slicebar,'Min'));
  val = min(handles.sliceval(sd)+val,get(handles.slicebar,'Max'));
  set(handles.slice,'String',num2str(val));
  slice_Callback(handles.slice,[],handles);
case ''''
  overlaymain_Callback(handles.overlaymain,[],handles);
%OBSOLETE
%case 'l'
%  set(hObject,'Value',0);  % special case
end

function keyboard_Callback(hObject, eventdata, handles)

% ALL OBSOLETE.  COMMENT OUT.  THIS MECHANISM IS SLOW ON MATLAB 7 FOR SOME REASON.
% SO, THE KEYBOARD BUTTON IS OBSOLETE!!!
%
% % keypressfcn isn't a good solution since it doesn't seem to
% % be triggered when some GUI control is in focus.  so it
% % seems we have to explicitly be in waitforbuttonpress mode.
% 
% global AV_GUI;
% 
% if get(hObject,'Value')
%   fprintf(1,'entered keyboard mode.\n');
%   while get(hObject,'Value')
%     bp = waitforbuttonpress;
%     switch bp
%     case 0  % mouse
%       % if something can switch us out of this mode, pause some time to
%       % allow it to finish up and take effect so we don't loop infinitely
%       if gco == handles.keyboard
%         pause(.25);
%       end
%     case 1  % keyboard
%       handles = guidata(AV_GUI);  % always use fresh version!
%       sd = get(handles.slicedim,'Value');
%       set(handles.keyboard,'Interruptible','off');  % turn off while doing the other callback
%       switch get(gcf,'CurrentCharacter')
%       case 'q'
%         txdown_Callback(handles.txdown,[],handles);
%       case 'w'
%         txup_Callback(handles.txup,[],handles);
%       case 'a'
%         tydown_Callback(handles.tydown,[],handles);
%       case 's'
%         tyup_Callback(handles.tyup,[],handles);
%       case 'z'
%         tzdown_Callback(handles.tzdown,[],handles);
%       case 'x'
%         tzup_Callback(handles.tzup,[],handles);
%       case 'e'
%         rxdown_Callback(handles.rxdown,[],handles);
%       case 'r'
%         rxup_Callback(handles.rxup,[],handles);
%       case 'd'
%         rydown_Callback(handles.rydown,[],handles);
%       case 'f'
%         ryup_Callback(handles.ryup,[],handles);
%       case 'c'
%         rzdown_Callback(handles.rzdown,[],handles);
%       case 'v'
%         rzup_Callback(handles.rzup,[],handles);
%       case 't'
%         esxdown_Callback(handles.esxdown,[],handles);
%       case 'y'
%         esxup_Callback(handles.esxup,[],handles);
%       case 'g'
%         esydown_Callback(handles.esydown,[],handles);
%       case 'h'
%         esyup_Callback(handles.esyup,[],handles);
%       case 'b'
%         eszdown_Callback(handles.eszdown,[],handles);
%       case 'n'
%         eszup_Callback(handles.eszup,[],handles);
%       case 'u'
%         etxdown_Callback(handles.etxdown,[],handles);
%       case 'i'
%         etxup_Callback(handles.etxup,[],handles);
%       case 'j'
%         etydown_Callback(handles.etydown,[],handles);
%       case 'k'
%         etyup_Callback(handles.etyup,[],handles);
%       case 'm'
%         etzdown_Callback(handles.etzdown,[],handles);
%       case ','
%         etzup_Callback(handles.etzup,[],handles);
% %      case 'o'
% %        ehxdown_Callback(handles.ehxdown,[],handles);
% %      case 'p'
% %        ehxup_Callback(handles.ehxup,[],handles);
% %      case 'l'
% %        ehydown_Callback(handles.ehydown,[],handles);
% %      case ';'
% %        ehyup_Callback(handles.ehyup,[],handles);
% %      case '.'
% %        ehzdown_Callback(handles.ehzdown,[],handles);
% %      case '/'
% %        ehzup_Callback(handles.ehzup,[],handles);
%       case '['
%         set(handles.slice,'String',num2str(handles.sliceval(sd)-1));  % this assumes sliderstep is like 1
%         slice_Callback(handles.slice,[],handles);
%       case ']'
%         set(handles.slice,'String',num2str(handles.sliceval(sd)+1));
%         slice_Callback(handles.slice,[],handles);
%       case '{'
%         val = subscript(get(handles.slicebar,'SliderStep'),2)*(get(handles.slicebar,'Max')-get(handles.slicebar,'Min'));
%         val = max(handles.sliceval(sd)-val,1);
%         set(handles.slice,'String',num2str(val));
%         slice_Callback(handles.slice,[],handles);
%       case '}'
%         val = subscript(get(handles.slicebar,'SliderStep'),2)*(get(handles.slicebar,'Max')-get(handles.slicebar,'Min'));
%         val = min(handles.sliceval(sd)+val,get(handles.slicebar,'Max'));
%         set(handles.slice,'String',num2str(val));
%         slice_Callback(handles.slice,[],handles);
%       case ''''
%         overlaymain_Callback(handles.overlaymain,[],handles);
%       case 'l'
%         set(hObject,'Value',0);  % special case
%       end
%       set(handles.keyboard,'Interruptible','on');  % restore
%     end
%   end
%   fprintf(1,'exited keyboard mode.\n');
% end

% THIS WAS ATTEMPT FOR FLASH AUTO MODE:...
%
% function keyboard_Callback(hObject, eventdata, handles)
% 
% % keypressfcn isn't a good solution since it doesn't seem to
% % be triggered when some GUI control is in focus.  so it
% % seems we have to explicitly be in waitforbuttonpress mode.
% 
% global AV_GUI;
% 
% elapsed = [];
% if get(hObject,'Value')
%   fprintf(1,'entered keyboard mode.\n');
%   
%   set(AV_GUI,'CurrentCharacter','/');
%   
%   while get(hObject,'Value')
%     fprintf('.');
% 
%     if isequal(get(AV_GUI,'CurrentCharacter'),'/')
%     fprintf('#');
%     drawnow;
%       if ~isempty(elapsed)
%         pause(max(.25 - elapsed,.01));
%       end
% 
%       check = get(AV_GUI,'CurrentCharacter');
%       fprintf('check = %s',check);
% 
%       % if something can switch us out of this mode, pause some time to
%       % allow it to finish up and take effect so we don't loop infinitely
%       if gco == handles.keyboard
%         pause(.25);
%       end
% 
%       tic;
%       handles = guidata(AV_GUI);  % always use fresh version!
%         overlaymain_Callback(handles.overlaymain,[],handles);
%       elapsed = toc;
%       
%     else
% 
% fprintf('huh');
% %     bp = waitforbuttonpress;
% %     switch bp
% %     case 0  % mouse
% %       % if something can switch us out of this mode, pause some time to
% %       % allow it to finish up and take effect so we don't loop infinitely
% %       if gco == handles.keyboard
% %         pause(.25);
% %       end
% %     case 1  % keyboard
%       handles = guidata(AV_GUI);  % always use fresh version!
%       sd = get(handles.slicedim,'Value');
%       set(handles.keyboard,'Interruptible','off');  % turn off while doing the other callback
%       switch get(AV_GUI,'CurrentCharacter')
%       case 'q'
%         txdown_Callback(handles.txdown,[],handles);
%       case 'w'
%         txup_Callback(handles.txup,[],handles);
%       case 'a'
%         tydown_Callback(handles.tydown,[],handles);
%       case 's'
%         tyup_Callback(handles.tyup,[],handles);
%       case 'z'
%         tzdown_Callback(handles.tzdown,[],handles);
%       case 'x'
%         tzup_Callback(handles.tzup,[],handles);
%       case 'e'
%         rxdown_Callback(handles.rxdown,[],handles);
%       case 'r'
%         rxup_Callback(handles.rxup,[],handles);
%       case 'd'
%         rydown_Callback(handles.rydown,[],handles);
%       case 'f'
%         ryup_Callback(handles.ryup,[],handles);
%       case 'c'
%         rzdown_Callback(handles.rzdown,[],handles);
%       case 'v'
%         rzup_Callback(handles.rzup,[],handles);
%       case 't'
%         esxdown_Callback(handles.esxdown,[],handles);
%       case 'y'
%         esxup_Callback(handles.esxup,[],handles);
%       case 'g'
%         esydown_Callback(handles.esydown,[],handles);
%       case 'h'
%         esyup_Callback(handles.esyup,[],handles);
%       case 'b'
%         eszdown_Callback(handles.eszdown,[],handles);
%       case 'n'
%         eszup_Callback(handles.eszup,[],handles);
%       case 'u'
%         etxdown_Callback(handles.etxdown,[],handles);
%       case 'i'
%         etxup_Callback(handles.etxup,[],handles);
%       case 'j'
%         etydown_Callback(handles.etydown,[],handles);
%       case 'k'
%         etyup_Callback(handles.etyup,[],handles);
%       case 'm'
%         etzdown_Callback(handles.etzdown,[],handles);
%       case ','
%         etzup_Callback(handles.etzup,[],handles);
% %      case 'o'
% %        ehxdown_Callback(handles.ehxdown,[],handles);
% %      case 'p'
% %        ehxup_Callback(handles.ehxup,[],handles);
% %      case 'l'
% %        ehydown_Callback(handles.ehydown,[],handles);
% %      case ';'
% %        ehyup_Callback(handles.ehyup,[],handles);
% %      case '.'
% %        ehzdown_Callback(handles.ehzdown,[],handles);
% %      case '/'
% %        ehzup_Callback(handles.ehzup,[],handles);
%       case '['
%         set(handles.slice,'String',num2str(handles.sliceval(sd)-1));  % this assumes sliderstep is like 1
%         slice_Callback(handles.slice,[],handles);
%       case ']'
%         set(handles.slice,'String',num2str(handles.sliceval(sd)+1));
%         slice_Callback(handles.slice,[],handles);
%       case '{'
%         val = subscript(get(handles.slicebar,'SliderStep'),2)*(get(handles.slicebar,'Max')-get(handles.slicebar,'Min'));
%         val = max(handles.sliceval(sd)-val,1);
%         set(handles.slice,'String',num2str(val));
%         slice_Callback(handles.slice,[],handles);
%       case '}'
%         val = subscript(get(handles.slicebar,'SliderStep'),2)*(get(handles.slicebar,'Max')-get(handles.slicebar,'Min'));
%         val = min(handles.sliceval(sd)+val,get(handles.slicebar,'Max'));
%         set(handles.slice,'String',num2str(val));
%         slice_Callback(handles.slice,[],handles);
%       case ''''
%         overlaymain_Callback(handles.overlaymain,[],handles);
%       case 'l'
%         set(hObject,'Value',0);  % special case
%       end
%       set(handles.keyboard,'Interruptible','on');  % restore
%       
%       set(AV_GUI,'CurrentCharacter','/');
%       
%     end
%   end
%   fprintf(1,'exited keyboard mode.\n');
% end
