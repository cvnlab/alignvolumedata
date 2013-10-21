function idx = permutation2idx(p,n)

% function idx = permutation2idx(p,n)
%
% <p> is a permutation
% <n> is the number of things being permuted
%
% return the corresponding index

switch n
case 3
  if isequal(p,[1 2 3])
    idx = 1;
  end
  if isequal(p,[1 3 2])
    idx = 2;
  end
  if isequal(p,[2 1 3])
    idx = 3;
  end
  if isequal(p,[2 3 1])
    idx = 4;
  end
  if isequal(p,[3 1 2])
    idx = 5;
  end
  if isequal(p,[3 2 1])
    idx = 6;
  end
otherwise
  error('unimplemented <n> value');
end
