function lims = getlimss(ax,xy)

if nargin==1
    xy = 'xy';
end

switch(xy)
    case 'y'
        lims = get(ax,'ylim');  
        if numel(ax)>1, lims = minmax(reshape(vertcat(lims{:}),1,[])); end
        lims = max(abs(lims))*[-1 1];
    case 'x'
        lims = get(ax,'xlim');  
        if numel(ax)>1, lims = minmax(reshape(vertcat(lims{:}),1,[])); end
        lims = max(abs(lims))*[-1 1];
    case 'xy'
        lims = get(ax,'xlim');  limsx = minmax(reshape(vertcat(lims{:}),1,[])); limsx = max(abs(limsx))*[-1 1];
        lims = get(ax,'ylim');  limsy = minmax(reshape(vertcat(lims{:}),1,[])); limsy = max(abs(limsy))*[-1 1];
        lims = [limsx; limsy];
end



end