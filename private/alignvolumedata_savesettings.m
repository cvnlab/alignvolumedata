function alignvolumedata_savesettings(x)

% function alignvolumedata_savesettings(x)
%
% given settings in struct <x>, save settings via setpref.m.
% struct <x> need not be a complete set of settings.
% any existing settings are overwritten on a per-setting basis.

xorig = getpref('kendrick','alignvolumedata',struct([]));
x = mergestructs(x,xorig);
setpref('kendrick','alignvolumedata',x);


%OLD
%file = alignvolumedata_constants('settingsfile');
%savesettings(x,file);
