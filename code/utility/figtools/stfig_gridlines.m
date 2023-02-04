function [h] = stfig_gridlines(xy,varargin)

p = inputParser;

def_xy = 'xy';
def_parent = gca;
def_color = [0 0 0];
def_linewidth = 1;
def_xvals = nan;
def_yvals = nan;

addOptional(p,'xy',def_xy,@(x)ischar(x));
addParameter(p,'parent',def_parent);
addParameter(p,'color',def_color);
addParameter(p,'linewidth',def_linewidth);
addParameter(p,'xvals',def_xvals);
addParameter(p,'yvals',def_yvals);

parse(p,xy,varargin{:});

axh = p.Results.parent;

X = p.Results.xvals(:)';
if isnan(X)
    X = min(axh.XLim):max(axh.XLim);  
    Xr = axh.XLim;
else
    Xr = minmax(X);
end

nX = length(X);

Y = p.Results.yvals(:)';
if isnan(Y)
    Y = min(axh.YLim):max(axh.YLim);
    Yr = axh.YLim;
else
    Yr = minmax(Y);
end
nY = length(Y);

h = {};
if contains(p.Results.xy,'x')
   h{end+1} = line( repmat(X,2,1), repmat(Yr',1,nX),...
       'color',p.Results.color,'parent',axh,'linew',p.Results.linewidth);
end
if contains(p.Results.xy,'y')
   h{end+1} = line( repmat(Xr',1,nY), repmat(Y,2,1),...
       'color',p.Results.color,'parent',axh,'linew',p.Results.linewidth);
end



end