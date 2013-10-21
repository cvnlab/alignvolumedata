function f = extractslices(refvolume,reflengths,targetvolume,targetlengths,tr,mode,interptype,sliceavg);

% function f = extractslices(refvolume,reflengths,targetvolume,targetlengths,tr,mode,interptype,sliceavg);
%
% <refvolume>,<reflengths>,<targetvolume>,<targetlengths> are as in alignvolumedata.m
% <tr> is:
%   (1) a transformation struct
%   (2) a 4x4 transformation matrix telling us how to go from
%       target space to reference space
% <mode> (optional) is
%   0 means to extract slices from reference to match target
%   1 means to extract slices from target to match reference
%   default: 0.
% <interptype> (optional) is
%   'nearest' | 'linear' | 'cubic'
%   default: 'cubic'.
% <sliceavg> (optional) is a nonzero integer; the magnitude indicates how many
%   actual extracted slices are averaged to produce a single bonafide
%   slice; a positive sign means to avoid matrix element boundaries,
%   while a negative sign means to coincide on matrix element 
%   boundaries.  extracted slices are equally spaced within
%   the matrix space they are extracted from.  examples:
%     slice 15 with <sliceavg>==2 means to average slices
%       14.75 and 15.25.
%     slice 15 with <sliceavg>==-3 means to average slices
%       14.5, 15, and 15.5.
%   default: 1.
%
% in mode 0, return a matrix representing the extracted slices from the 
% reference volume.  if the volumes are correctly aligned, then the
% returned matrix should be comparable to the target volume.
%
% in mode 1, return a matrix representing the extracted slices from the
% target volume.  if the volumes are correctly aligned, then the
% returned matrix should be comparable to the reference volume.
%
% example:
% (see the example in alignvolumedata.m)

% input
if ~exist('mode','var') || isempty(mode)
  mode = 0;
end
if ~exist('interptype','var') || isempty(interptype)
  interptype = 'cubic';
end
if ~exist('sliceavg','var') || isempty(sliceavg)
  sliceavg = 1;
end
  % these defaults come from alignvolumedata.m:
if isempty(reflengths)
  reflengths = [1 1 1];
end
if isempty(targetlengths)
  targetlengths = [1 1 1];
end

  % notice the on-the-fly conversion to double
  % TODO: we could allow the user to cache...  (see alignvolumedata_exportvolume.m)
f = reslicevolume(mode,tr,interptype,3,[],sliceavg,0,double(refvolume),reflengths, ...
                  sizefull(refvolume,3),double(targetvolume),targetlengths,sizefull(targetvolume,3));
