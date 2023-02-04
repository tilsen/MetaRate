function [] = fig_method_scalogram_interpretation()

dbstop if error; close all
h = metarate_helpers;

load([h.data_dir 'metarate_partialcorr_scalographs.mat'],'T');
UTIL = T.Properties.UserData;
T = UTIL.index(T,'vowels','phones',0,'bytarget','centered',1);

H.sigma = h.sigma;
[Xr,Yr,Zr] = gen_scalogram(T,'rho','smoothing',false','interpolation',false); 
[X,Y,Z] = gen_scalogram(T,'rho','filter',H);

Zr = -Zr; Zr(Zr(:)==0) = nan;
Z = -Z;

rho_step = 0.05;
nancol = 0.85*[1 1 1];

SC.varlab = '\rho^{\prime}';
SC.rho_range = minmax(Z(:)');
SC.clims = [SC.rho_range] +[-.1 0];
SC.cmap = [nancol; viridis(numel(unique(Zr(:))))];
SC.cmap1 = [nancol; flipud(gray(500))]; SC.cmap1 = SC.cmap1(1:end-100,:);
SC.rho_levels = 0:rho_step:1;

%----slices
slice_props = {
    '(a)' 'constant scale'         'scale'    0.40;
    '(b)' 'constant center'        'center'   0.0;
    '(c)' 'constant right edge'    're'       0;
    '(d)' 'constant left edge'     'le'       0};

SL = cell2table(slice_props,'VariableNames',{'lab' 'name' 'input' 'val'});

colors = lines(4);
colors(3,:) = pastelize(colors(3,:),-0.15);
SL.color = colors;

for i=1:height(SL)
    [SL.x{i},SL.y{i},SL.z{i}] = slice_scalogram(X,Y,Z,SL.input{i},SL.val(i));
    [SL.xr{i},SL.yr{i},SL.zr{i}] = slice_scalogram(Xr,Yr,Zr,SL.input{i},SL.val(i));
end

%%
ax = stf([1 1 1 3 3 3; 2 2 2 4 4 4],[0.05 0.075 .035 0.065],[0.075 0.15]);


%----raw scalogram
axes(ax(1));
imagesc(Xr,Yr,Zr); hold on;
colormap(gca,SC.cmap);
set(gca,'Clim',SC.clims,'Ydir','normal');
cbh(1) = colorbar;

%----smoothed, interpolated scalogram
axes(ax(2));
imagesc(X,Y,Z); hold on;
colormap(gca,SC.cmap1);
set(gca,'Clim',SC.clims,'Ydir','normal');
cbh(2) = colorbar;

for i=1:height(SL)
    plot(SL.x{i},SL.y{i},'-','color',SL.color(i,:),'linew',2);

    switch(i)
        case {1,3}
            [x,ix] = min(SL.x{i});
            y = SL.y{i}(ix);
            ha = 'right';
            va = 'mid';
        case 4
            [y,ix] = max(SL.y{i});
            x = SL.x{i}(ix);
            ha = 'left';
            va = 'mid';      
        case 2
            [y,ix] = max(SL.y{i});
            x = SL.x{i}(ix);
            ha = 'left';
            va = 'top';                
    end
    
    text(x,y,SL.lab{i},'color',SL.color(i,:),...
        'fontweight','bold','fontsize',h.fs(2),'verti',va,'hori',ha);
end

[M,c] = contour(X,Y,Z, SC.rho_levels, 'color', 'g');
clabel(M,c,'fontsize',h.fs(end),'fontname','calibri','labelspacing',500);
C = contours_scalogram(M,c);

%----scalogram slices
axes(ax(3));
axsl = stfig_subaxpos(ax(3),[1 2],[0 0 0 0 0.025 0]);
axsl(2).Position(1)=axsl(2).Position(1)+0.035;

axes(axsl(1));
for i=2:4
    plot(SL.y{i},SL.z{i},'color',SL.color(i,:),'linew',2); hold on;
end

axes(axsl(2));
plot(SL.x{1},SL.z{1},'color',SL.color(1,:),'linew',2); hold on;

axis(axsl,'tight');
ylims = getlims(axsl,'y');
ylim(axsl,ylims);
axrescalex(0.05,axsl);
axrescaley(0.05,axsl);

%----windows
axes(ax(4));
axw = stfig_subaxpos(ax(4),[1 2],[0 0 0 0 0.025 0]);
axw(2).Position(1)=axw(2).Position(1)+0.035;

for i=1:height(SL)
    switch(i)
        case 1
            axes(axw(2));
        otherwise
            axes(axw(1));
    end
    x = SL.xr{i};
    y = SL.yr{i};
    for j=1:length(x)
        xx = x(j)+y(j)*[-1 1]/2;
        switch(i)
            case 1
                yy = y(j)*[1 1]-(j-length(x)/2)*0.001;
            otherwise
                yy = y(j)*[1 1]-i*0.005;
        end
        ph(i,j) = plot(xx,yy,'color',SL.color(i,:),'linew',2); hold on;
        plot(mean(xx),mean(yy),'.','color',SL.color(i,:),'markersize',20); hold on;
    end
end
axrescalex(0.05,axw);
axrescaley(0.05,axw);

%%
set(ax,'fontsize',h.fs(end));

set(ax(1:2),'Ydir','normal','xgrid','on','ygrid','on');

xlabel(ax,'window center (s)');
ylabel(ax,'window scale (s)');

set(axsl,'box','off','fontsize',h.fs(end),'xgrid','on','ygrid','on');
xlabel(axsl(1),'window scale (s)','fontsize',h.fs(3)); 
ylabel(axsl,'\it{r}^{\prime}  ','fontsize',h.fs(2),'rotation',0,'hori','right');
xlabel(axsl(2),'window center (s)','fontsize',h.fs(3)); 

set(axw,'XGrid','on','YGrid','on','fontsize',h.fs(end));

set(axw(2),'YTick',[]);
ylabel(axw(1),'window scale (s)','fontsize',h.fs(3)); 
ylabel(axw(2),'scale = 0.400 s','fontsize',h.fs(3));
xlabel(axw,'window center (s)','fontsize',h.fs(3)); 

SL.legstr = cellfun(@(c,d){[c ' ' d]},SL.lab,SL.name);

legh = legend(ph(:,2),SL.legstr,'fontsize',h.fs(end),'location','northeast');
shiftposy(legh,0.30);
shiftposx(legh,-0.025);

panlabs = {'raw scalogram','smoothed, interpolated scalogram','slices','slice windows'};
stfig_panlab(ax,panlabs,'xoff',0,'yoff',0.02,'hori','left','fontweight','normal');

panlets = arrayfun(@(c){['(' char(c+64) ')']},1:length(ax));
stfig_panlab(ax,panlets,'xoff',-0.01,'yoff',0.02,'hori','right','fontweight','bold');

set(ax(3:4),'Visible','off');

%%

h.printfig(mfilename);

end

