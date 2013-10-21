function p = idx2permutation(idx,n)

% function p = idx2permutation(idx,n)
%
% <idx> is the index (integer >= 1)
% <n> is the number of things being permuted
%
% return the corresponding permutation

switch n
case 3
  switch idx
  case 1
    p = [1 2 3];
  case 2
    p = [1 3 2];
  case 3
    p = [2 1 3];
  case 4
    p = [2 3 1];
  case 5
    p = [3 1 2];
  case 6
    p = [3 2 1];
  end
otherwise
  error('unimplemented <n> value');
end
