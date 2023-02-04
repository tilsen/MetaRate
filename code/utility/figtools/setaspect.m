function [varargout] = setaspect(varargin)

dbstop if error;
p = inputParser;

default_figh = nan;
default_monitornum = 1;

monpos = get(0,'MonitorPositions');
maxasp = @()monpos(1,3)/monpos(1,4);
default_aspect = inf;

addOptional(p,'target_aspect',default_aspect,@(x)isnumeric(x));
addOptional(p,'figh',default_figh,@(x)ishandle(x));
addOptional(p,'monitornum',default_monitornum,@(x)isnumeric(x));
varargout{1} = [];

parse(p,varargin{:});

figh = p.Results.figh;
if ~ishandle(figh)
    figh = gcf;
end

target_aspect = p.Results.target_aspect;
if isinf(target_aspect)
    %target_aspect =  maxasp();
    set(gcf,'WindowState','maximized');
    return;
end

set(figh,'units','inches');
set(gcf,'WindowState','maximized'); drawnow;

newpos = figh.OuterPosition;
curr_aspect = newpos(3)/newpos(4);

adjfac = target_aspect/curr_aspect;

if curr_aspect > target_aspect %too wide, reduce width
    newpos(3) = newpos(3)*adjfac;
elseif curr_aspect < target_aspect %reduce height
    newpos(4) = newpos(4)/adjfac;
end

set(figh,'outerposition',newpos); drawnow;
set(figh,'units','normalized');

end

