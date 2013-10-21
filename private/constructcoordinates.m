function XYZ = constructcoordinates(x,y,z)

% function XYZ = constructcoordinates(x,y,z)
%
% <x>,<y>,<z> are matrices of x-, y-, and z-coordinates
%
% return the XYZ coordinate format.

XYZ = [x(:)'; y(:)'; z(:)'; ones(1,numel(x))];
