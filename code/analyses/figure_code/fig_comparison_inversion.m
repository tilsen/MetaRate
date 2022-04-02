function [] = fig_comparison_inversion()

dbstop if error; close all;
h = metarate_helpers();

load([h.data_dir 'metarate_partialcorr_scalographs.mat'],'T');
load([h.figures_dir 'analysis_comparisons.mat'],'D');

D = D(ismember(D.data_selection,'bytarget'),:);
D = D(D.exclusion==1,:);

D = analysis_differences(...
    D(ismember(D.ratio,'proper'),:),...
    D(ismember(D.ratio,'inverse'),:));


%define set/comparison (target, unit, inversion, exclusion, selection)
datasel = {'bytarget'};
target = {'consonants_simplexcodas'};
unit = {'phones'};
exclusion = 1;

G{1} = { target unit 0 exclusion datasel};
G{2} = { target unit 1 exclusion datasel};
G{3} = { target unit 0 exclusion datasel;
         target unit 1 exclusion datasel};

climsets = {[1 2],[3]};
colorbars = [0 1 1];

G = prep_subsets(G);        
SC = prep_scalographs(T,G,'climsets',climsets); 

%%
ax = stf([1 1 1; 2 3 4],[0.065 0.075 0.05 0.05],[0.05 0.10]);

%---comparison by target
hb = comparison_barplot(D,'d_avg_rho','parent',ax(1),'hatchfill',false,'fontsize',18);
axrescaley([0.075 0.075],ax(1));

set(hb.labh,'rotation',90,'hori','center','fontsize',h.fs(3));

ax_tleg = axes('position',[.60 .820 .395 .175]);
targets_legend(D,ax_tleg,'fontsize',h.fs(end)+2);

units = unique(D.unit,'stable');
ixs = cellfun(@(c,d)find(ismember(D.unit,c),1,'first'),units);

ax_rleg = legend(hb.bh(ixs),units,'location','southwest','fontsize',h.fs(end)+2,'Orientation','horizontal');

%---scalograms
hh = plot_scalographs(SC,ax(2:end),h,colorbars);

%%

set(ax,'Fontsize',h.fs(end));

hh.th(1).String = [hh.th(1).String ' (proper rate)'];
hh.th(2).String = [hh.th(2).String ' (inverse rate)'];
hh.th(3).String = {[hh.th(1).String ' -'],hh.th(2).String};

shiftposx([hh.ax(2) hh.cbh(2) hh.cb_th(2)],-0.04);

hb.labh.String = [hb.labh.String ' (proper - inverse)'];
hb.labh.FontSize = h.fs(3);

stfig_panlab([ax(1:2)],{'A' 'B'},'xoff',[-0.01 -0.05],'fontsize',h.fs(1));

ax(end).YTickLabelMode = 'auto';

%%
h.printfig(mfilename);

end