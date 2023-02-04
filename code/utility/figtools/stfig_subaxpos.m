function [axh] = stfig_subaxpos(ax,axn,margins)

%ax: axes handle or array of axes handles
%axn: new layout spec or cell array of new layout specs
%margins: new margins (relative to parent) or cell array of new margins

if numel(ax)>1
    ax = ax(:);
    if ~iscell(axn)
        axn = repmat({axn},1,length(ax));
    end
    if ~iscell(margins)
        margins = repmat({margins},1,length(ax));
    end    
    
    for i=1:length(ax)
        axh{i,1} = stfig_subaxpos(ax(i),axn{i},margins{i});
    end
    return
end

pos = ax.Position;
pos_l = pos(1);
pos_r = pos(1)+pos(3);
pos_b = pos(2);
pos_t = pos(2)+pos(4);

if all(size(axn)==[1 2]) %convert to grid
    nr = axn(1);
    nc = axn(2);
    axn = reshape((1:(nr*nc)),nc,nr)';
end

if nargin<3, margins = [.01 .01 .01 .01 .01 .01]; end %default margins

imarg = margins(5:6);
xmarg = margins([1 3]);
ymarg = margins([2 4]);

axn = flipud(axn);
nr = size(axn,1);
nc = size(axn,2);
% arng = pos(3) - (sum(xmarg) + nc*imarg(1)); %?? 
% brng = pos(4) - (sum(ymarg) + nr*imarg(2));
% arng = pos(3) - (sum(xmarg)) + imarg(1); %?? 
% brng = pos(4) - (sum(ymarg)) + imarg(2);

% %convert to offsets
% w = arng/nc;
% h = brng/nr;
% 
% xoff = (pos_l+xmarg(1)):w:(pos_r-xmarg(2));
% yoff = (pos_b+ymarg(1)):h:(pos_t-ymarg(2));

% %-----05.2019: corrections
% if length(xoff)<size(axn,2)
%    xoff = linspace(pos_l+xmarg(1),(pos_r-xmarg(2)),size(axn,2)); w = mean(diff(xoff));
% end
% if length(yoff)<size(axn,1)
%    yoff = linspace(pos_b+ymarg(1),(post_t-ymarg(2)),size(axn,1)); h = mean(diff(yoff));
% end
% %---------
%-----11.2020: corrections

xoff = linspace(pos_l+xmarg(1),(pos_r-xmarg(2)),size(axn,2)+1); w = mean(diff(xoff));
yoff = linspace(pos_b+ymarg(1),(pos_t-ymarg(2)),size(axn,1)+1); h = mean(diff(yoff));

%----------
nax = length(unique(axn(~isnan(axn(:)))));
axposc = cell(1,nax);
for y=1:nr
    for x=1:nc
        if isnan(axn(y,x)), continue; end
        axposc{axn(y,x)} = [axposc{axn(y,x)}; xoff(x) yoff(y) xoff(x)+(w-imarg(1)) yoff(y)+(h-imarg(2))];
    end
end

for j=1:length(axposc)
    axpos(j,:) = [min(axposc{j}(:,1)) min(axposc{j}(:,2)) max(axposc{j}(:,3)) max(axposc{j}(:,4))]; %#ok<AGROW>
    
end
axpos(:,3:4) = axpos(:,3:4)-axpos(:,1:2);

varargout{1} = axpos;
for i=1:size(axpos,1)
    axh(i) = axes('position',axpos(i,:)); %#ok<AGROW>
end

end