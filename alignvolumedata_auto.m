function alignvolumedata_auto(ballmn,ballsd,ptype,skip,interptype,sliceavg,updateiter,metricinfo,tol,extraopt)

% function alignvolumedata_auto(ballmn,ballsd,ptype,skip,interptype,sliceavg,updateiter,metricinfo,tol,extraopt)
%
% <ballmn> (optional) indicates the position of the 3D Gaussian (see makegaussian3d.m).
%   default: [.5 .5 .5].  consider using defineellipse3d.m to figure out what to use.
%   special case is a 3D matrix (determined via ~isvector(ballmn)) which is 0/1
%   indicating which voxels to use.  in this case, the 3D matrix should be the 
%   same size as the target volume and <ballsd> is ignored.
% <ballsd> (optional) indicates the size of the 3D Gaussian (see makegaussian3d.m).
%   default: [.2 .2 .2].  consider using defineellipse3d.m to figure out what to use.
% <ptype> (optional) indicates the transformation parameters to adjust.
%   0 means translation and rotation
%   1 means translation, rotation, and scaling
%   2 means translation, rotation, scaling, and shearing
%   3 means scaling
%   [TX TY TZ RX RY RZ ESX ESY ESZ EHX EHY EHZ] where each element is 0/1 indicates
%     which parameters to adjust (translations, rotations, scalings, shearings)
%   default: 0.
% <skip> (optional) is [G H I] with the number of matrix elements
%   to skip when extracting slices.  for example, [2 2 1] means extract
%   every other voxel in the first two dimensions but all voxels along
%   the third dimension.  the point of this is to speed up the 
%   optimization (at the cost of potentially suboptimal results).
%   default: [4 4 2].  TODO: smarter default.
% <interptype> (optional) is 'nearest' | 'linear' | 'cubic'
%   default: 'linear'.
% <sliceavg> (optional) is like in extractslices.m.  slice-averaging is important
%   when the slice thickness of the target volume is substantially larger than
%   the resolution of the reference volume.  default: 1.
% <updateiter> (optional) is the number of iterations after which to update the GUI.
%   default: 1.
% <metricinfo> (optional) is
%   0 means maximize abs of the correlation (see calccorrelation.m)
%   [1 N] means maximize mutual information calculated using N bins
%     (see calcmutualinformationcontinuous.m).  can pass in 1 which means
%     to use a default of 30 bins.  convergence is a bit tricky when using
%     the mutual information metric.  moreover, the execution time is quite
%     long.  to be on the safe side, let the optimization run to completion 
%     (don't stop it early).  there may be better strategy than the one
%     we implement (see code for details).  if it is applicable to your
%     data, it is faster and more robust to use the correlation metric
%     than the mutual information metric.
%  default: 0.
% <tol> (optional) is the tolerance for TolFun and TolX.  default: 1e-4.
% <extraopt> (optional) is a cell vector of extra parameter/value pairs to use
%   in the optimization options (e.g. {'Large-Scale' 'off'}).  default: {}.
% 
% automatically adjust transformation parameters to achieve a better match
% between slices extracted from the reference volume and the target volume.
% we use MATLAB's Optimization Toolbox and our metric is specified by <metricinfo>. 
% as the optimization proceeds, the GUI is automatically updated (and at each step,
% we toggle between the reference and the target a few times for visualization purposes).
%
% the optimization is subject to two factors.  first, we construct a 3D Gaussian
% and consider only those voxels that are above half the maximum of the Gaussian.
% this is useful for ignoring artifacts like the skull and fat.  second, we allow
% voxels to be skipped (via <skip>) in order to achieve faster execution.
%
% before the optimization starts, we display in Figure 999 the 
% target volume after having been subjected to skipping.  we show two versions:
% one version shows all voxels that we will not consider in the optimization;
% the other version shows all voxels that we will consider in the optimization.
% the purpose of this visualization is so that you can ensure that the values 
% you set for <ballmn>, <ballsd>, and <skip> are reasonable.
%
% if you would like to stop the optimization manually, press 'q' in Figure 999.
%
% example:
% (see the example in alignvolumedata.m)
%
% history:
% 2012/02/28 - add flexibility to <ballmn>
% 2011/06/28 - add <extraopt> input
% 2011/03/14 - add <tol> input
% 2010/12/27 - add mutual information option to <metricinfo>
% 2010/09/29 - make it use abs of corr, not just corr !

% internal constants
dim = 3;  % we assume this is the dimension to work on

% input
if ~exist('ballmn','var') || isempty(ballmn)
  ballmn = [.5 .5 .5];
end
if ~exist('ballsd','var') || isempty(ballsd)
  ballsd = [.2 .2 .2];
end
if ~exist('ptype','var') || isempty(ptype)
  ptype = 0;
end
if ~exist('skip','var') || isempty(skip)
  skip = [4 4 2];
end
if ~exist('interptype','var') || isempty(interptype)
  interptype = 'linear';
end
if ~exist('sliceavg','var') || isempty(sliceavg)
  sliceavg = 1;
end
if ~exist('updateiter','var') || isempty(updateiter)
  updateiter = 1;
end
if ~exist('metricinfo','var') || isempty(metricinfo)
  metricinfo = 0;
end
if ~exist('tol','var') || isempty(tol)
  tol = 1e-4;
end
if ~exist('extraopt','var') || isempty(extraopt)
  extraopt = {};
end
if isequal(metricinfo,1)
  metricinfo = [1 30];
end

% declare globals
global AV_REFVOL AV_REFLENGTHS AV_REFSIZE AV_TGTVOL AV_TGTLENGTHS AV_TGTSIZE;

% get the current transformation
tr = alignvolumedata_exporttransformation(0);

% calc grid if necessary
alignvolumedata_calcgrid(0,interptype,0);
alignvolumedata_calcgrid(1,'linear',0);  % 'linear' forces a calculation

% calculate 3D Gaussian ball (same dimensions as target matrix)
if ~isvector(ballmn)
  ball = ballmn;
else
  ball = makegaussian3d(AV_TGTSIZE,ballmn,ballsd,[],[],[]) > .5;
end

% calc
fullparams = [tr.trans tr.rot tr.extrascale tr.extrashear];

% figure out which parameters to update
if length(ptype)==1
  switch ptype
  case 0
    ix = 1:6;
  case 1
    ix = 1:9;
  case 2
    ix = 1:12;
  case 3
    ix = 7:9;
  end
else
  ix = find(ptype);
end
seed = fullparams(ix);

% pre-compute
ball0 = ball(1:skip(1):end,1:skip(2):end,1:skip(3):end);
wvol = (1-ball0) .* AV_TGTVOL(1:skip(1):end,1:skip(2):end,1:skip(3):end);
wvol2 = (ball0) .* AV_TGTVOL(1:skip(1):end,1:skip(2):end,1:skip(3):end);
cvol = subscript(AV_TGTVOL(1:skip(1):end,1:skip(2):end,1:skip(3):end),ball0);

% show the target volume
figure(999); clf; set(gcf,'CurrentCharacter','z');
imagesc(cat(2,makeimagestack(wvol,1),makeimagestack(wvol2,1))); axis equal tight;

% define the function
if isequal(metricinfo,0)
  metricfun = @(x,y) sqrt(2-abs(calccorrelation(x,y,0)));
else
  metricfun = @(x,y) -calcmutualinformationcontinuous(x,y,metricinfo(2));
end
fun = @(pp) feval(metricfun, ...
  subscript(reslicevolume(0,maketransformation([0 0 0],[1 2 3],pp(1:3),[1 2 3],pp(4:6), ...
                                              tr.matrixsize,tr.matrixfov,pp(7:9), ...
                                              tr.extratrans,pp(10:12),tr.extrashearflag), ...
                         interptype,dim,1:skip(3):AV_TGTSIZE(3),sliceavg,0, ...
                         AV_REFVOL,AV_REFLENGTHS,AV_REFSIZE, ...
                         AV_TGTVOL,AV_TGTLENGTHS,AV_TGTSIZE, ...
                         skip),ball0),cvol);

% optimize
options = optimset('Display','iter','FunValCheck','on','MaxFunEvals',Inf,'MaxIter',Inf, ...
                   'TolFun',tol,'TolX',tol,'OutputFcn',@(x,y,z,aa,bb,cc) alignvolumedata_auto_outputfcn(x,y,z,updateiter,ix),extraopt{:});
optionsB = optimset('Display','iter','FunValCheck','on','MaxFunEvals',Inf,'MaxIter',50,'TolFun',tol,'TolX',tol,extraopt{:});
if isequal(metricinfo,0)
  [params0,d,d,exitflag,output] = lsqnonlin(@(jj) feval(fun,copymatrix(fullparams,ix,jj)),seed,[],[],options);
else
  fprintf('*** performing 50 iterations of fminsearch to get close to the solution (no GUI update is performed)... ***\n');
  [params0,d,exitflag,output] = fminsearch(@(jj) feval(fun,copymatrix(fullparams,ix,jj)),seed,optionsB);
  fprintf('*** now performing the main optimization... ***\n');
  [params0,d,exitflag,output] = fminunc(@(jj) feval(fun,copymatrix(fullparams,ix,jj)),params0,options);
end
assert(exitflag >= -1);
