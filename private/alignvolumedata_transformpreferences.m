function prefs = alignvolumedata_transformpreferences(prefs)

% function prefs = alignvolumedata_transformpreferences(prefs)
%
% <prefs> is a prefs (or settings) struct.
%
% return <prefs> but with the fields that correspond to
% preferences transformed into the internal format.  any
% unexpected preference value triggers an error, so you
% can use me to verify preference values.

assert(ischar(prefs.referencecolor),'invalid <referencecolor> value');  % minimal check
assert(ischar(prefs.targetcolor),'invalid <targetcolor> value');  % minimal check
assert(ischar(prefs.overlaycolor),'invalid <overlaycolor> value');  % minimal check
assert(all(isint(prefs.checkersize)) && prefs.checkersize >= 1,'invalid <checkersize> value');
assert(isfinitenum(prefs.maxsingledim),'invalid <maxsingledim> value');
