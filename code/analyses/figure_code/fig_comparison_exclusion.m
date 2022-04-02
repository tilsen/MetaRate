function [] = fig_comparison_exclusion()

dbstop if error; close all;
h = metarate_helpers();

load([h.data_dir 'metarate_partialcorr_scalographs.mat'],'T');
load([h.figures_dir 'analysis_comparisons.mat'],'D');

D = D(ismember(D.data_selection,'bytarget'),:);

%comparisons of all analyses by exclusion
D = analysis_differences(D(D.exclusion==0,:),D(D.exclusion==1,:));

target = {'vowels_stress1'};
unit = {'phones'};
datasel = {'bytarget'};
inversion = 0;

%define set/comparison (target, unit, inversion, exclusion, selection)
G{1} = { target unit inversion [0] datasel};
G{2} = { target unit inversion [1] datasel};
G{3} = { target unit inversion [0] datasel;
         target unit inversion [1] datasel};
     
climsets = {[1 2]};
colorbars = [0 1 1];

G = prep_subsets(G);        
SC = prep_scalographs(T,G,'climsets',climsets); 

%%
ax = stf([1 1 1; 2 3 4],[0.055 0.075 0.05 0.05],[0.05 0.10]);

%----bar plots
hb = comparison_barplot(D,'d_avg_rho','parent',ax(1),'hatchfill',true);
set(hb.labh,'String',[hb.labh.String ' (inclusion - exclusion)'],...
    'fontsize',h.fs(2),'rotation',90,'hori','center');
ax(1).YLim = [0 max(ax(1).YLim)+0.025];

ax_tleg = axes('position',[.60 .83 .395 .165]);
targets_legend(D,ax_tleg,'fontsize',h.fs(end)+2);
ax_rleg = rates_legend(D,hb.bh,h,'north',3,h.fs(end)+2);
ax_rleg.Position(2) = sum(ax_tleg.Position([2 4]))-ax_rleg.Position(4);
ax_rleg.Position(1) = ax_tleg.Position(1)-ax_rleg.Position(3)-0.015;

%----scalograms
SC(end).rho_levels = [-1:0.1:-0.1 0.1:0.1:1];
hh = plot_scalographs(SC,ax(2:end),h,colorbars);

%%
hh.th(1).String = [hh.th(1).String ' (targets included)'];
hh.th(2).String = [hh.th(2).String ' (targets excluded)'];
hh.th(3).String = {[hh.th(1).String ' -'],hh.th(2).String};

xa = 0.04;
hh.ax(2).Position(1) = hh.ax(2).Position(1) - xa;
hh.cbh(2).Position(1) = hh.cbh(2).Position(1) - xa; 
hh.cb_th(2).Position(1) = hh.cb_th(2).Position(1) - xa; 

hh.ax(3).YTickLabelMode = 'auto';

stfig_panlab(ax(1:2),{'A','B'},'hori','right','xoff',-1*[0.01 0.05]);

%%

h.printfig(mfilename);

end