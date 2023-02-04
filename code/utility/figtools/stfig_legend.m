function [hobj,htext,hax] = stfig_legend(legh,fontsize)

%creates a pseudo-legend copy of legend for easier manipulation of graphics
%objects

drawnow;
legch = legh.EntryContainer.NodeChildren;
for i=1:length(legch)
    legobjs(i) = legch(i).Object;
    legstrs_objs{i} = legobjs(i).DisplayName;
end

%sort legend objects
legstrs = legh.String;
for i=1:length(legstrs)
    ix(i) = find(strcmp(legstrs_objs,legstrs{i}));
end
legobjs = legobjs(ix);

%axes for new legend
hax = axes('position',legh.Position);

nc = legh.NumColumns;
nr = ceil(length(legobjs)/nc);

xmarg = 0.025;
ymarg = 0.05;

x = linspace(xmarg,1,nc+1);
y = linspace(ymarg,1,nr+1);

[xx,yy] = meshgrid(x(1:end-1),y(1:end-1));

yy = flipud(yy);

cw = x(2)-x(1); %column width
rh = y(2)-y(1); %row height

co = 0.025*cw; %column offset of fill
fw = 0.1*cw; %width of fill

ro = 0.05*rh; %row offset of fill
rh = 0.75*rh; %row height of fill

set(hax,'YLim',[0 1],'XLim',[0 1]);
hold(hax,'on');

for i=1:length(legobjs)
    xv = [0 fw fw 0] + xx(i);
    yv = [0 0 rh rh] + yy(i);
    hobj(i) = fill(xv,yv,legobjs(i).FaceColor,'Facealpha',legobjs(i).FaceAlpha,...
        'EdgeColor',legobjs(i).EdgeColor); hold(hax,'on');
    htext(i) = text(max(xv)+co,mean(yv),legstrs{i},'fontsize',fontsize,'verti','mid');
end

set(hax,'XTick',[],'YTick',[],'Box','on');

% % iteratively resize until all text objects fit in axes
% xlim([0 1]);
% while 1
%     ext = vertcat(htext.Extent);
%     re = sum(ext(:,[1 3]),2);
%     if any(re>max(xlim))
%         xlim([-0.05*diff(xlim) max(re)+0.1]);
%     else
%         xlim([-0.05*diff(xlim) max(re)+0.1]);
%         break;
%     end
% end



delete(legh);

end