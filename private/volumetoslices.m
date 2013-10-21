function XYZ = volumetoslices(XYZ,tr,pre)

% function XYZ = volumetoslices(XYZ,tr,pre)
%
% <XYZ> are coordinates in coordinate space
% <tr> is of the format described in maketransformation.m
% <pre> (optional) is a transformation matrix to apply
%   as the very first step.  if [] or not supplied, don't
%   do anything.
%
% based on the information in <tr>, return the
% coordinates as they would be in slice space.
% note that coordinate space is not necessarily
% reference space!

% deal with input
if ~exist('pre','var') || isempty(pre)
  pre = eye(4);
end

% deal with 'extra' case
if isfield(tr,'extra')  % DEPRECATED
  % we need a intermediary matrix that goes from slice to volume
  temp = xyztranslate([.5 .5 .5])*xyzscale(tr.matrixfov./tr.matrixsize)*xyztranslate([-.5 -.5 -.5]);
  XYZ = volumetoslices(volumetoslices(XYZ,rmfield(tr,'extra'),pre),tr.extra,temp);
  return;
end

% prepare rotation
rotmatrix = 1;
for p=fliplr(tr.rotorder)
  switch p
  case 1
    rotmatrix = xyzrotate_x(-tr.rot(1))*rotmatrix;
  case 2
    rotmatrix = xyzrotate_y(-tr.rot(2))*rotmatrix;
  case 3
    rotmatrix = xyzrotate_z(-tr.rot(3))*rotmatrix;
  end
end

% transform
% 0. start in coordinate space
% 1. apply pre-operation
% 2. translate so that we are centered around (perceived) slice volume center
% 3. rotate around (perceived) volume center
% 4. un-translate according to the fudge factor (extratrans)
% 5. scale so that we are in slice space, with the fudge factor (extrascale)
% 6. shear in slice space
% 7. translate so that we are no longer centered around matrix center; instead we are in the normal position
% 8. end in slice space

% OLD WAY OF DOING IT:
% mat = xyztranslate((1+tr.matrixsize(tr.reorder))/2)*xyzscale(1./(tr.matrixfov(tr.reorder)./tr.matrixsize(tr.reorder)))*rotmatrix*xyztranslate(-tr.trans)*pre;
mat = xyztranslate((1+tr.matrixsize(tr.reorder))/2)* ...
      xyzshear(-tr.extrashear(tr.reorder),tr.extrashearflag(tr.reorder))* ...
      xyzscale(1./(tr.extrascale(tr.reorder).*tr.matrixfov(tr.reorder)./tr.matrixsize(tr.reorder)))* ...
      xyztranslate(-tr.extratrans(tr.reorder))* ...
      rotmatrix* ...
      xyztranslate(-tr.trans)* ...
      pre;
XYZ = mat*XYZ;

% reorder if necessary
if ~isequal(tr.reorder,[1 2 3])
  XYZ(1:3,:) = XYZ([find(tr.reorder==1) find(tr.reorder==2) find(tr.reorder==3)],:);
end

% flip if necessary
if tr.flip(1)
  XYZ(1,:) = (tr.matrixsize(1)+1)-XYZ(1,:);
end
if tr.flip(2)
  XYZ(2,:) = (tr.matrixsize(2)+1)-XYZ(2,:);
end
if tr.flip(3)
  XYZ(3,:) = (tr.matrixsize(3)+1)-XYZ(3,:);
end
