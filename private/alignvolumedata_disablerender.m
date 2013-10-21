function alignvolumedata_disablerender

% function alignvolumedata_disablerender
%
% safely make render windows impotent.

global AV_FIGREF AV_FIGTGT AV_FIGOLY;
for p=[AV_FIGREF AV_FIGTGT AV_FIGOLY]
  if ishandle(p)
    set(p,'CloseRequestFcn','closereq');
  end
end
