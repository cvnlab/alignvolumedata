function alignvolumedata_calcgrid(mode,interptype,wantguistatus)

% function alignvolumedata_calcgrid(mode,interptype,wantguistatus)
%
% <mode> is 0 means calc ref grid
%           1 means calc tgt grid
% <interptype> is a string
% <wantguistatus> is whether to show status indicator (and hence drawnow)
%
% if necessary (depending on <interptype>),
% populate the ref/tgt global grid vars
% (and while doing so, change the GUI status).

global AV_GUI;
global AV_REFSIZE AV_TGTSIZE;

% define
handles = guidata(AV_GUI);

% do it
switch interptype
case {'linear' 'cubic'}
  switch mode
  case 0
%     if isempty(AV_REFVOL_X1)
%       if wantguistatus
%         oldstatus = get(handles.status,'String');
%         set(handles.status,'String','status: preparing...'); drawnow;
%       end
%       [AV_REFVOL_X1,AV_REFVOL_X2,AV_REFVOL_X3] = ndgrid(1:AV_REFSIZE(1),1:AV_REFSIZE(2),1:AV_REFSIZE(3));
%       if wantguistatus
%         set(handles.status,'String',oldstatus); drawnow;
%       end
%     end
  case 1
%     if isempty(AV_TGTVOL_X1)
%       if wantguistatus
%         oldstatus = get(handles.status,'String');
%         set(handles.status,'String','status: preparing...'); drawnow;
%       end
%       [AV_TGTVOL_X1,AV_TGTVOL_X2,AV_TGTVOL_X3] = ndgrid(1:AV_TGTSIZE(1),1:AV_TGTSIZE(2),1:AV_TGTSIZE(3));
%       if wantguistatus
%         set(handles.status,'String',oldstatus); drawnow;
%       end
%     end
  end
end
