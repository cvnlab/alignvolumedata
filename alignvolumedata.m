function alignvolumedata(refvolume,reflengths,targetvolume,targetlengths,tr)

% function alignvolumedata(refvolume,reflengths,targetvolume,targetlengths,tr)
%
% <refvolume> is a 3D matrix of numbers.  Infs are not allowed,
%   but NaNs are allowed.  consider using preconditionvolume.m
%   to prepare your volume for alignment.
% <reflengths> is a vector [x y z] where values specify
%   the sizes of the corresponding dimensions of <refvolume>.
%   default: [1 1 1].
% <targetvolume> is a 3D matrix of numbers.  Infs are not allowed,
%   but NaN are allowed.  consider using preconditionvolume.m
%   to prepare your volume for alignment.
% <targetlengths> is a vector [x y z] where values specify
%   the sizes of the corresponding dimensions of <targetvolume>.
%   default: [1 1 1].
% <tr> (optional) is of the format returned by maketransformation.m.
%   there are two cases:
%   (1) if <tr> is [] or not supplied, the GUI is seeded with
%       default values.
%   (2) if <tr> is supplied, then we use it to seed the initial 
%       values in the GUI.
%
% essentially, alignvolumedata provides visualization to help you
% to determine the transformation which aligns <targetvolume>
% to <refvolume>.
%
% with regards to centering/offset issues, everything is treated as
% being exactly centered.  so, for a given volume, the center point
% is the exact center of the volume.  for a given slice of a volume,
% it is treated as representing data from the exact middle of the
% corresponding region of space.
%
% NaNs are allowed in <refvolume> and <targetvolume>.  with respect to 
% visualization, NaNs are displayed as the color associated with the 
% lowest value on the colormap (this is a consequence of MATLAB's 
% default behavior).
%
% note that depending on slice orientation, a slice of the reference 
% volume may extend beyond the range of the reference volume.  points 
% that lie beyond the range of the reference volume get associated the 
% value of NaN.  so even if no values in <refvolume> and <targetvolume> 
% are NaN, there is still the potential to encounter NaN values.
%
% note that the interpolation type affects how NaNs are handled.  with 
% 'nearest', the effect of a NaN value is guaranteed to be localized within
% the region associated with that value.  however, with the other 
% interpolation types, the effect of a NaN value may extend beyond the 
% region associated with that value.  so be careful!
%
% please see alignvolumedata.txt for additional information.
%
% example:
% tr = maketransformation([0 0 0],[1 2 3],[122 60.5 137.5],[1 2 3],[104.75 -0.5 -2.75],[256 256 16],[192 192 48],[1 1 1],[0 0 0],[0 0 0],[0 0 0]);
% ref = getsamplebrain(3);
% target = getsamplebrain(2);
% alignvolumedata(ref,[1 1 1],target,[0.75 0.75 3],tr);
% [f,mn,sd] = defineellipse3d(target);
% alignvolumedata_auto(mn,sd,0,[4 4 2]);
% tr = alignvolumedata_exporttransformation
% T = transformationtomatrix(tr,0,[1 1 1])
% refmatch = extractslices(ref,[1 1 1],target,[0.75 0.75 3],T);
% figure; imagesc(makeimagestack(target)); axis equal tight;
% figure; imagesc(makeimagestack(refmatch)); axis equal tight;
% tr2 = matrixtotransformation(T,0,[1 1 1],[256 256 16],[192 192 48])
%
% history:
% 2011/03/12 - change initial seed of the transformation used in the GUI
% 2011/03/08 - make much faster (using ba_interp3), take less memory, remove spline interpolation option, 
%              ensure that the alignvolumedata_auto_outputfcn runs at optimization completion.
% 2010/09/26 - initial re-release.

% internal history:
% 2010/09/25 - (hide keyboard.  hide flip, reorder, rotorder.  note that keyboard is always on.  add 1 2 3 keys.)

%%%%%%%%%%%%%%%%%%%%% preliminary stuff

% OBSOLETE
% % handle surfpak files
% if ~exist('~/.surfpak','dir')
%   assert(mkdir('~','.surfpak'),'failed to create ~/.surfpak directory!');
% end

% prep
refvolume = double(refvolume);
targetvolume = double(targetvolume);

% make sure clean slate (even global vars!)
alignvolumedata_quit(0);

%%%%%%%%%%%%%%%%%%%%% setup

% globals
global AV_REFVOL AV_REFLENGTHS AV_TGTVOL AV_TGTLENGTHS;
global AV_FIGREF AV_FIGTGT AV_FIGOLY AV_GUI;
global AV_REFRANGE AV_TGTRANGE;
global AV_REFSIZE AV_TGTSIZE;

% internal constants
[figrefpos,figtgtpos,figolypos,guipos,maxsingle] = alignvolumedata_constants('figrefpos','figtgtpos','figolypos','guipos','maxsingle');

% load settings, transforming the preference settings into internal format
settings = alignvolumedata_transformpreferences(alignvolumedata_loadsettings({},0));

%%%%%%%%%%%%%%%%%%%%% deal with input

if ~exist('tr','var')
  tr = [];
end
verifytransformation(tr);
if isfield(tr,'extra')  % DEPRECATED
  fprintf(1,'special handling will be done since the ''extra'' field was detected in <tr>.\n');
end

%%%%%%%%%%%%%%%%%%%%%% manipulations...

% get into our preferred format (first pass)
AV_REFLENGTHS = reflengths;
AV_TGTLENGTHS = targetlengths;

% handle defaults
if isempty(AV_REFLENGTHS)
  AV_REFLENGTHS = [1 1 1];
end
if isempty(AV_TGTLENGTHS)
  AV_TGTLENGTHS = [1 1 1];
end

%%%%%%%%%%%%%%%%%%%%% check input

% TODO: should check that no Inf? in general need better verification
assert(isnumeric(refvolume) & ndims(refvolume)<=3,'invalid <refvolume> value');
assert(all(isfinitenum(AV_REFLENGTHS)) & isrowvector(AV_REFLENGTHS) & length(AV_REFLENGTHS)==3 & ...
       all(AV_REFLENGTHS>0),'invalid <reflengths> value');
assert(isnumeric(targetvolume) & ndims(targetvolume)<=3,'invalid <targetvolume> value');
assert(all(isfinitenum(AV_TGTLENGTHS)) & isrowvector(AV_TGTLENGTHS) & length(AV_TGTLENGTHS)==3 & ...
       all(AV_TGTLENGTHS>0),'invalid <targetlengths> value');
if any(size(refvolume) > settings.maxsingledim)
  temp = input('warning: at least one dimension of <refvolume> exceeds the maximum expected size.  are you sure you want to continue? ','s');
  if isequal(temp,'y')
    fprintf(1,'ok, continuing!\n');
  else
    fprintf(1,'ok, aborting!\n');
    return;
  end
end
if any(size(targetvolume) > settings.maxsingledim)
  temp = input('warning: at least one dimension of <targetvolume> exceeds the maximum expected size.  are you sure you want to continue? ','s');
  if isequal(temp,'y')
    fprintf(1,'ok, continuing!\n');
  else
    fprintf(1,'ok, aborting!\n');
    return;
  end
end

%%%%%%%%%%%%%%%%%%%%%% more manipulations...

% get into our preferred format (second pass)
AV_REFVOL = refvolume;
clear refvolume;  % save memory
AV_TGTVOL = targetvolume;
clear targetvolume;  % save memory

% NOTE: at this point, we are using AV_* vars

%%%%%%%%%%%%%%%%%%%%% calculations

AV_REFRANGE = [min(AV_REFVOL(:)) max(AV_REFVOL(:))];
AV_TGTRANGE = [min(AV_TGTVOL(:)) max(AV_TGTVOL(:))];
AV_REFSIZE = sizefull(AV_REFVOL,3);
AV_TGTSIZE = sizefull(AV_TGTVOL,3);

%%%%%%%%%%%%%%%%%%%%% final checks

if ~isempty(tr)
  if isfield(tr,'extra')  % DEPRECATED
    if ~allzero(tr.extra.matrixsize - AV_TGTSIZE)  % HMM HACKY
      fprintf(1,'warning: <tr>.extra.matrixsize does not match the target matrix size.\n');
    end
    if ~allzero(tr.extra.matrixfov - AV_TGTSIZE.*AV_TGTLENGTHS)
      fprintf(1,'warning: <tr>.extra.matrixfov does not match the target matrix FOV.\n');
    end
  else
    if ~allzero(tr.matrixsize - AV_TGTSIZE)
      fprintf(1,'warning: <tr>.matrixsize does not match the target matrix size.\n');
    end
    if ~allzero(tr.matrixfov - AV_TGTSIZE.*AV_TGTLENGTHS)
      fprintf(1,'warning: <tr>.matrixfov does not match the target matrix FOV.\n');
    end
  end
end

%%%%%%%%%%%%%%%%%%%%% main stuff

% handle figure stuff
AV_FIGREF = figure('Visible','off');  % make sure invisible to begin with because the creation of the gui window causes things to be rendered prematurely i think
AV_FIGTGT = figure('Visible','off');
AV_FIGOLY = figure('Visible','off');
setfigurepos(AV_FIGREF,figrefpos);
setfigurepos(AV_FIGTGT,figtgtpos);
setfigurepos(AV_FIGOLY,figolypos);
set([AV_FIGREF AV_FIGTGT AV_FIGOLY],'DoubleBuffer','on');  % doublebuffer has no effect in opengl mode?
set([AV_FIGREF AV_FIGTGT AV_FIGOLY],'CloseRequestFcn','delete(gcf); alignvolumedata_quit(0);');
set([AV_FIGREF AV_FIGTGT AV_FIGOLY],'Pointer','custom');
set([AV_FIGREF AV_FIGTGT AV_FIGOLY],'PointerShapeCData',pointercrosssmall);
set([AV_FIGREF AV_FIGTGT AV_FIGOLY],'PointerShapeHotSpot',[5 5]);
set([AV_FIGREF AV_FIGTGT AV_FIGOLY],'MenuBar','none');
set(0,'CurrentFigure',AV_FIGREF);
[volref,ttlref] = alignvolumedata_initfigure(1);
set(0,'CurrentFigure',AV_FIGTGT);
[voltgt,ttltgt] = alignvolumedata_initfigure(2);
set(0,'CurrentFigure',AV_FIGOLY);
[vololy,ttloly] = alignvolumedata_initfigure(3);

% gui stuff
AV_GUI = alignvolumedata_gui(AV_FIGREF,AV_FIGTGT,AV_FIGOLY,volref,voltgt,vololy,ttlref,ttltgt,ttloly,tr);
setfigurepos(AV_GUI,guipos);
set(AV_GUI,'CloseRequestFcn', ...
    ['fprintf(''the alignvolumedata GUI has been closed. in case you forgot to export the transformation, here it is:\n''); ' ...
     'alignvolumedata_exporttransformation(2); delete(gcf); alignvolumedata_quit(0);']);

% force a redraw
handles = guidata(AV_GUI);
alignvolumedata_gui('redraw_Callback',handles.redraw,[],handles);

% ok, make visible
set([AV_FIGREF AV_FIGTGT AV_FIGOLY],'Visible','on');

% report finished
fprintf(1,'alignvolumedata executed successfully.\n');






% INTERNAL NOTES ONLY:

%   (2) if <tr> is supplied and lacks the 'extra' field, then 
%       we use it to seed the initial values in the GUI.  note 
%       that the 'matrixsize' and 'matrixfov' fields are ignored
%       since they are implicitly specified by <targetvolume> 
%       and <targetlengths>.  (however, if a mismatch is detected,
%       we issue a warning to the command window.)

% DEPRECATED
%   (3) if <tr> is supplied and has an 'extra' field, then 
%       this is a special case.  the interpretation is that there
%       are two successive transformations to perform to get from
%       slice space to coordinate space: first, do the transformation
%       specified by tr.extra, and then do the transformation
%       specified by tr (disregarding the 'extra' field).  (this
%       idea is evident upon inspection of slicestovolume.m.)
%       the transformation specified by tr.extra is the one 
%       controlled by the GUI, while the transformation specified
%       specifically by tr is handled "behind-the-scenes".
%       if tr.extra is [], the GUI is seeded with default values;
%       if tr.extra is not [], the GUI is seeded with the values
%       specified by tr.extra.  note that for tr.extra, the
%       'matrixsize' and 'matrixfov' fields are ignored
%       since they are implicitly specified by <targetvolume> 
%       and <targetlengths>.  (however, if a mismatch is detected,
%       we issue a warning to the command window.)  on the other
%       hand, note that for tr, the 'matrixsize' and 'matrixfov'
%       fields are essential, and must be correct.
%         the usefulness of the tr.extra feature is like this.
%       suppose you aligned slices to some volume A, 
%       obtaining some transformation X.  then you realize
%       you actually wanted to align the slices to
%       volume B which is just some rigid-body transformation
%       (possibly with flips) of volume A.  what you could do is the
%       following.  first, use alignvolumedata with volume B as the
%       reference volume and volume A as the target volume,
%       obtaining a transformation Y, making sure to set the
%       'matrixsize' and 'matrixfov' fields to correspond to
%       volume A.  then, construct a new transformation 
%       struct that is identical to Y but which has an 'extra' 
%       field that is identical to X.  then you can use
%       this new transformation struct when calling alignvolumedata
%       with volume B as the reference volume and your slices as the
%       target volume.  
