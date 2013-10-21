function varargout = reslicevolume(mode,tr,interptype,dim,slices, ...
  sliceavg,autoupsample, ...
  refvol,reflengths,refsize, ...
  tgtvol,tgtlengths,tgtsize, ...
  skip)

% function varargout = reslicevolume(mode,tr,interptype,dim,slices, ...
%   sliceavg,autoupsample, ...
%   refvol,reflengths,refsize, ...
%   tgtvol,tgtlengths,tgtsize, ...
%   skip)
%
% <mode> is 0 means to extract slices from reference to match target
%           1 means to extract slices from target to match reference
%           2 is like 0 but we return volume coordinates of the extracted slices
%           3 is like 1 but we return volume coordinates of the extracted slices
% <tr> is:
%   (1) a transformation struct
%   (2) a 4x4 transformation matrix telling us how to go from
%       target space to reference space
% <interptype> is a string.  ignored if mode is 2 or 3.
% <dim> is the dimension of target in normal mode (or ref in
%   reverse mode) being sliced through
% <slices> is the slices desired (scalar index or vector of indices).
%   if [], default to doing all slices.
% <sliceavg> is a nonzero integer; the magnitude indicates how many
%   actual extracted slices are averaged to produce a single bonafide
%   slice; a positive sign means to avoid matrix element boundaries,
%   while a negative sign means to coincide on matrix element 
%   boundaries.  extracted slices are equally spaced within
%   the matrix space they are extracted from.  examples:
%     slice 15 with <sliceavg>==2 means to average slices
%       14.75 and 15.25.
%     slice 15 with <sliceavg>==-3 means to average slices
%       14.5, 15, and 15.5.
%   forced to be 1 if <mode> is 2 or 3.
% <autoupsample> is whether to automatically upsample by a whole
%   number factor in the plane of the slices to achieve at least
%   the resolution of the minimum length dimension of the volume
%   being extracted from.
% <refvol>,<reflengths>,<refsize>,<tgtvol>,<tgtlengths>,<tgtsize>
%   are as the global variables in alignvolumedata.
%   in mode 2, <refvol>,<reflengths>,<refsize>,<tgtvol>,<tgtlengths> are ignored.
%   in mode 3, <tgtvol>,<tgtlengths>,<tgtsize>,<refvol>,<reflengths> are ignored.
% <skip> (optional) is a 3-element vector with positive integers.  the one that
%   corresponds to the slice dimension is ignored.  of the remaining ones,
%   if any is not 1, then this indicates that we don't want to extract all
%   voxels and in this case <autoupsample> must be 0.  default: [1 1 1].
%
% if <mode> is 0 or 1, do the following:
%   in the normal mode (0), return as the first argument
%   a single matrix representing the extracted slices from the 
%   reference volume.  in the reverse mode (1), return as
%   the first argument a single matrix representing the extracted
%   slices from the target volume.  note that the 
%   extracted slices are in the expected shape but squeezed.
%   for example, if you want slices [3 5 8] from dimension 2, 
%   then the extracted slices will have something like 
%   dimensions [256 3 256].  in both modes, return as the
%   second argument a vector of lengths that correspond to
%   the extracted slices.  note that if <autoupsample> is 0,
%   then these lengths will simply be the lengths associated
%   with the the volume being matched to.
% if <mode> is 2 or 3, do the same as above, but return as the
%   first three arguments containing the x-, y-, and z-coordinates
%   corresponding to the positions of the voxels of the
%   extracted slices.  note that these coordinates will be
%   in coordinate space, not reference or target space.  (the
%   fourth argument is the vector of lengths.)

% deal with input
if ~exist('skip','var') || isempty(skip)
  skip = [1 1 1];
end
if isempty(slices)
  switch mode
  case {0 2}
    slices = 1:tgtsize(dim);
  case {1 3}
    slices = 1:refsize(dim);
  end
end

% further dealing of input
if mode==2 || mode==3
  interptype = '';
  sliceavg = 1;
end  
% if isequal(interptype,'linear') || isequal(interptype,'cubic')
%   interptype = ['*' interptype];  % in these modes, we can cause a speed-up (see MATLAB's documentation for interpn)
% end

switch mode

% NORMAL MODE
case {0 2}

  % ok, figure out outputlengths
  outputlengths = tgtlengths;
  fctr = [1 1 1];  % this is the extra factor applied
  if autoupsample
    bestres = min(reflengths);  % best resolution we can get from the volume being extracted from
    otherdims = setdiff(1:3,dim);
    for otherdim=otherdims
      fctr(otherdim) = ceil(outputlengths(otherdim)/bestres);
      outputlengths(otherdim) = outputlengths(otherdim)/fctr(otherdim);
    end
  end
  
  % set up some vars
  tgtsize2 = [length(1:skip(1):tgtsize(1)) length(1:skip(2):tgtsize(2)) length(1:skip(3):tgtsize(3))];  % target size, reflecting the skip
  slicessize = tgtsize2;
  slicessize(dim) = length(slices);
  slicessize = slicessize.*fctr;
  slicesize = tgtsize2;
  slicesize(dim) = abs(sliceavg);  % one slice is actually composed of multiple slices for averaging...
  slicesize = slicesize.*fctr;
  
  % do it (slice by slice to save on memory requirements)
  if mode==0
    f = zeros(slicessize);
  else
    x = zeros(slicessize);
    y = zeros(slicessize);
    z = zeros(slicessize);
  end
  for p=1:length(slices)
    slice = slices(p);

    % determine range for averages
    if sliceavg > 0
      slicerange = linspacefixeddiff(slice,1/abs(sliceavg),abs(sliceavg)) + (1/abs(sliceavg))/2 - 1/2;
    else
      if sliceavg==-1
        slicerange = slice;
      else
        slicerange = linspacefixeddiff(slice,1/(abs(sliceavg)-1),abs(sliceavg)) - 1/2;
      end
    end

    % construct mesh for a single slice (which may be composed of multiple averages)
    switch dim
    case 1
      if ~autoupsample
        [X,Y,Z] = ndgrid(slicerange,1:skip(2):tgtsize(2),1:skip(3):tgtsize(3));
      else
        [X,Y,Z] = ndgrid(slicerange,resamplingindices(1,tgtsize(2),-fctr(2)),resamplingindices(1,tgtsize(3),-fctr(3)));
      end
    case 2
      if ~autoupsample
        [X,Y,Z] = ndgrid(1:skip(1):tgtsize(1),slicerange,1:skip(3):tgtsize(3));
      else
        [X,Y,Z] = ndgrid(resamplingindices(1,tgtsize(1),-fctr(1)),slicerange,resamplingindices(1,tgtsize(3),-fctr(3)));
      end
    case 3
      if ~autoupsample
        [X,Y,Z] = ndgrid(1:skip(1):tgtsize(1),1:skip(2):tgtsize(2),slicerange);
      else
        [X,Y,Z] = ndgrid(resamplingindices(1,tgtsize(1),-fctr(1)),resamplingindices(1,tgtsize(2),-fctr(2)),slicerange);
      end
    end
    XYZ = constructcoordinates(X,Y,Z);
    
    % transform
    if isstruct(tr)
      % normal struct case.
      % apply transformation.
      if mode==0
        % use a final transformation to get the coordinates
        % into matrix space (so that we can index into it).
        XYZ = slicestovolume(XYZ,tr,xyztranslate([.5 .5 .5])*xyzscale(1./reflengths)*xyztranslate([-.5 -.5 -.5]));
      else
        XYZ = slicestovolume(XYZ,tr);
      end
    else
      % alternative direct case.
      XYZ = tr*XYZ;
    end
    
    % extract or just report coords
    if mode==0
      % ok, do the interpolation
      switch interptype
      case 'nearest'  % TODO: would nearest be faster if we just used the interp?
        % find bad and good
        bad = sum(XYZ < .5,1) | XYZ(1,:) >= refsize(1)+.5 | XYZ(2,:) >= refsize(2)+.5 | XYZ(3,:) >= refsize(3)+.5;
        good = ~bad;
        % init image
        img = zeros(slicesize);
        % get indices and set
        if any(good)
          idx = sub2ind(refsize,round(XYZ(1,good)),round(XYZ(2,good)),round(XYZ(3,good)));  % TODO: could use sub2ind2 (and below)
          img(good) = refvol(idx);
        end
        % all others are NaN
        img(bad) = NaN;
      case {'linear' 'cubic'}  %%%% 'spline'}
        img = reshape(ba_interp3_wrapper(refvol,XYZ,interptype),slicesize);
                            %%OLD:        img = interpn(refvolx1,refvolx2,refvolx3,refvol,XYZ(1,:),XYZ(2,:),XYZ(3,:),interptype);
      end
      
      % average slices together
      img = mean(img,dim);

      % ok, store it
      idx = indexall(ndims(f),dim,p);
      f(idx{:}) = img;
    else
      % ok, reshape and store it
      idx = indexall(ndims(x),dim,p);
      x(idx{:}) = reshape(XYZ(1,:),slicesize);
      y(idx{:}) = reshape(XYZ(2,:),slicesize);
      z(idx{:}) = reshape(XYZ(3,:),slicesize);
    end
  end

% REVERSE MODE
case {1 3}

  % ok, figure out outputlengths
  outputlengths = reflengths;
  fctr = [1 1 1];  % this is the extra factor applied
  if autoupsample
    bestres = min(tgtlengths);  % best resolution we can get from the volume being extracted from
    otherdims = setdiff(1:3,dim);
    for otherdim=otherdims
      fctr(otherdim) = ceil(outputlengths(p)/bestres);
      outputlengths(otherdim) = outputlengths(otherdim)/fctr(otherdim);
    end
  end

  % set up some vars
  refsize2 = [length(1:skip(1):refsize(1)) length(1:skip(2):refsize(2)) length(1:skip(3):refsize(3))];  % reference size, reflecting the skip
  slicessize = refsize2;
  slicessize(dim) = length(slices);
  slicessize = slicessize.*fctr;
  slicesize = refsize2;
  slicesize(dim) = abs(sliceavg);
  slicesize = slicesize.*fctr;
  
  % do it (slice by slice to save on memory requirements)
  if mode==1
    f = zeros(slicessize);
  else
    x = zeros(slicessize);
    y = zeros(slicessize);
    z = zeros(slicessize);
  end
  for p=1:length(slices)
    slice = slices(p);

    % determine range for averages
    if sliceavg > 0
      slicerange = linspacefixeddiff(slice,1/abs(sliceavg),abs(sliceavg)) + (1/abs(sliceavg))/2 - 1/2;  % TODO: can we use resamplingindices here?
    else
      if sliceavg==-1
        slicerange = slice;
      else
        slicerange = linspacefixeddiff(slice,1/(abs(sliceavg)-1),abs(sliceavg)) - 1/2;
      end
    end

    % construct mesh for a single slice (which may be composed of multiple averages)
    switch dim
    case 1
      if ~autoupsample
        [X,Y,Z] = ndgrid(slicerange,1:skip(2):refsize(2),1:skip(3):refsize(3));
      else
        [X,Y,Z] = ndgrid(slicerange,resamplingindices(1,refsize(2),-fctr(2)),resamplingindices(1,refsize(3),-fctr(3)));
      end
    case 2
      if ~autoupsample
        [X,Y,Z] = ndgrid(1:skip(1):refsize(1),slicerange,1:skip(3):refsize(3));
      else
        [X,Y,Z] = ndgrid(resamplingindices(1,refsize(1),-fctr(1)),slicerange,resamplingindices(1,refsize(3),-fctr(3)));
      end
    case 3
      if ~autoupsample
        [X,Y,Z] = ndgrid(1:skip(1):refsize(1),1:skip(2):refsize(2),slicerange);
      else
        [X,Y,Z] = ndgrid(resamplingindices(1,refsize(1),-fctr(1)),resamplingindices(1,refsize(2),-fctr(2)),slicerange);
      end
    end
    XYZ = constructcoordinates(X,Y,Z);
    
    % transform
    if isstruct(tr)
      % normal struct case.
      % apply transformation.
      if mode==1
        % use a preliminary transformation to get the coordinates
        % from matrix space into coordinate space.
        XYZ = volumetoslices(XYZ,tr,xyztranslate([.5 .5 .5])*xyzscale(reflengths)*xyztranslate([-.5 -.5 -.5]));
      else
        XYZ = volumetoslices(XYZ,tr);
      end
    else
      % alternative direct case.
      XYZ = inv(tr)*XYZ;
    end
    
    % extract or just report coords
    if mode==1
      % ok, do the interpolation
      switch interptype
      case 'nearest'  % TODO: would nearest be faster if we just used the interp?
        % find bad and good
        bad = sum(XYZ < .5,1) | XYZ(1,:) >= tgtsize(1)+.5 | XYZ(2,:) >= tgtsize(2)+.5 | XYZ(3,:) >= tgtsize(3)+.5;
        good = ~bad;
        % init image
        img = zeros(slicesize);
        % get indices and set
        if any(good)
          idx = sub2ind(tgtsize,round(XYZ(1,good)),round(XYZ(2,good)),round(XYZ(3,good)));
          img(good) = tgtvol(idx);
        end
        % all others are NaN
        img(bad) = NaN;
      case {'linear' 'cubic'}  %%%% 'spline'}
        img = reshape(ba_interp3_wrapper(tgtvol,XYZ,interptype),slicesize);
                  %%OLD:        img = interpn(tgtvolx1,tgtvolx2,tgtvolx3,tgtvol,XYZ(1,:),XYZ(2,:),XYZ(3,:),interptype);
      end
  
      % average slices together
      img = mean(img,dim);
  
      % ok, store it
      idx = indexall(ndims(f),dim,p);
      f(idx{:}) = img;
    else
      % ok, reshape and store it
      idx = indexall(ndims(x),dim,p);
      x(idx{:}) = reshape(XYZ(1,:),slicesize);
      y(idx{:}) = reshape(XYZ(2,:),slicesize);
      z(idx{:}) = reshape(XYZ(3,:),slicesize);
    end
  end
end

% ok, deal with output
switch mode
case {0 1}
  varargout = {f outputlengths};
case {2 3}
  varargout = {x y z outputlengths};
end
