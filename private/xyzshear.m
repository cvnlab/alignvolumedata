function f = xyzshear(v,flag)

% function f = xyzshear(v,flag)
%
% return the shear matrix for <v>, which is [xy yz xz].
% <flag> is 3-element vector of 0/1, where 0 indicates the
% default shear direction, and 1 indicates the alternate
% shear direction.
%
% for example, <flag>==[1 0 1] means [yx yz zx].
% and the new coordinates are:
%   [v(1)*x+y y+v(2)*z v(3)*x+z]

f = eye(4);

if flag(1)
  f(2,1) = v(1);
else
  f(1,2) = v(1);
end

if flag(2)
  f(3,2) = v(2);
else
  f(2,3) = v(2);
end

if flag(3)
  f(3,1) = v(3);
else
  f(1,3) = v(3);
end
