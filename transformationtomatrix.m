function f = transformationtomatrix(tr,dir,reflengths)

% function f = transformationtomatrix(tr,dir,reflengths)
%
% <tr> is of the format returned by maketransformation.m
% <dir> is:
%   0 means target space to reference space
%   1 means reference space to target space
% <reflengths> is like in alignvolumedata.m
%
% this function returns a 4x4 matrix representing the affine
% transformation from target (or reference) space to reference
% (or target) space.
%
% example:
% (see the example in alignvolumedata.m)

% internal note:
% - this function mirrors slicestovolume and volumetoslices
% to some extent.

% input (inherited from alignvolumedata.m)
if ~exist('reflengths','var') || isempty(reflengths)
  reflengths = [1 1 1];
end

% warn about flips
if any(tr.flip)
  fprintf(1,'warning: flips detected --- ignoring.\n');
end

% warn about reordering
if ~isequal(tr.reorder,[1 2 3])
  fprintf(1,'warning: reordering detected --- ignoring.\n');
end

switch dir
case 0
  % deal with 'extra' case
  if isfield(tr,'extra')  % DEPRECATED
    f = transformationtomatrix(rmfield(tr,'extra'),dir,reflengths)*transformationtomatrix(tr.extra,dir,tr.matrixfov./tr.matrixsize);
    return;
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
  f = xyztranslate([.5 .5 .5])* ...
      xyzscale(1./reflengths)* ...
      xyztranslate([-.5 -.5 -.5])* ...
      xyztranslate(tr.trans)* ...
      rotmatrix* ...
      xyztranslate(tr.extratrans)* ...
      xyzscale(tr.extrascale.*tr.matrixfov./tr.matrixsize)* ...
      xyzshear(tr.extrashear,tr.extrashearflag)* ...
      xyztranslate(-(1+tr.matrixsize)/2);
case 1
  % deal with 'extra' case
  if isfield(tr,'extra')
    f = transformationtomatrix(tr.extra,dir,tr.matrixfov./tr.matrixsize)*transformationtomatrix(rmfield(tr,'extra'),dir);
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
  f = xyztranslate((1+tr.matrixsize)/2)* ...
      xyzshear(-tr.extrashear,tr.extrashearflag)* ...
      xyzscale(1./(tr.extrascale.*tr.matrixfov./tr.matrixsize))* ...
      xyztranslate(-tr.extratrans)* ...
      rotmatrix* ...
      xyztranslate(-tr.trans)* ...
      xyztranslate([.5 .5 .5])* ...
      xyzscale(reflengths)* ...
      xyztranslate([-.5 -.5 -.5]);
end



% OLD DOCUMENTATION
% 
% function f = transformationtomatrix(tr,dir,reflengths)
%
% <tr> is of the format described in maketransformation.m
% <dir> is:
%   0 means slice space to coordinate space
%   1 means coordinate space to slice space
% <reflengths> (optional) is a vector [x y z] where values
%   specify the sizes of the corresponding dimensions of
%   the reference volume.  if [] or not supplied, default
%   to [1 1 1].  supplying this argument (with a value other
%   than [1 1 1]) changes the meaning of this function.
%   see below for details.
%
% assuming that <reflengths> is omitted or is [1 1 1],
% this function returns a 4x4 matrix representing the
% transformation from slice/coordinate space to coordinate/slice
% space.  note that the ability to represent the 
% transformation as a 4x4 matrix is dependent on 
% the transformation <tr> having no flips and no
% reordering (i.e., reorder is x,y,z).  if <tr> 
% contains flips or reordering, we issue a warning,
% act as if the flips and/or reorderings didn't exist,
% and proceed as usual.
% 
% however, if <reflengths> is specified and is not [1 1 1],
% then this function no longer converts to and from volume
% space but rather to and from reference space.  
% recall from alignvolumedata.txt that reference
% space is simply a scaling of coordinate space with respect
% to (.5,.5,.5).
%
% example:
% (see the example in alignvolumedata.m)
