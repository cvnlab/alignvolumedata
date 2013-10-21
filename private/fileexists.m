function f = fileexists(x)

% function f = fileexists(x)
%
% <x> is a string
% 
% return whether <x> refers to an actual file or directory that exists.
% (wildcard matches don't count.)

% the first check allows weird cases of a file being somewhere on the MATLAB path.
% the second check ensures that these weird cases are ignored.  (we can't use
% just the second check since it allows wildcards cases to come through.)

%fprintf('fileexists: %s\n',x);
f = exist(x,'file') && fileattrib(x);
