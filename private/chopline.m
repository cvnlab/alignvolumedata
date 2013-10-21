function x = chopline(x)

% function x = chopline(x)
% 
% <x> is a string.
%
% remove all characters up to and including the first \n.
% if \n is not found, return <x> as is.

pos = findstr(sprintf('\n'),x);
if ~isempty(pos)
  x(1:pos) = '';
end
