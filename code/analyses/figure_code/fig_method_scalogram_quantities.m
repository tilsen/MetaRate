function [] = fig_scalogram_quantities()

dbstop if error; close all
h = metarate_helpers;

load([h.data_dir 'metarate_partialcorr_scalographs.mat'],'T');
UTIL = T.Properties.UserData;
T = UTIL.index(T,'vowels','phones',0,1,'bytarget');

H.sigma = h.sigma;
[X,Y,Z] = gen_scalogram(T,'rho','filter',H);
Z = -Z;
Z(~isnan(Z))=1;

gaussfcn = @(x,mu,sigma)exp(-((x-mu).^2)/sigma);
gxy = gaussfcn(X,0,0.05)*gaussfcn(Y,0,0.15)';

Z = Z.*gxy';
Z = Z/max(Z(:));

nancol = 1*[1 1 1];

SC.varlab = '\rho^{\prime}';
SC.rho_range = minmax(Z(:)');
SC.clims = [SC.rho_range] +[-.1 0];
SC.cmap = [nancol; flipud(gray(100))]; 
SC.rho_levels = [];

%----slices
slice_props = {
    '(a)' 'constant scale'         'scale'    0.50;
    '(b)' 'constant center'        'center'   0.0;
    '(c)' 'constant right edge'    're'       0;
    '(d)' 'constant left edge'     'le'       0};

SL = cell2table(slice_props,'VariableNames',{'lab' 'name' 'input' 'val'});

colors = [lines(6); [0 0 0]];
colors(5:6,:) = colors([6 5],:);
SL.color = colors(1:height(slice_props),:);

for i=1:height(SL)
    [SL.x{i},SL.y{i},SL.z{i}] = slice_scalogram(X,Y,Z,SL.input{i},SL.val(i));
end

%%
ax = stf([1 1],[0.065 0.085 .30 0.065],[0 0]);

%----smoothed, interpolated scalogram
axes(ax(1));
imagesc(X,Y,Z); hold on;
colormap(gca,SC.cmap);
set(gca,'Clim',SC.clims,'Ydir','normal');

%------------
[xle,yle,~] = slice_scalogram(X,Y,Z,'le',-0.5);
[xre,yre,~] = slice_scalogram(X,Y,Z,'re',0.5);

xx = [SL.x{1}; xre; xle];
yy = [SL.y{1}; yre; yle];
zz = 0*ones(size(xx));

fprops = {'fontsize',h.fs(1),'fontweight','bold'};

fh(1) = fill3(xx,yy,zz,colors(end-2,:),'FaceAlpha',0.5,'edgeColor','none');
text(-0.1,0.6,'(e)',fprops{:},...
    'HorizontalAlignment','center','color',colors(end-2,:));

for i=1:height(SL)
    ph(i) = plot(SL.x{i},SL.y{i},'-','color',SL.color(i,:),'linew',3);

    switch(i)
        case 1
            [x,ix] = min(SL.x{i});
            y = SL.y{i}(ix);
            ha = 'left'; va = 'bot';
        case 3
            [x,ix] = min(SL.x{i});
            y = SL.y{i}(ix);
            ha = 'right'; va = 'top';            
        case 4
            [y,ix] = max(SL.y{i});
            x = SL.x{i}(ix);
            ha = 'left'; va = 'top';      
        case 2
            [y,ix] = max(SL.y{i});
            x = SL.x{i}(ix);
            ha = 'left'; va = 'top';                
    end
    
    text(x,y,SL.lab{i},'color',SL.color(i,:),fprops{:},...
        'verti',va,'hori',ha);
end

%---pre-/post-asymmetry
yo = 0.4; xo = 0.195;
plot([-xo xo],yo*[1 1],':','color',colors(end-1,:),'linew',3);
arrow([xo-0.02 yo],[xo yo],'length',8,'tipangle',30);
text(-xo, yo,'(f)',fprops{:},...
    'verti','bot','hori','left','color',colors(end-1,:));

% region of local timing interactions
[M,c] = contour(X,Y,Z, [0 0.25],'color', colors(end,:),'LineStyle',':','linew',2);
text(-0.2,0.2,'(g)',fprops{:},'color',colors(end,:),'verti','top','hori','left');


%%
set(ax,'fontsize',h.fs(end),'Ydir','normal','xgrid','on','ygrid','on','ticklen',0.003*[1 1]);

xlabel(ax,'window center (s)','FontSize',h.fs(2));
ylabel(ax,'window scale (s)','FontSize',h.fs(2));

qlabs = {...
    '(a)' 'constant scale = 0.5 s'
    '(b)' 'constant center = 0.0 s'
    '(c)' {'constant right edge = 0.0 s','(pre-target windows)'}
    '(d)' {'constant left edge = 0.0 s','(post-target windows)'}
    '(e)' {'{\it{R}}^{\prime} (= avg. {\it{r}}^{\prime}, scale > 0.500)'}
    '(f)' {'\Delta{\it{r}}^{\prime} = (c)-(d)', 'pre-/post-target asymmetry'}
    '(g)' {'local timing interactions'} };

xo = max(xlim)+0.025*diff(xlim);
xo1 = xo+0.05;
yo = linspace(max(ylim),0.15,size(qlabs,1));

for i=1:size(qlabs,1)
    text(xo,yo(i)+0.01,qlabs{i,1},'Color',colors(i,:),fprops{:},'verti','top');
    text(xo1,yo(i),qlabs{i,2},'verti','top','fontsize',h.fs(2));
end


set(ax,'Clipping','off');


%%

h.printfig(mfilename);

end

