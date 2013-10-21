function varargout = separate(m)

% function varargout = separate(m)
%
% <m> is a matrix
%
% assign elements of m(:) to individual output variables.
% example:
%   [a,b,c] = separate([1 2 3]);
%
% note that you can have fewer but not more variables
% on the left-hand side than there are elements in <m>.

varargout = num2cell(m(:));
