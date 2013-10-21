function tr = alignvolumedata_exporttransformation(wantprint)

% function tr = alignvolumedata_exporttransformation
%
% return a transformation struct that reflects
% the current state of alignvolumedata.
%
% example:
% (see the example in alignvolumedata.m)

% internal note:
% - <wantprint> is whether to print the transformation.
%     if 2, then we omit the line that says 'the following constructs...'
% if [] or not supplied, default to 1.

global AV_GUI AV_TGTSIZE AV_TGTLENGTHS;

% deal with input
if ~exist('wantprint','var') || isempty(wantprint)
  wantprint = 1;
end

if isempty(AV_GUI)
  warning('no alignvolumedata GUI detected.');
  tr = [];
  return;
end

% define
handles = guidata(AV_GUI);  % <handles> is the current handles info

% find gui's tr
flip = [get(handles.flipx,'Value') get(handles.flipy,'Value') get(handles.flipz,'Value')];
reorder = idx2permutation(get(handles.reorder,'Value'),3);
trans = [handles.txval handles.tyval handles.tzval];
rotorder = idx2permutation(get(handles.rorder,'Value'),3);
rot = [handles.rxval handles.ryval handles.rzval];
matrixsize = AV_TGTSIZE;
matrixfov = AV_TGTSIZE.*AV_TGTLENGTHS;
extrascale = [handles.esxval handles.esyval handles.eszval];
extratrans = [handles.etxval handles.etyval handles.etzval];
extrashear = [handles.ehxval handles.ehyval handles.ehzval];
extrashearflag = [get(handles.ehxf,'Value') get(handles.ehyf,'Value') get(handles.ehzf,'Value')];
trgui = maketransformation(flip,reorder,trans,rotorder,rot,matrixsize,matrixfov,extrascale,extratrans,extrashear,extrashearflag);

% deal with extra if necessary
if isfield(handles.initialtr,'extra')  % DEPRECATED
  tr = handles.initialtr;
  tr.extra = trgui;
else
  tr = trgui;
end

% print to command window
if wantprint
  if wantprint==1
    fprintf(1,'the following constructs the current transformation:\n');
  end
  printtransformation(tr);
end
