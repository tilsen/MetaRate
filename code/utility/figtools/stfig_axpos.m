function [axh,varargout] = stfig_axpos(axn,margins)
% ST_axpos  generate axes, using normalized figure coordinates
%
% axh = ST_axpos([rows, cols]) returns handles of axes in a rows x cols grid
%
% axh = ST_axpos(grid) returns handles of axes in an arbitrary rectangular grid
%         e.g. [1 1 1; 2 3 3] - indices must increase from 1:N
%
% axh = ST_axpos(grid,margins) controls external and internal margins
%         e.g. margins = [left bottom right top] = [.05 .05 .01 .01]
%          or margins = [left bottom right top hor-internal ver-internal] = [.05 .05 .01 .01 .02 .05]

if nargin<2, margins = [.08 .08 .01 .02 .005 .005]; end %default margins
if length(margins)~=6
    if length(margins)==4
        margins(5:6) = [0.005 0.005];
    else
        fprintf('error: must specify 4 or 6 margin values\n'); return;
    end
end

imarg = margins(5:6);
xmarg = margins([1 3]);
ymarg = margins([2 4]);

%%
if(all(size(axn)==[1 2]))  %convert [rows, cols] to grid specification
    
    nr = axn(1);
    nc = axn(2);
    axn = reshape((1:(nr*nc)),nc,nr)';   
end

%%

axn = flipud(axn);
nr = size(axn,1);
nc = size(axn,2);
arng = 1 - sum(xmarg) + imarg(1);
brng = 1 - sum(ymarg) + imarg(2);

%convert to offsets
w = arng/nc;
h = brng/nr;

xoff = xmarg(1):w:(1-xmarg(2));
yoff = ymarg(1):h:(1-ymarg(2));

%-----05.2019: corrections
if length(xoff)<size(axn,2)
   xoff = linspace(xmarg(1),(1-xmarg(2)),size(axn,2)); w = mean(diff(xoff));
end
if length(yoff)<size(axn,1)
   yoff = linspace(ymarg(1),(1-ymarg(2)),size(axn,1)); h = mean(diff(yoff));
end
%---------

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

set(axh,'ActivePositionProperty','position');

end