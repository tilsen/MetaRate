function [h] = stf_matrix(M,varargin)

dbstop if error;
p = inputParser;

def_parent = nan;
def_colormap = viridis(1000);
def_textvalues = true;
def_formatstr = '%1.2f';
def_fontsize = get(0,'defaulttextfontSize');
def_fontcolor = [1 1 1; 0 0 0];
def_fontweight = 'normal';
def_colorbar = false;
def_gridlines = true;
def_gridline_color = [0 0 0];
def_ydir = 'reverse';
def_nan_color = [.5 .5 .5];
def_hsp_thresh = 127.5;
def_x = nan;
def_y = nan;

addRequired(p,'M',@(x)ismatrix(x));
addParameter(p,'parent',def_parent);
addParameter(p,'x',def_x);
addParameter(p,'y',def_y);
addParameter(p,'colormap',def_colormap);
addParameter(p,'textvalues',def_textvalues);
addParameter(p,'formatstr',def_formatstr);
addParameter(p,'fontsize',def_fontsize);
addParameter(p,'fontcolor',def_fontcolor);
addParameter(p,'fontweight',def_fontweight);
addParameter(p,'colorbar',def_colorbar);
addParameter(p,'gridlines',def_gridlines);
addParameter(p,'gridline_color',def_gridline_color);
addParameter(p,'ydir',def_ydir);
addParameter(p,'nan_color',def_nan_color);
addParameter(p,'hsp_thresh',def_hsp_thresh);

parse(p,M,varargin{:});

r = p.Results;

if ~ishandle(r.parent)
    ax = gca;
else
    ax = r.parent;
end

if isnan(r.x)
    r.x = 1:size(M,2);
end
if isnan(r.y)
    r.y = 1:size(M,1);
end

%plot 
h.imh = imagesc(r.x,r.y,M,'parent',ax); 
hold(ax,'on');

colormap(ax,r.colormap);

if any(isnan(M),"all")
    set(h.imh,'AlphaData',~isnan(M));
    set(ax,'Color',r.nan_color);
end

set(ax,'YDir',r.ydir);

if r.colorbar
    h.cbh = colorbar(ax);
    h.cbh.Position(1) = sum(ax.Position([1 3]))+0.025;
    %h.cbh.Position(3) = 0.05;
end

if r.gridlines

    xvals = linspace(min(xlim),max(xlim),size(M,2)+1);
    yvals = linspace(min(ylim),max(ylim),size(M,1)+1);

    h.gridh = stfig_gridlines('xy', ...
        'color',r.gridline_color,'xvals',xvals,'yvals',yvals);
end

if r.textvalues
    
    xpnts = h.imh.XData;
    ypnts = h.imh.YData;

    h.vh = matrix_text(M, ...
        'formatstr',r.formatstr, ...
        'fontsize', r.fontsize, ...
        'fontcolor',r.fontcolor(1,:), ...
        'fontweight',r.fontweight, ...
        'parent',r.parent, ...
        'x',xpnts,...
        'y',ypnts);

    text_color_threshold(h.imh,h.vh, ...
        'colors',r.fontcolor, ...
        'thresholds',r.hsp_thresh);
end

h.ax = ax;

end



