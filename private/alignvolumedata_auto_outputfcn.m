function stop = alignvolumedata_auto_outputfcn(params,optimValues,state,numiters,ix)

% function stop = alignvolumedata_auto_outputfcn(params,optimValues,state,numiters,ix)
%
% <params> is the current optimization parameter
% <optimValues>,<state> are optimization state stuff
% <numiters> is to refresh the GUI after every this number of iterations
% <ix> is indices of parameters that are being optimized
%
% in the 'iter' and 'done' states, update the GUI based on <params> and do some flashing.
%   then, if 'q' is pressed in the current figure, stop the optimization.
%   if 'p' is pressed, issue a keyboard command.

% define global
global AV_GUI;

% do it
switch state
case 'init'
case {'iter' 'done'}
  if mod(optimValues.iteration,numiters)==0 || isequal(state,'done')

    % handle new parameters
    handles = guidata(AV_GUI);
    cnt = 1;
    if ismember(1,ix)
      handles.txval = params(cnt); cnt = cnt + 1;
    end
    if ismember(2,ix)
      handles.tyval = params(cnt); cnt = cnt + 1;
    end
    if ismember(3,ix)
      handles.tzval = params(cnt); cnt = cnt + 1;
    end
    if ismember(4,ix)
      handles.rxval = params(cnt); cnt = cnt + 1;
    end
    if ismember(5,ix)
      handles.ryval = params(cnt); cnt = cnt + 1;
    end
    if ismember(6,ix)
      handles.rzval = params(cnt); cnt = cnt + 1;
    end
    if ismember(7,ix)
      handles.esxval = params(cnt); cnt = cnt + 1;
    end
    if ismember(8,ix)
      handles.esyval = params(cnt); cnt = cnt + 1;
    end
    if ismember(9,ix)
      handles.eszval = params(cnt); cnt = cnt + 1;
    end
    if ismember(10,ix)
      handles.ehxval = params(cnt); cnt = cnt + 1;
    end
    if ismember(11,ix)
      handles.ehyval = params(cnt); cnt = cnt + 1;
    end
    if ismember(12,ix)
      handles.ehzval = params(cnt); cnt = cnt + 1;
    end
    set(handles.tx,'String',num2str(handles.txval));
    set(handles.ty,'String',num2str(handles.tyval));
    set(handles.tz,'String',num2str(handles.tzval));
    set(handles.rx,'String',num2str(handles.rxval));
    set(handles.ry,'String',num2str(handles.ryval));
    set(handles.rz,'String',num2str(handles.rzval));
    set(handles.esx,'String',num2str(handles.esxval));
    set(handles.esy,'String',num2str(handles.esyval));
    set(handles.esz,'String',num2str(handles.eszval));
    set(handles.ehx,'String',num2str(handles.ehxval));
    set(handles.ehy,'String',num2str(handles.ehyval));
    set(handles.ehz,'String',num2str(handles.ehzval));
    alignvolumedata_gui('redraw_Callback',handles.redraw,[],handles,0);
    pause(.5);
    alignvolumedata_gui('overlaymain_Callback',handles.overlaymain,[],handles);
    pause(.15);
    alignvolumedata_gui('overlaymain_Callback',handles.overlaymain,[],handles);
    pause(.15);
    alignvolumedata_gui('overlaymain_Callback',handles.overlaymain,[],handles);
    pause(.15);
    alignvolumedata_gui('overlaymain_Callback',handles.overlaymain,[],handles);

    % handle keypresses
    if isequal(get(gcf,'CurrentCharacter'),'q')
      stop = 1;
      return;
    end
    if isequal(get(gcf,'CurrentCharacter'),'p')
      keyboard;
    end

  end
end

% return
stop = 0;
