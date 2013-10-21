function [vobj,dar] = alignvolumedata_drawvolume(vobj,type,interptype,dim,slice,sliceavg,tr,rotations,overlaymode,overlaymain)

% function [vobj,dar] = alignvolumedata_drawvolume(vobj,type,interptype,dim,slice,sliceavg,tr,rotations,overlaymode,overlaymain)
%
% <vobj> is an existing image handle to mangle.
%   if [], then we make a new image.
% <type> is 1 (ref), 2 (target), 3 (overlay)
%   can also be 0 which is a special case to draw an empty image, and
%   in that case, the remaining inputs do not need to be specified.
% <interptype> is a string
% <dim> is which dimension to slice through (1, 2, or 3)
% <slice> is a 3-element vector indicating which slice of the target
% <sliceavg> is a nonzero integer (see reslicevolume for meaning)
% <tr> is the output from maketransformation.m
% <rotations> is a 3-element vector of integers indicating the rotation of the image
%   (note that rotations are for display purposes only.)
% <overlaymode> is 1 (single), 2 (subtract), 3 (checker)
% <overlaymain> is 0 (ref), 1 (target)
% 
% possibly make a new image.  make the image what it needs to be.
% set the colormap of the image's associated axis to be what it should be.
% then return the image object handle and the proper dar to be applied.
%
% note that the call for <type>==3 must take place after the calls to ==1 and ==2.

global AV_GUI;

% handle input
if isempty(vobj)
  vobj = image([],'AlphaDataMapping','none', ...  % no need to set AlphaData
                  'CDataMapping','scaled', ...
                  'Clipping','on');
end

% get out
if type==0
  return;
end

ax = get(vobj,'Parent');
switch type
case {1 2}
  [data,dar] = alignvolumedata_drawvolume_helper(type,interptype,dim,slice,sliceavg,tr,rotations,overlaymode,overlaymain);
case 3
  handles = guidata(AV_GUI);  % this must be called when AV_GUI exists for sure!
  ref = get(handles.volref,'CData');
  tgt = get(handles.voltgt,'CData');
  refdar = get(handles.axref,'DataAspectRatio');
  tgtdar = get(handles.axtgt,'DataAspectRatio');
  [data,dar] = alignvolumedata_drawvolume_helper(type,interptype,dim,slice,sliceavg,tr,rotations,overlaymode,overlaymain,ref,tgt,refdar,tgtdar);
  % now deal with colormap + title
  switch overlaymode
  case 1
    switch overlaymain
    case 0
      colormap(ax,handles.settings.referencecolor);
      set(handles.ttloly,'String','overlay (reference)');
    case 1
      colormap(ax,handles.settings.targetcolor);
      set(handles.ttloly,'String','overlay (target)');
    end
  case 2
    switch overlaymain
    case 0
      colormap(ax,handles.settings.overlaycolor);
      set(handles.ttloly,'String','overlay (reference-target)');
    case 1
      colormap(ax,handles.settings.overlaycolor);
      set(handles.ttloly,'String','overlay (target-reference)');
    end
  case 3
    switch overlaymain
    case 0
      colormap(ax,handles.settings.referencecolor);
      set(handles.ttloly,'String','overlay (checker with respect to reference)');
    case 1
      colormap(ax,handles.settings.targetcolor);
      set(handles.ttloly,'String','overlay (checker with respect to target)');
    end
  end
end
set(vobj,'CData',data);
set(vobj,'UserData',data);  % store a copy so we can adjust contrast
