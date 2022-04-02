function [] = fig_proportional_duration()

dbstop if error; close all;
h = metarate_helpers();

%seg_durs = round([.15 .2 .1 .25 .3 .15],3);
seg_durs = round([.15 .2 .10 .10 .25 .3 .15],3);

seg_labs = arrayfun(@(c){sprintf('u_%i',c)},[0 1 2 2 3 4 5]);

tt = cumsum([0 seg_durs]);
S = table(seg_labs',seg_durs',tt(1:end-1)',tt(2:end)','VariableNames',{'lab','dur','t0','t1'});

%S.lab([1 end]) = {'SIL'};
S.lab([1  4 end]) = {'SIL'};

S.tmid = (S.t0+S.t1)/2;

S.include = true(height(S),1);
S.include(ismember(S.lab,'SIL')) = false;

dt = 0.05;

S.frame_pdur = S.include .* (1./(S.dur/dt));

t = round(S.t0(1):dt:S.t1(end),3);
pdur = zeros(size(t));

for i=1:height(S)
    ixs = t>=S.t0(i) & t<S.t1(i);
    pdur(ixs) = S.frame_pdur(i);
end

%%
ax = stf([1; 2; 3; 3; 4; 4; 5; 5; 5],[0.175 0.075 0.01 0.01],[0 0.01]);

%----units
axes(ax(1));
for i=1:height(S)
    phl0(i) = plot(S.t0(i)*[1 1],[0 1],'k-','linew',2); hold on;
    phl1(i) = plot(S.t1(i)*[1 1],[0 1],'k-','linew',2); 
    str =['$' S.lab{i} '$'];
    str = regexprep(str,'SIL','\\mathrm{SIL}');
    th(i) = text(S.tmid(i),0.95,str,'hori','center','fontsize',h.fs(2),'verti','top','interp','latex');
    th2(i) = text(S.tmid(i),0.05,{sprintf('%1.3f',S.dur(i))},'hori','center','fontsize',h.fs(2),'verti','bot');
end
set([phl0(1) phl1(end)],'visible','off');

%-----proportional durations
axes(ax(2));
for i=1:length(t)-1
    plot(t(i)*[1 1],[0 1],'k-','linew',0.5); hold on;
    str = num2str(pdur(i),'%.3f');
    text(sum(t(i+[0 1]))/2,0.5,str(2:end),'fontsize',16,'hori','center');
end

%----time-series
%dx = dt/2;
dx = 0;
axes(ax(3))
plot(t+dx,pdur,'ko-','linew',2,'markerfacecolor','w'); hold on;
ylim([0 max(pdur)]);

%----cumulative
axes(ax(4));
plot(t+dx,cumsum(pdur),'ko-','linew',2,'markerfacecolor','w'); hold on;
ylim([0 max(cumsum(pdur))]);

%----windows
scales = dt:dt:1;
centers = -1:dt:1;
tanch = S.tmid(5);
tlims = [S.t0(2) S.t0(end)];

sc = combvec(scales,centers)';
sc = sortrows(sc,1);
wins = tanch + sc(:,2)+sc(:,1).*[-1 1]/2;
wins = round(wins,3);
wins = wins(wins(:,1)>=tlims(1) & wins(:,2)<=tlims(2),:);

axes(ax(end));
for i=1:size(wins,1)
    color = [.5 .5 .5];
    lw = 1;
    if abs(mean(wins(i,:))-tanch)<1e-3
        color = 'r';
        lw = 2;
    end
    plot(wins(i,:),-i*[1 1],'-','color',color,'linew',lw); hold on;
end
axis tight;

axes(ax(3));
PP = [0 0.02; dt 0.02];
bh = drawbrace(PP(1,:),PP(2,:),0.0075,'color','k','linew',1);
text(dt/2,max(bh.YData),'$\Delta t$','Interpreter','latex',...
    'FontSize',h.fs(2),'verti','bot','hori','center');

 
%%
set(ax,'xlim',minmax(t),'Tickdir','out','ticklen',0.002*[1 1],...
    'Box','off','fontsize',h.fs(end),...
    'xtick',0:dt:max(t));
set(ax(1:end-1),'xticklabel',[]);
set(ax(end-2:end),'xgrid','on');

axrescaley(0.05,ax(end-2:end));

set(ax(3:4),'YGrid','on');
set(ax([1 2 end]),'YColor','none','YTick',[]);

set(ax(end-1),'ytick',[0:4]);
xlabel(ax(end),'time (s)','FontSize',h.fs(end-1));

panlabs = {'units',...
    {'proportional','counts by frame'},...
    {'proportional','count timeseries','\delta(t)'},...
    {'cumulative sum','of proportional','counts'},...
    {'valid','windows'}};

stfig_panlab(ax,panlabs,'verti','top','hori','right','xoff',-0.05,'yoff',0,...
    'fontsize',h.fs(3)+[4 2 4 2 4]);

%%
h.printfig(mfilename);

end


