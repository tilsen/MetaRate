function [] = fig_comparison_classes()

dbstop if error; close all
h = metarate_helpers();

load([h.data_dir 'metarate_partialcorr_scalographs.mat'],'T');
load([h.figures_dir 'analysis_comparisons.mat'],'D');

D = D(ismember(D.data_selection,'bytarget'),:);
D = D(D.exclusion==1,:);
D = sortrows(D,'avg_rho','descend');

%% choose best model that does not overfit
LM{1} = fitlm(D,'avg_rho~unit+ratio+target');
LM{2} = fitlm(D,'avg_rho~unit*target+ratio');
LM{3} = fitlm(D,'avg_rho~unit*ratio+target');
LM{4} = fitlm(D,'avg_rho~unit+ratio*target');

AICs = cellfun(@(c)c.ModelCriterion.AIC,LM);
[~,min_ix] = min(AICs);
lmo = LM{min_ix};

%%

C = lmo.Coefficients;
C.name = lmo.CoefficientNames';

C = C(~contains(C.name,':'),:);

C.istarget = contains(C.name,'target');
C.isunit = contains(C.name,'unit');
C(C.istarget,:) = sortrows(C(C.istarget,:),'Estimate','descend');
C(C.isunit,:) = sortrows(C(C.isunit,:),'Estimate','descend');

for i=1:height(C)
    if C.istarget(i)
        C.symb{i} = D.symb{find(ismember(D.target,strrep(C.name{i},'target_','')),1,'first')};
    end
end
C.symb{1} = D.symb{find(ismember(D.target,'consonants_simplexcodas'),1,'first')};

%%
ax = stf([2 1],[0.065 0.01 0.01 0.075],[0.01 0.05]);

%----
axes(ax(1));
hb = comparison_barplot(D,'avg_rho','parent',ax(1),...
        'hatchfill',true,'hatchspacing',0.02,'orientation','vertical','fontsize',18);

ax(1).YLim = [0 ax(1).YLim(2)];
set(hb.labh,'FontSize',h.fs(2));
hb.labh.Position(1)=hb.labh.Position(1)-0.5;

xlims = getlims(ax,'x');
set(ax,'xlim',xlims);

ax_tleg = axes('position',[.60 .85 .395 .145]);
targets_legend(D,ax_tleg,'fontsize',h.fs(end)+1);
ax_rleg = rates_legend(D,hb.bh,h,'north',3,h.fs(end)+2);
ax_rleg.Position(2) = sum(ax_tleg.Position([2 4]))-ax_rleg.Position(4);
ax_rleg.Position(1) = ax_tleg.Position(1)-ax_rleg.Position(3)-0.015;

%----
axes(ax(2));

lw = 3;
ms = 10;

C.xpos = (1:height(C))';
C.xpos(C.isunit) = C.xpos(C.isunit) + 3;
C.xpos(end) = C.xpos(end) + 6;

y = C.Estimate(1);
yci = y+[-1 1]*C.SE(1);
x = [1 max(C.xpos)+1];
color = D.color(find(ismember(D.unit,'phones'),1,'first'),:);

fill(x([1 2 2 1]),yci([1 1 2 2]),color,'FaceAlpha',0.25,'edgecolor','none'); hold on;

plot(x,C.Estimate(1)*[1 1],'linew',lw, 'color',color); hold on;

th = text(7,C.Estimate(1),[C.symb{1} ' \sim phones proper'],'verti','bot','fontsize',h.fs(2));

for i=2:height(C)
    y = C.Estimate(i)+C.Estimate(1);
    yci = y+[-1 1]*C.SE(i);
    x = C.xpos(i);

    if C.isunit(i)
        unit = strrep(C.name{i},'unit_','');
        color = D.color(find(ismember(D.unit,unit),1,'first'),:);    
        th(i) = text(x,yci(2),unit,...
            'verti','bot','fontsize',h.fs(2),'hori','center');        
    elseif C.istarget(i)
        color = [.5 .5 .5];
        draw_hatchline(x,yci,0.1,'color',color,'linew',lw); 
        th(i) = text(x,yci(1),C.symb{i},...
            'verti','top','fontsize',h.fs(2),'hori','center');
    else
        color = [.5 .5 .5];
        th(i) = text(x,yci(1),'inverse',...
            'verti','top','fontsize',h.fs(2),'hori','center');            
    end
    draw_hatchline(x,yci,0.15,'color',color,'linew',lw);
    plot(x,y,'ko','markerfacecolor',color,'markersize',ms);

end
axis tight;
axrescaley([-0.05 0.15],gca);
set(gca,'Box','off','XColor','none','fontsize',h.fs(end),...
    'ygrid','on','tickdir','out','ticklen',0.003*[1 1]);
ax(2).YLabel = copyobj(ax(1).YLabel,ax(2));

stfig_panlab(ax,[],'hori','right','xoff',-0.035);

%%
h.printfig(mfilename);

end