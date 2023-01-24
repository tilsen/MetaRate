function [] = fig_comparison_exclusion()

dbstop if error; close all;
h = metarate_helpers();

load([h.data_dir 'metarate_partialcorr_scalographs.mat'],'T');
load([h.figures_dir 'analysis_comparisons.mat'],'D');

S.target = {'vowels_stress1'};
S.unit = {'phones'};
S.datasel = {'bytarget'};
S.inversion = 0;

D = tabindex(D,'datasel',S.datasel);

%comparisons of all analyses by exclusion
D = analysis_differences( ...
    tabindex(D,'exclusion',0,'winmethod','centered'), ...
    tabindex(D,'exclusion',1,'winmethod','centered')); 

!!should be extendwin

%define plotting subsets:
S = repmat(S,2,1);
S(1).exclusion = 0; S(1).winmethod='centered';
S(2).exclusion = 1; S(2).winmethod='centered';
 
climsets = {[1 2]};
colorbars = [0 1 1];

G = prep_subsets({S(1), S(2), S});        
SC = prep_scalographs(T,G,'climsets',climsets); 

%%
ax = stf([1 1 1; 2 3 4],[0.055 0.075 0.05 0.05],[0.05 0.10],'aspect',1.5);

%----bar plots
hb = comparison_barplot(D,'d_avg_rho','parent',ax(1),...
        'hatchfill',true,'hatchspacing',0.02, ...
        'orientation','vertical','textrotation',0, ...
        'fontsize',h.fs(end)+4,'offsetcycle',3);

%hb = comparison_barplot(D,'d_avg_rho','parent',ax(1),'hatchfill',true);

set(hb.labh,'String',[hb.labh.String ' (inclusion - exclusion)'],...
    'fontsize',h.fs(2),'rotation',90,'hori','center');
ax(1).YLim = [0 max(ax(1).YLim)+0.025];

%ax_tleg = axes('position',[.60 .83 .395 .165]);
%targets_legend(D,ax_tleg,'fontsize',h.fs(end)+2);

targlegw = 0.30;
ax_tleg = axes('position',[0.995-targlegw .83 targlegw .165]);
targets_legendr(D,ax_tleg,'fontsize',h.fs(end)+4);

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