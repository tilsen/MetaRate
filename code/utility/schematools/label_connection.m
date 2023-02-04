function [th] = label_connection(ch,loc,str,varargin)

defaultstr = '';
defaultloc = 0.5;
defaultva = 'mid';
defaultha = 'left';
defaultrot = 0;
defaultfs = 20;
defaultxoff = 0.01*diff(xlim);
defaultinterp = 'tex';

p = inputParser();

addRequired(p,'ch');
addOptional(p,'loc',defaultloc,@(x)isnumeric(x) & numel(x)<=2);
addOptional(p,'str',defaultstr,@(x)ischar(x) | iscell(x));
addParameter(p,'verticalalignment',defaultva);
addParameter(p,'horizontalalignment',defaultha);
addParameter(p,'rotation',defaultrot);
addParameter(p,'fontsize',defaultfs);
addParameter(p,'interpreter',defaultinterp);
addParameter(p,'xoffset',defaultxoff);

parse(p,ch,loc,str,varargin{:});

xdata = get(ch,'XData');
ydata = get(ch,'YData');

xd = minmax(xdata(:)');
yd = minmax(ydata(:)');

switch(numel(loc))
    case 1
        loc = loc([1 1]);
end

xx = linspace(xd(1),xd(2),1000);
yy = linspace(yd(1),yd(2),1000);

x = xx(round(loc(1)*1000));
y = yy(round(loc(2)*1000));

switch(p.Results.horizontalalignment)
    case 'left'
        x=x+p.Results.xoffset;
    case 'right'
        x=x-p.Results.xoffset;
end


th = text(x,y,p.Results.str,...
    'hori',p.Results.horizontalalignment,...
    'verti',p.Results.verticalalignment,'fontsize',p.Results.fontsize,...
    'rotation',p.Results.rotation,'interpreter',p.Results.interpreter,'parent',get(ch,'parent'));


end

