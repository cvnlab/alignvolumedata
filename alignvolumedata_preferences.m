function f = alignvolumedata_preferences(prefs)

% function f = alignvolumedata_preferences(prefs)
%
% f = alignvolumedata_preferences
%   returns the existing saved preferences in struct f.
%
% f = alignvolumedata_preferences('default')
%   returns the default preferences.
%
% alignvolumedata_preferences(prefs)
%   given struct <prefs>, save the preferences.
%   <prefs> needs to to have all fields defined
%   (i.e. cannot be an incomplete struct).
%
%   here are the fields:
%
%   <referencecolor> determines the colormap setting for
%   the reference volume.
%     <user-defined colormap> | 'autumn' | 'bone' | 'colorcube' |
%     'cool' | 'copper' | 'flag' | 'gray' (default) | 'hot' |
%     'hsv' | 'jet' | 'lines' | 'pink' | 'prism' | 'spring' |
%     'summer' | 'vga' | 'white' | 'winter'
%
%   <targetcolor> determines the colormap setting for
%   the target volume.
%     <user-defined colormap> | 'autumn' | 'bone' | 'colorcube' |
%     'cool' | 'copper' | 'flag' | 'gray' (default) | 'hot' |
%     'hsv' | 'jet' | 'lines' | 'pink' | 'prism' | 'spring' |
%     'summer' | 'vga' | 'white' | 'winter'
%
%   <overlaycolor> determines the colormap setting for
%   the overlay volume in the 'subtract' mode.  in the other
%   overlay modes, the colormap used is identical to either
%   the reference or target colormap.
%     <user-defined colormap> | 'autumn' | 'bone' | 'colorcube' |
%     'cool' | 'copper' | 'flag' | 'gray' | 'hot' (default) |
%     'hsv' | 'jet' | 'lines' | 'pink' | 'prism' | 'spring' |
%     'summer' | 'vga' | 'white' | 'winter'
%
%   <checkersize> is the number of pixels on the side for
%   a single check in the 'checker' overlay mode.  default: 30.
%
%   <maxsingledim> is the maximum allowable number of pixels
%   in any single dimension of the reference or target
%   volumes; any more than this we require confirmation from
%   the user.  default: 2048.
%
%   note that preference changes take effect only on the next 
%   call to alignvolumedata.
%
% this function can be called at any time.

plist = {'referencecolor' 'targetcolor' 'overlaycolor' 'checkersize' 'maxsingledim'};

if exist('prefs','var') && isequal(prefs,'default')
  f = alignvolumedata_loadsettings(plist,1);
end

if ~exist('prefs','var')
  f = alignvolumedata_loadsettings(plist,0);
end

if exist('prefs','var') && ~isequal(prefs,'default')
  % verify but don't transform
  try
    alignvolumedata_transformpreferences(prefs);
  catch
    fprintf(1,['error: ',chopline(lasterr),'\n']);
    return;
  end
  % save them
  for p=1:length(plist)
    settings.(plist{p}) = prefs.(plist{p});
  end
  alignvolumedata_savesettings(settings);
  % report
  fprintf(1,'preferences have been saved and will take effect on the next call to alignvolumedata.\n');
end
