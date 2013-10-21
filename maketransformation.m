function tr = maketransformation(flip,reorder,trans,rotorder,rot,matrixsize,matrixfov,extrascale,extratrans,extrashear,extrashearflag)

% function tr = maketransformation(flip,reorder,trans,rotorder,rot,matrixsize,matrixfov,extrascale,extratrans,extrashear,extrashearflag)
%
% given transformation parameters, return a struct with all the transformation information.
% the user does not need to worry about the specific meaning of this function.

% INTERNAL NOTES:
%
% <flip> is a 3-element vector of 0/1s where 1 indicates that
%   preliminary flipping of the functional matrix is to 
%   happen in the associated dimension.  <flip> can be [],
%   which is equivalent to [0 0 0], which means no flipping.
% <reorder> is a permutation of [1 2 3] indicating any
%   reordering of dimensions after flipping.  for example,
%   <reorder>==[3 1 2] and <flip>==[0 0 1] means to first
%   flip along the z-dimension, and then map the z-, x-,
%   and y-dimensions to the x-, y-, and z-dimensions.
%   <reorder> can be [], which is equivalent to [1 2 3],
%   which means no dimension reordering.
% <trans> is a 3-element vector indicating the position in
%   space that the center of the functional volume (after
%   being processed for <flip> and <reorder>) should
%   be located at.  <trans> can be [], which is equivalent
%   to (.5+(.5+<matrixfov>))/2, which is the center of
%   the matrix if it were anchored to (.5,.5,.5).
% <rotorder> is a permutation of [1 2 3] indicating the
%   order in which rotations are performed.  for example,
%   <rotorder>==[2 3 1] means y, z, and then x.  <rotorder>
%   can be [], which is equivalent to [1 2 3].
% <rot> is a 3-element vector of degrees of rotation for each
%   dimension for the functional volume (after being
%   processed for <flip>, <reorder>, and <trans>).  
%   rotation is performed in the order specified by
%   <rotorder>.  <rot> can be [], which is equivalent
%   to [0 0 0].
% <matrixsize>: (target) matrix size (like [64 64 16])
% <matrixfov>: (target) matrix FOV in mm (like [192 192 48])
% <extrascale> (optional): is a 3-element vector of scale
%   factors to apply to each dimension of the functional
%   volume (after being processed for <flip>, <reorder>,
%   <trans>, <rotorder>, and <rot>).  note that the anchor 
%   point of the scaling is <trans>.  if [] or not supplied,
%   default to [1 1 1].
% <extratrans> (optional): is a 3-element vector indicating
%   the number of real (not matrix) units along each dimension
%   of the functional volume (after being processed for
%   <flip>, <reorder>, <trans>, <rotorder>, <rot>, and
%   <extrascale>).  if [] or not supplied, default to [0 0 0].
% <extrashear> (optional): is a 3-element vector of shear
%   factors ([xy yz xz]) to apply to the functional volume
%   (after being processed for <flip>, <reorder>, <trans>, 
%   <rotorder>, <rot>, <extrascale>, and <extratrans>).  if []
%   or not supplied, default to [0 0 0].  (note that this is
%   the very last step!!)
% <extrashearflag> (optional): is a 3-element vector of 0/1
%   indicating flips to the shear directions.  for example, [1 0 0] means
%   interpret <extrashear> as [yx yz xz].  if [] or not supplied,
%   default to [0 0 0].
%
% return a struct with all the transformation information.
% the format of the struct is like:
%   tr.flip
%   tr.reorder
%   tr.trans
%   tr.rotorder
%   tr.rot
%   tr.matrixsize
%   tr.matrixfov
%   tr.extrascale
%   tr.extratrans
%   tr.extrashear
%   tr.extrashearflag
%   [tr.extra]
% where tr.extra is an optional field.  if tr.extra exists,
% it is another transformation struct but which definitely does 
% not itself have an 'extra' field.  the 'extra' field is
% used only in special cases where we want to apply two consecutive
% transformations, and the first transformation that gets applied
% is the "parent" transformation.  note that you have to 
% manually create a transformation struct with an 'extra' field,
% since this function cannot do it for you.
%
% some comments on the <extrascale> and <extratrans> feature:
% strictly speaking, there is no additional freedom afforded 
% by those two parameters.  in particular, the scaling 
% afforded by <extrascale> can be achieved by changing 
% the FOV in <matrixfov>.  however, the two parameters are
% convenient as a hack.  the idea is that after applying 
% the <extrascale> and <extratrans> transformations, we 
% pretend that we still have the originally specified
% matrix size and FOV (as specified by <matrixsize>
% and <matrixfov>).  THIS POINT IS IMPORTANT TO ABSORB.
%
% note that the <extrashearflag> does not add any additional
% transformation flexibility, since a shear along the other
% direction can be achieved by a shear along the first direction
% plus a rotation.

% define
if isempty(flip)
  tr.flip = [0 0 0];
else
  tr.flip = flip;
end
if isempty(reorder)
  tr.reorder = [1 2 3];
else
  tr.reorder = reorder;
end
if isempty(trans)
  tr.trans = (.5+(.5+matrixfov))/2;
else
  tr.trans = trans;
end
if isempty(rotorder)
  tr.rotorder = [1 2 3];
else
  tr.rotorder = rotorder;
end
if isempty(rot)
  tr.rot = [0 0 0];
else
  tr.rot = rot;
end
tr.matrixsize = matrixsize;
tr.matrixfov = matrixfov;
if ~exist('extrascale','var') || isempty(extrascale)
  extrascale = [1 1 1];
end
tr.extrascale = extrascale;
if ~exist('extratrans','var') || isempty(extratrans)
  extratrans = [0 0 0];
end
tr.extratrans = extratrans;
if ~exist('extrashear','var') || isempty(extrashear)
  extrashear = [0 0 0];
end
tr.extrashear = extrashear;
if ~exist('extrashearflag','var') || isempty(extrashearflag)
  extrashearflag = [0 0 0];
end
tr.extrashearflag = extrashearflag;

% check
verifytransformation(tr);
