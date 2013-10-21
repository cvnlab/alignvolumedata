function f = pointercrosssmall

% function f = pointercrosssmall
%
% return a small cross pointer matrix.
% the hotspot is [5 5].

f = NaN*zeros(16,16);
f(5,1:9) = [2 1 1 1 1 1 1 1 2];
f(1:9,5) = [2 1 1 1 1 1 1 1 2]';
f(5,5) = 2;
