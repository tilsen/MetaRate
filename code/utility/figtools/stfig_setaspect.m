function [varargout] = stfig_setaspect(varargin)

%assumes landscape
%ToDo parameterize landscape vs. portrait mode

varargout{1} = [];

if nargin==0
    figh=gcf;
    target_aspect =  10.5/8; %inches
    
elseif nargin==1
    if isscalar(varargin{1})
        figh = gcf;
        target_aspect =  varargin{1}; %inches              
    elseif ishandle(varargin{1})
        figh = varargin{1};
        target_aspect =  10.5/8; %inches
    elseif ischar(varargin{1})
        if strcmp(varargin{1},'query')
            monpos = get(0,'MonitorPositions');
            varargout{1} = monpos(1,3)/monpos(1,4);
            return;
        else
            figh = gcf;
            set(figh,'units','inches');
            newpos = figh.OuterPosition;
            varargout{1} = newpos(3)/newpos(4);
            set(figh,'units','normalized');
            return;
        end
    end
    
elseif nargin==2
    if ishandle(varargin{1})
        figh = varargin{1};
        target_aspect =  varargin{2}; %inches
    else
        figh = varargin{2};
        target_aspect =  varargin{1}; %inches       
    end    
end


% rh = get(figh,'parent');
% set(rh,'units','inches');
% screen_aspect = rh.ScreenSize(3)/rh.ScreenSize(4);

set(figh,'units','inches');
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

