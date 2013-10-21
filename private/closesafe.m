function closesafe(h)

% function closesafe(h)
%
% h is maybe a handle to a figure window.
%
% close h if possible

if ~isempty(h) && ishandle(h) && isequal(get(h,'Type'),'figure')
  close(h);
end
