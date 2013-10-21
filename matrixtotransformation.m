function tr = matrixtotransformation(T,dir,reflengths,targetmatrixsize,targetmatrixfov)

% function tr = matrixtotransformation(T,dir,reflengths,targetmatrixsize,targetmatrixfov)
%
% <T> is a 4x4 matrix representing the affine transformation from
%   target (or reference) space to reference (or target) space.
% <dir> is:
%   0 means target space to reference space
%   1 means reference space to target space
% <reflengths> is like in alignvolumedata.m, and gives the physical length of
%   a voxel in the reference volume (e.g. [.7 .7 .7] millimeters)
% <targetmatrixsize> is the matrix size of the target volume (e.g. [64 64 16])
% <targetmatrixfov> is the FOV of the target volume (e.g. [192 192 48] millimeters)
%
% this function returns a transformation of the format
% returned by maketransformation.m.  to prevent ambiguity,
% we enforce the policy that the returned transformation 
% will have <extratrans> set to [0 0 0] and <extrashearflag>
% set to [0 0 0].
%
% example:
% (see the example in alignvolumedata.m)

% input (inherited from alignvolumedata.m)
if ~exist('reflengths','var') || isempty(reflengths)
  reflengths = [1 1 1];
end

% initialize
clear tr;
tr.flip = [0 0 0];
tr.reorder = [1 2 3];
tr.rotorder = [1 2 3];
tr.extratrans = [0 0 0];
tr.extrashearflag = [0 0 0];
tr.matrixsize = targetmatrixsize;
tr.matrixfov = targetmatrixfov;

switch dir
case 0

  % define function that maps parameters to a 4x4 matrix
    % rot1 rot2 rot3 trans1 trans2 trans3 extrascale1 extrascale2 extrascale3 extrashear1 extrashear2 extrashear3
  fun = @(pp) ...
        xyztranslate([.5 .5 .5])* ...
        xyzscale(1./reflengths)* ...
        xyztranslate([-.5 -.5 -.5])* ...
        xyztranslate(pp(4:6))* ...
        xyzrotate_z(pp(3))*xyzrotate_y(pp(2))*xyzrotate_x(pp(1))* ...
        xyzscale(pp(7:9) .* tr.matrixfov./tr.matrixsize)* ...
        xyzshear(pp(10:12),tr.extrashearflag)* ...
        xyztranslate(-(1+tr.matrixsize)/2) - T;
  
case 1
  
  % define function that maps parameters to a 4x4 matrix
    % rot1 rot2 rot3 trans1 trans2 trans3 extrascale1 extrascale2 extrascale3 extrashear1 extrashear2 extrashear3
  fun = @(pp) ...
        xyztranslate((1+tr.matrixsize)/2)* ...
        xyzshear(-pp(10:12),tr.extrashearflag)* ...
        xyzscale(1./(pp(7:9).*tr.matrixfov./tr.matrixsize))* ...
        xyzrotate_x(-pp(1))*xyzrotate_y(-pp(2))*xyzrotate_z(-pp(3))* ...
        xyztranslate(-pp(4:6))* ...
        xyztranslate([.5 .5 .5])* ...
        xyzscale(reflengths)* ...
        xyztranslate([-.5 -.5 -.5]) - T;

end

% optimize
options = optimset('Display','iter','FunValCheck','on','MaxFunEvals',Inf,'MaxIter',Inf,'TolFun',1e-6,'TolX',1e-6);
[params0,d,d,exitflag,output] = lsqnonlin(fun,[0 0 0 0 0 0 1 1 1 0 0 0],[],[],options);
assert(exitflag >= 0);

% ok, record  
tr.rot = params0(1:3);
tr.trans = params0(4:6);
tr.extrascale = params0(7:9);
tr.extrashear = params0(10:12);
