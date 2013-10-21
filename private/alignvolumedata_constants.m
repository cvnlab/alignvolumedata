function varargout = alignvolumedata_constants(varargin)

% function varargout = alignvolumedata_constants(varargin)
%
% <varargin> = cell vector of field names
%
% <varargout> = cell vector of corresponding values

for p=1:length(varargin)
  switch varargin{p}
% OBSOLETE
%   case 'settingsfile'
%     varargout{p} = '~/.surfpak/alignvolumedata_settings.mat';
  case 'figrefpos'
    varargout{p} = [.20 .05 .29 .415];
  case 'figtgtpos'
    varargout{p} = [.20 .05+.415+.04 .29 .415];
  case 'figolypos'
    varargout{p} = [.20+.29+.02 .05+.415+.04 .29 .415];
  case 'guipos'
    varargout{p} = [.20+.29+.02 .05+.015 .4 .4];
  case 'maxsingle'
    varargout{p} = 2048;
  end
end
