function alignvolumedata_quit(wantreport)

% function alignvolumedata_quit
%
% this function is for internal use only.

% INTERNAL USE:
% cleans up program state and closes any
% existing gui window (but not render window).
% this function is useful for when you think the
% program state is stale or has been corrupted
% and you want to start with a clean slate or
% if you want to free memory.

% internal note:
% <wantreport> is a hidden parameter such that
%   <wantreport> is whether to report to the 
%   the command window.  if [] or not supplied,
%   default to 1.

if ~exist('wantreport','var') || isempty(wantreport)
  wantreport = 1;
end

alignvolumedata_closegui;
alignvolumedata_disablerender;

% make sure globals are cleared
clear global AV_REFVOL AV_REFLENGTHS AV_TGTVOL AV_TGTLENGTHS;
clear global AV_FIGREF AV_FIGTGT AV_FIGOLY AV_GUI;
clear global AV_REFRANGE AV_TGTRANGE;
clear global AV_REFSIZE AV_TGTSIZE;

% report
if wantreport
  fprintf(1,'alignvolumedata program state successfully cleared.\n');
end
