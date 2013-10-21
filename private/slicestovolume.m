function XYZ = slicestovolume(XYZ,tr,post)

% function XYZ = slicestovolume(XYZ,tr,post)
%
% <XYZ> are coordinates in slice space
% <tr> is of the format described in maketransformation.m
% <post> (optional) is a transformation matrix to apply
%   as the very last step.  if [] or not supplied, don't
%   do anything.
%
% based on the information in <tr>, return the
% coordinates as they would be in coordinate space.
% note that coordinate space is not necessarily
% reference space!

% deal with input
if ~exist('post','var') || isempty(post)
  post = eye(4);
end

% deal with 'extra' case
if isfield(tr,'extra')  % DEPRECATED
  % we need a intermediary matrix that goes from volume to slice
  temp = xyztranslate([.5 .5 .5])*xyzscale(1./(tr.matrixsize./tr.matrixfov))*xyztranslate([-.5 -.5 -.5]);
  XYZ = slicestovolume(slicestovolume(XYZ,tr.extra,temp),rmfield(tr,'extra'),post);
  return;
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

% reorder if necessary
if ~isequal(tr.reorder,[1 2 3])
  XYZ(1:3,:) = XYZ(tr.reorder,:);
end

% prepare rotation
rotmatrix = 1;
for p=tr.rotorder
  switch p
  case 1
    rotmatrix = xyzrotate_x(tr.rot(1))*rotmatrix;
  case 2
    rotmatrix = xyzrotate_y(tr.rot(2))*rotmatrix;
  case 3
    rotmatrix = xyzrotate_z(tr.rot(3))*rotmatrix;
  end
end

% transform
% 0. start in slice space
% 1. translate so that we are centered around matrix center
% 2. shear in slice space
% 3. scale so that we are in coordinate space, with the fudge factor (extrascale)
% 4. translate according to the fudge factor (extratrans) along the slice dimensions
% 5. rotate around the original slice volume center (before the extratrans adjustment)
% 6. translate
% 7. apply post-operation
% 8. end in coordinate space
% OLD WAY OF DOING IT:
% mat = post*xyztranslate(tr.trans)*rotmatrix*xyzscale(tr.matrixfov(tr.reorder)./tr.matrixsize(tr.reorder))*xyztranslate(-(1+tr.matrixsize(tr.reorder))/2);
mat = post* ...
      xyztranslate(tr.trans)* ...
      rotmatrix* ...
      xyztranslate(tr.extratrans(tr.reorder))* ...
      xyzscale(tr.extrascale(tr.reorder).*tr.matrixfov(tr.reorder)./tr.matrixsize(tr.reorder))* ...
      xyzshear(tr.extrashear(tr.reorder),tr.extrashearflag(tr.reorder))* ...
      xyztranslate(-(1+tr.matrixsize(tr.reorder))/2);
XYZ = mat*XYZ;
