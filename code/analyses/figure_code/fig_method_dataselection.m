function [] = fig_method_dataselection()

dbstop if error; close all;
h = metarate_helpers();

%scale_step = 0.05;
%center_step = 0.05;

%%
load([h.data_dir 'metarate_partialcorr_scalographs.mat'],'T');

Tu = T.Properties.UserData;

tt{1} = Tu.index(T,'vowels','phones',0,1,'beginanchored');
tt{2} = Tu.index(T,'vowels','phones',0,1,'bytarget');
tt{3} = Tu.index(T,'vowels','phones',0,1,'endanchored');

N = 115757;

for i=1:length(tt)
    prop_inc(i) = max(tt{i}.N_valid)/N;
    wins = tt{i}.center + tt{i}.sizes*[-1 1]/2;
    wrange(i,:) = minmax(wins(:)');
end

clear('T');

%%

orig = load([h.datasets_dir 'data_vowels.mat']);
D = orig.D;

N_targets = height(D);

fprintf('%i targets\n',height(D));
fprintf('proportion normal condition: %1.2f\n',sum(ismember(D.rate,{'N'}))/height(D));

%densities

XX = {D.dur,D.utt_t1-D.utt_t0,D.tmid-D.utt_t0,D.utt_t1-D.tmid};

%wintypes = {'bywindow','bytarget','endanchored','beginanchored'};

%generate scalogram for bywindow strategy
WIN = metarate_construct_windows('bywindow','scale_range',[0.05 3],'center_range',[-3 3]);
[D,WIN] = metarate_match_data_windows(orig.D,WIN);
WIN = count_vars_bywindow(D,WIN);
WIN.p_valid = WIN.N_valid/N_targets;
WIN.p_fast = 1-WIN.p_normal;
%SC(1) = prep_scalogram(WIN,'N_valid');
SC(1) = prep_scalogram(WIN,'p_valid');
SC(2) = prep_scalogram(WIN,'p_normal');

%other strategies get counts
wintypes = {'bytarget','endanchored','beginanchored'};
scale_maxima = 0.5:0.1:2;
c=1;
for i=1:length(wintypes)
    for j=1:length(scale_maxima)

        scale_range = [0.05 scale_maxima(j)];
        switch(wintypes{i})
            case 'bytarget'
                center_range = scale_range(2)*[-1 1]/2;
            case 'endanchored'
                center_range = scale_range(2)*[-1 0];
            case 'beginanchored'
                center_range = scale_range(2)*[0 1];
        end

        WIN = metarate_construct_windows(wintypes{i},...
            'scale_range',scale_range,...
            'center_range',center_range);
        [D,WIN] = metarate_match_data_windows(orig.D,WIN);
        WIN = count_vars_bywindow(D,WIN);
        WIN.p_valid = WIN.N_valid/N_targets;
        T(c).datasel = wintypes{i};
        T(c).scale_range = scale_range;
        T(c).center_range = center_range;
        T(c).N_valid = unique(WIN.N_valid);
        T(c).p_valid = unique(WIN.p_valid);
        T(c).p_normal = unique(WIN.p_normal);
        T(c).p_fast = 1-T(c).p_normal;
        c=c+1;
    end
end

T = struct2table(T);
T.N_valid = T.N_valid/1000;
    
%%
nancol = [.5 .5 .5];
%SC(1).cmap = [nancol; viridis(5000)];
%SC(1).Z = SC(1).Z/1000;
%SC(1).clims = [0 max(SC(1).Z(:))];
%SC(1).clevels = 10:20:round(SC(1).clims(2),-1);
SC(1).cmap = [nancol; stf_colormap(5000,[1 1 1],[.5 .5 1])];
SC(1).clims = [0 1];
SC(1).clevels = 0:0.1:1;
SC(1).clabcolor = 'k';

SC(2).cmap = [nancol; stf_colormap(5000,[1 .5 .5],[1 1 1])];
SC(2).clims = [0.5 1];
SC(2).clevels = 0.5:0.1:0.9;
SC(2).Z(isnan(SC(1).Z)) = nan;
SC(2).clabcolor = 'k';

%%
panlab = [7 7 7 5 5; 7 7 7 6 6; 1 1 1 3 3; 2 2 2 4 4];
panlab = [
    repmat(panlab(1,:),3,1); 
    repmat(panlab(2,:),3,1);
    repmat(panlab(3,:),4,1); 
    repmat(panlab(4,:),4,1)];

ax = stf(panlab,...
    [0.05 0.065 0.01 0.01],[0.10 0.10],'aspect',1);

h.fs=h.fs-[2 4 4 4];

%-----scalogram
for i=1:length(SC)
    axes(ax(i));
    X = SC(i).X;
    Y = SC(i).Y;
    Z = SC(i).Z;
    imh(i) = imagesc(X,Y,Z); hold on;
    set(gca,'Clim',SC(i).clims);
    colormap(gca,SC(i).cmap);     
    cbh(i) = colorbar;
    set(gca,'YDir','normal');
    
    [M,c] = contour(X,Y,Z, SC(i).clevels,'color', SC(i).clabcolor);
    clabel(M,c,'fontsize',h.fs(end),'fontname','calibri','labelspacing',500,'color',SC(i).clabcolor);
end

lims = getlims(ax(1:2),'xy');
set(ax(1:2),'xlim',lims(1,:),'ylim',lims(2,:));

%--------------------
datasels = unique(T.datasel,'stable');
N_valid = cellfun(@(c){T.N_valid(ismember(T.datasel,c))},datasels);
p_valid = cellfun(@(c){T.p_valid(ismember(T.datasel,c))},datasels);
p_normal = cellfun(@(c){T.p_normal(ismember(T.datasel,c))},datasels);
colors = lines(numel(datasels));

axes(ax(3));
for i=1:length(datasels)
    plot(scale_maxima,p_valid{i},'-','color',colors(i,:),'linew',2); hold on;    
    plot(scale_maxima,p_valid{i},'ko','markerfacecolor',colors(i,:)); hold on;    
end

axes(ax(4));
for i=1:length(datasels)
    plot(scale_maxima,p_normal{i},'-','color',colors(i,:),'linew',2); hold on;   
    ph(i) = plot(scale_maxima,p_normal{i},'ko','markerfacecolor',colors(i,:)); hold on;    
end

%------------
gcol = 0.75*[1 1 1];
axes(ax(5));
edges = (min(XX{1})-0.01):0.01:(max(XX{1})+0.01);
histogram(XX{1},edges,'Facecolor',gcol); hold on;
axis tight;
xlim([0 max(xlim)]);
axrescaley([0 0.05],gca);
ax(5).YTickLabel = arrayfun(@(c){sprintf('%1.1f',c/1000)},ax(5).YTick);

axes(ax(6));
edges = (min(XX{2})-0.01):0.1:(max(XX{2})+0.01);
histogram(XX{2},edges,'Facecolor',gcol); hold on;
axis tight;
xlim([0 max(xlim)]);
axrescaley([0 0.05],gca);
ax(6).YTickLabel = arrayfun(@(c){sprintf('%1.1f',c/1000)},ax(6).YTick);

%----- classification
axes(ax(end));
labs = {
    {'data selection strategies'}
    'by-window'
    'across-window'
    'begin-anchored'
    'centered'
    'end-anchored'};

pincstr = @(x)sprintf('prop: %1.2f',x);
wrngstr = @(x)sprintf('lims: [%1.1f, %1.1f]',x(1),x(2));

info = {
    2 {'+ more data','- window-dep. bias'};
    3 {'- less data','+ no window-dep. bias'};
    4 {pincstr(prop_inc(1)),wrngstr(wrange(1,:)),'anch: endpoints'};
    5 {pincstr(prop_inc(2)),wrngstr(wrange(2,:)),'anch: midpoints'};
    6 {pincstr(prop_inc(3)),wrngstr(wrange(3,:)),'anch: beginpoints'};
    };

N = array2table(labs,'VariableNames',{'lab'});
N.ypos = [0 -1 -1 -2 -2 -2]';
N.xpos = [0 -1  1  -0.25  1  2.25]';

for i=1:height(N)
    th(i) = text(N.xpos(i),N.ypos(i),N.lab{i},...
        'hori','center','verti','mid','fontsize',h.fs(3),'Backgroundcolor','w'); hold on;
end

CC = [1 2; 1 3; 3 4; 3 5; 3 6];
ylim([-2.75 0.15]);
xlim([-1.25 2.75]);
for i=1:size(CC,1)
    cc = connecting_line(th(CC(i,1)),th(CC(i,2)),'anchors','center','bounds','none');
    PP = cc(1,:);
    PP(2,:) = PP(1,:)+[0 -0.5];
    PP(3,:) = [cc(2,1) PP(2,2)];
    PP(4,:) = [PP(3,1) cc(2,2)];
    plot(PP(:,1),PP(:,2),'k-','linew',2); hold on;
end

for i=1:length(th)
    th(i) = text(N.xpos(i),N.ypos(i),N.lab{i},...
        'hori','center','verti','mid','fontsize',h.fs(3),'Backgroundcolor','w','edgecolor',[.7 .7 .7]); hold on;
end

for i=1:size(info,1)
    ix = info{i,1};
    str = info{i,2};
    str = pad(str');
    anch = th(ix).Extent;

    switch(i)
        case {2}
            pp = anch*[1 0 1 0; 0 1 0 .5]';
            thi = text(pp(1)+0.05,pp(2),str,'verti','mid','hori','left','fontsize',h.fs(4));                 
        otherwise
            pp = anch*[1 0 0 0; 0 1 0 0]';
            thi = text(pp(1),pp(2)-0.05,str,'verti','top','hori','left','fontsize',h.fs(4));       
    end
end
set(gca,'visible','off');


%%
ax1 = ax(1:2);
ax2 = ax(3:4);
ax3 = ax(5:6);

set(ax1,'fontsize',h.fs(end),'xgrid','on','ygrid','on');


axis([ax2],'tight');
axrescalex(0.05,ax2); axrescaley(0.05,ax2);

set(ax2,'box','off','xgrid','on','ygrid','on','xtick',scale_maxima(1:2:end),...
    'tickdir','out','ticklen',0.002*[1 1],'fontsize',h.fs(end));

set(ax3,'box','off','ygrid','on',...
    'tickdir','out','ticklen',0.002*[1 1],'fontsize',h.fs(end));

datasels{1} = 'centered';

legh(1) = legend(ph,datasels,'fontsize',h.fs(end),'Location','southeast');
legh(1).Position(1)=legh(1).Position(1)+0.01;

xlabel(ax1,'window center (s)','fontsize',h.fs(3));
ylabel(ax1,'window scale (s)','fontsize',h.fs(3));

xlabel(ax2,'max. scale','fontsize',h.fs(3));
ylabel(ax2(1),'prop. valid','fontsize',h.fs(3));
ylabel(ax2(2),'prop. normal cond.','fontsize',h.fs(3));

xlabel(ax3,'duration (s)','fontsize',h.fs(3));
ylabel(ax3,'count (thousands)','fontsize',h.fs(3));

panlabs = {...
    'proportion valid vowels (by-window)'
    'proportion from normal cond. (by-window)'
    'prop. valid vowels (across-window)'
    'prop. normal cond. (across-window)' 
    'vowel durations'
    'utterance durations'
    ' '};

stfig_panlab(ax,panlabs,'fontsize',h.fs([2 2 3 3 2 2 3]),'xoff',0,'yoff',0,'hori','left','verti','bot','fontweight','normal');

stfig_panlab(ax([end 1:end-1]),arrayfun(@(c){char(c+64)},1:length(ax)),'fontsize',h.fs(2),'xoff',-0.02,'yoff',0,'hori','right','verti','bot');

%%
h.printfig(mfilename);

end

%% count valid by win
function [WIN] = count_vars_bywindow(D,WIN)
for i=1:height(WIN)
    ix_valid = ...
        (D.tanch + WIN.edges(i,1))>=D.utt_t0 & ...
        (D.tanch + WIN.edges(i,2))<=D.utt_t1;

    WIN.N_valid(i) = sum(ix_valid);
    WIN.p_normal(i) = sum(ismember(D.rate(ix_valid),{'N'}))/WIN.N_valid(i);
end
end

%% scalogram
function [SC] = prep_scalogram(WIN,varname)
[X,Y,Z] = gen_scalogram(WIN,varname,'smoothing',false,'interpolation',false);
SC.X = X;
SC.Y = Y;
SC.Z = Z;
end



