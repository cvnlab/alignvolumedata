function [data,dar] = alignvolumedata_drawvolume_helper(type,interptype,dim,slice,sliceavg,tr,rotations,overlaymode, ...
  overlaymain,ref,tgt,refdar,tgtdar)

% function [data,dar] = alignvolumedata_drawvolume_helper(type,interptype,dim,slice,sliceavg,tr,rotations,overlaymode, ...
%   overlaymain,ref,tgt,refdar,tgtdar)
%
% <type> is 1 (ref), 2 (target), 3 (overlay)
% <interptype> is a string
% <dim> is which dimension to slice through (1, 2, or 3)
% <slice> is a 3-element vector indicating which slice of the target
% <sliceavg> is a nonzero integer (see reslicevolume for meaning)
% <tr> is the output from maketransformation.m
% <rotations> is a 3-element vector of integers indicating the rotation of the image
%   (note that rotations are for display purposes only.)
% <overlaymode> is 1 (single), 2 (subtract), 3 (checker)
% <overlaymain> is 0 (ref), 1 (target)
% <ref> is the ref image (needed only in type==3)
% <tgt> is the target image (needed only in type==3)
% <refdar> is the ref data aspect ratio (needed only in type==3)
% <tgtdar> is the target data aspect ratio (needed only in type==3)
%   
% simply return the image matrix and the data aspect ratio.

global AV_TGTVOL AV_TGTLENGTHS AV_REFLENGTHS AV_TGTSIZE AV_REFSIZE AV_REFVOL;
global AV_TGTRANGE AV_REFRANGE;

% do it
switch type
case 1
  % calc grid (if necessary)
  alignvolumedata_calcgrid(0,interptype,1);
  % get slice
  [data,dar] = ...
    reslicevolume(0,tr,interptype,dim,slice(dim),sliceavg,1,AV_REFVOL,AV_REFLENGTHS,AV_REFSIZE, ...  % TODO: make autoupsample controllable by user?
           AV_TGTVOL,AV_TGTLENGTHS,AV_TGTSIZE);
  % rotate
  data = rot90(squeeze(data),rotations(dim));
  % deal with dar
  dar(dim) = [];
  if mod(rotations(dim),2)==1
    dar = fliplr(dar);
  end
  dar = [dar 1];
case 2
  data = rot90(squeeze(subscript(AV_TGTVOL,indexall(3,dim,slice(dim)))),rotations(dim));
  % deal with dar
  dar = AV_TGTLENGTHS;
  dar(dim) = [];
  if mod(rotations(dim),2)==1
    dar = fliplr(dar);
  end
  dar = [dar 1];
case 3
  switch overlaymode
  case 1
    switch overlaymain
    case 0
      data = ref;
      dar = refdar;
    case 1
      data = tgt;
      dar = tgtdar;
    end
  case 2
    tgt = normalizerange(tgt,AV_REFRANGE(1),AV_REFRANGE(2),AV_TGTRANGE(1),AV_TGTRANGE(2));
    tgt = upsamplematrix(tgt,tgtdar(1:2)./refdar(1:2),[],[],'nearest');  % NOTE: this is only approximate
    switch overlaymain
    case 0
      data = ref-tgt;
    case 1
      data = tgt-ref;
    end
    data = normalizerange(data,AV_REFRANGE(1),AV_REFRANGE(2),AV_REFRANGE(1)-AV_REFRANGE(2),AV_REFRANGE(2)-AV_REFRANGE(1));
    dar = refdar;
  case 3
    % load settings
    settings = alignvolumedata_transformpreferences(alignvolumedata_loadsettings({},0));
    % construct mask (TODO: it is inefficient to construct this each time!)
    mx = max(size(ref,1),size(ref,2));  % larger of two dimensions
    num = ceil(mx/settings.checkersize);  % need this many checks
    mask = repmat([0 1],1,ceil(num/2));  % construct periods
    mask = upsamplematrix(mask,[1 settings.checkersize],[],[],'nearest');  % flesh out periods
    mask = repmat(mask,[length(mask) 1]);  % flesh out columns
    mask = xor(mask,mask');  % xor to finish checker mask (this has 0s at upper left)
    % do it
    switch overlaymain
    case 0
      tgt = normalizerange(tgt,AV_REFRANGE(1),AV_REFRANGE(2),AV_TGTRANGE(1),AV_TGTRANGE(2));  % bring tgt to ref
      tgt = upsamplematrix(tgt,tgtdar(1:2)./refdar(1:2),[],[],'nearest');  % NOTE: this is only approximate
      data = ref.*~mask(1:size(ref,1),1:size(ref,2)) + tgt.*mask(1:size(tgt,1),1:size(tgt,2));
    case 1
      ref = normalizerange(ref,AV_TGTRANGE(1),AV_TGTRANGE(2),AV_REFRANGE(1),AV_REFRANGE(2));  % bring ref to tgt
      tgt = upsamplematrix(tgt,tgtdar(1:2)./refdar(1:2),[],[],'nearest');  % NOTE: this is only approximate
      data = tgt.*~mask(1:size(tgt,1),1:size(tgt,2)) + ref.*mask(1:size(ref,1),1:size(ref,2));
    end
    dar = refdar;
  end
end
