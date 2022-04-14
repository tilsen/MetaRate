function [hh] = plot_scalographs(SC,ax,h,colorbars)

% plotting

if nargin==1
    ax = gca;
    h.fs = [16 12 8];
    colorbars = false(1,length(SC));
elseif nargin==2
    h.fs = [16 12 8];
    colorbars = false(1,length(SC));
elseif nargin==3
    colorbars = false(1,length(SC));
end

if ismatrix(ax)
    axix = reshape([SC.ax_ix],size(ax,1),[])';
    axix = [axix(:)];
    for i=1:length(SC)
        SC(i).ax_ix = axix(i);
    end
end

cboff = 0.035;
axbak = stbgax;
hh.ax = ax;

for i=1:length(SC)
    set(gcf,'currentaxes',ax(SC(i).ax_ix));
    
    X = SC(i).XX;
    Y = SC(i).YY;
    Z = SC(i).ZZ;
    
    hh.imh(i) = imagesc(X,Y,Z); hold on;
    set(gca,'Clim',SC(i).clims);
    colormap(gca,SC(i).cmap);    
    [M,c] = contour(X,Y,Z, SC(i).rho_levels, 'color', 'k');
    clabel(M,c,'fontsize',h.fs(end),'fontname','calibri','labelspacing',500);
    
    hh.th(i) = text(min(xlim)+0.01*diff(xlim),max(ylim),SC(i).panlab,...
        'verti','bot','fontsize',h.fs(2),'interp','tex');
    
    [xp,yp,~] = slice_scalogram(X,Y,Z,'re',0); 
    if ~isempty(xp), hh.slc_re(i) = plot(xp,yp,'k--'); end
    [xp,yp,~] = slice_scalogram(X,Y,Z,'le',0); 
    if ~isempty(xp), hh.slc_le(i) = plot(xp,yp,'k--'); end
    
    if colorbars(i)
        cbh = colorbar;
        cbh.Position(1) = cbh.Position(1)+cboff;
        pos = cbh.Position;
        hh.cb_th(i) = text(pos(1)+pos(3)/2,sum(pos([2 4])),SC(i).varlab,'FontSize',h.fs(2),...
            'Verti','bot','hori','center','parent',axbak);
        
        hh.cbh(i) = cbh;
    end
    
end

%%
dxtick = 0.2;
set(ax,'YDir','normal','fontsize',h.fs(end),'TickDir','out','ticklen',0.003*[1 1],...
    'box','off','XGrid','on','YGrid','on','xtick',[-2:dxtick:2]);

set(ax(:,2:end),'YTickLabel',[]);
set(ax(1:end-1,:),'XTickLabel',[]);

xlabel(ax(end,:),'window center (s)','fontsize',h.fs(3));
ylabel(ax(:,1),'window scale (s)','fontsize',h.fs(3));


end