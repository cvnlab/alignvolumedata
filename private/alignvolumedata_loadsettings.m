function f = alignvolumedata_loadsettings(x,usedefaults)

% function f = alignvolumedata_loadsettings(x,usedefaults)
%
% <x> is a cell vector of strings
% <usedefaults> is whether to completely ignore
%   existing values for the fields named in <x>.
%
% return a struct with the settings.

% define the default
def = struct('referencecolor','gray', ...
             'targetcolor','gray', ...
             'overlaycolor','hot', ...
             'checkersize',30, ...
             'maxsingledim',2048);

% load in if possible
f = getpref('kendrick','alignvolumedata',def);

% override certain ones
if usedefaults
  for p=1:length(x)
    f.(x{p}) = def.(x{p});
  end
end



% OLD
% inits = {'referencecolor'  'gray';
%          'targetcolor'     'gray';
%          'overlaycolor'    'hot';
%          'checkersize'     30;
%          'maxsingledim'    2048};
% file = alignvolumedata_constants('settingsfile');
% f = loadsettings(x,usedefaults,inits,file);
