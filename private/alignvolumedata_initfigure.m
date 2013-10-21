function [vol,ttl] = alignvolumedata_initfigure(type)

% function [vol,ttl] = alignvolumedata_initfigure(type)
%
% <type> is 1 (ref), 2 (target), 3 (overlay)
%
% on the current figure, do the essential initializations,
% returning handles to the volume object (which is just an image)
% and the title text object.

global AV_REFRANGE AV_TGTRANGE;

settings = alignvolumedata_transformpreferences(alignvolumedata_loadsettings({},0));  % the reason for this is that the GUI may not be init yet

hold on;

% aux stuff (this is important to do early)
switch type
case 1
  set(gca,'CLim',AV_REFRANGE);
case 2
  set(gca,'CLim',AV_TGTRANGE);
case 3
  % set in _gui
end
set(gca,'CLimMode','manual');
set(gca,'ALim',[0 1],'ALimMode','manual');  % not really necessary since we use alphadatamapping=='none'

% draw dummy volume
vol = alignvolumedata_drawvolume([],0);

% aux stuff
view(2);
set(gca,'XTick',[]);
set(gca,'YTick',[]);
set(gca,'ZTick',[]);
set(gca,'Color','none');
set(gca,'XColor',get(gcf,'Color'));
set(gca,'YColor',get(gcf,'Color'));
set(gca,'ZColor',get(gcf,'Color'));
%set(gca,'CameraPositionMode','manual');
%set(gca,'CameraTargetMode','manual');
%set(gca,'CameraUpVectorMode','manual');
%set(gca,'CameraViewAngleMode','manual');
%set(gca,'PlotBoxAspectRatioMode','manual');
%set(gca,'XLimMode','manual');
%set(gca,'YLimMode','manual');
%set(gca,'ZLimMode','manual');
%set(gca,'DataAspectRatio',[1 1 1]);  % the dar is set on each image redraw

% more
%colorbar;
switch type
case 1
  ttl = title('reference');  % title doesn't accept an explicit axes, dumb.  so we have to save it.
  colormap(settings.referencecolor);
case 2
  ttl = title('target');
  colormap(settings.targetcolor);
case 3
  ttl = title('');
  % the overlay title is set for real in _drawvolume
  % the overlay colormap is set in _drawvolume
end

hold off;
