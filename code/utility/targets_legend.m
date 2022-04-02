function [hh] = targets_legend(D,ax,varargin)

p = inputParser;

def_fontsize = 16;
def_numcols = 2;
def_layout = nan;

addRequired(p,'D');
addRequired(p,'ax');
addParameter(p,'fontsize',def_fontsize);
addParameter(p,'numcols',def_numcols);
addParameter(p,'layout',def_layout);

parse(p,D,ax,varargin{:});

r = p.Results;

[symb,ia] = unique(D.symb);
descriptions = D.description(ia);
DE.symb = symb;
DE.descriptions = descriptions;
DE = struct2table(DE);
DE = sortrows(DE,'descriptions');
DE.id = (1:height(DE))';

if isnan(r.layout)
    DE = DE([2 8 10 9 7 1 4 6 3 5],:);
end

nc = r.numcols;
nr = ceil(height(DE)/nc);
c=1;
for a=1:nc
    for b=1:nr
        hh.thx(c) = text(a,1-b,DE.symb{c},'fontsize',r.fontsize,'hori','right','parent',r.ax); hold(ax,'on');
        hh.thd(c) = text(a+0.05,1-b,DE.descriptions{c},'fontsize',r.fontsize,'parent',r.ax);
        c=c+1;
        if c>height(DE), break; end
    end
    if c>height(DE), break; end
end
set(ax,'YDir','normal','XTick',[],'YTick',[],'Box','on','Ycolor','k');

for i=1:3
    ext = vertcat(hh.thx.Extent);
    ext = [ext; vertcat(hh.thd.Extent)];
    xlim(ax,[min(ext(:,1)) max(sum(ext(:,[1 3]),2))]);
    ylim(ax,[min(ext(:,2)) max(sum(ext(:,[2 4]),2))]);
end
axrescalex([-0.02 0.1],ax);

end