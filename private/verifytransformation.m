function verifytransformation(tr)

% function verifytransformation(tr)
%
% <tr> is of the format described in maketransformation.m.
%   can be [].
%
% verify the sanity of <tr>.

if ~isempty(tr)
  assert(isrowvector(tr.flip) & length(tr.flip)==3 & all(tr.flip==0 | tr.flip==1),'invalid <flip> value');
  assert(isrowvector(tr.reorder) & length(tr.reorder)==3 & isequal(sort(tr.reorder),[1 2 3]),'invalid <reorder> value');
  assert(isrowvector(tr.trans) & length(tr.trans)==3 & all(isfinitenum(tr.trans)),'invalid <trans> value');
  assert(isrowvector(tr.rotorder) & length(tr.rotorder)==3 & isequal(sort(tr.rotorder),[1 2 3]),'invalid <rotorder> value');
  assert(isrowvector(tr.rot) & length(tr.rot)==3 & all(isfinitenum(tr.rot)),'invalid <rot> value');
  assert(isrowvector(tr.matrixsize) & length(tr.matrixsize)==3 & all(isint(tr.matrixsize)) & all(tr.matrixsize >= 1),'invalid <matrixsize> value');
  assert(isrowvector(tr.matrixfov) & length(tr.matrixfov)==3 & all(isfinitenum(tr.matrixfov) & all(tr.matrixfov > 0)),'invalid <matrixfov> value');
  assert(isrowvector(tr.extrascale) & length(tr.extrascale)==3 & all(isfinitenum(tr.extrascale)),'invalid <extrascale> value');  %  & all(tr.extrascale > 0)
  assert(isrowvector(tr.extratrans) & length(tr.extratrans)==3 & all(isfinitenum(tr.extratrans)),'invalid <extratrans> value');
  assert(isrowvector(tr.extrashear) & length(tr.extrashear)==3 & all(isfinitenum(tr.extrashear)),'invalid <extrashear> value');
  assert(isrowvector(tr.extrashearflag) & length(tr.extrashearflag)==3 & all(tr.extrashearflag==0 | tr.extrashearflag==1),'invalid <extrashearflag> value');
  if isfield(tr,'extra')  % DEPRECATED
    assert(~isfield(tr.extra,'extra'));
    verifytransformation(tr.extra);
  end
end
