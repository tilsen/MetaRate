function [] = fig_comparison_inversion()

dbstop if error; close all;
h = metarate_helpers();

load([h.data_dir 'metarate_partialcorr_scalographs.mat'],'T');
load([h.figures_dir 'analysis_comparisons.mat'],'D');

D = tabindex(D,'winmethod','extendwin','exclusion',1);

D = analysis_differences(...
    D(ismember(D.ratio,'proper'),:),...
    D(ismember(D.ratio,'inverse'),:));

%define set/comparison (target, unit, inversion, exclusion, selection)
S.target = 'consonants_simplexcodas';
S.unit = 'phones';
S.datasel = 'bytarget';
S.inversion = 0;
S.winmethod = 'extendwin';
S.exclusion = 1;

S = repmat(S,2,1);
S(2).inversion = 1;
 
climsets = {[1 2],3};
colorbars = [0 1 1];
G = prep_subsets({S(1), S(2), S});        
SC = prep_scalographs(T,G,'climsets',climsets); 

%%
ax = stf([1 1 1; 2 3 4],[0.07 0.075 0.05 0.05],[0.05 0.10],'aspect',1.5);

%---comparison by target
hb = comparison_barplot(D,'d_avg_rho','parent',ax(1), ...
    'hatchfill',false,'fontsize',h.fs(end)+4,'textrotation',0);

axrescaley([0.075 0.075],ax(1));

set(hb.labh,'rotation',90,'hori','center','fontsize',h.fs(3));

axw = 0.30; axh = 0.165;
ax_tleg = axes('position',[0.995-axw 0.995-axh axw axh]);
targets_legendr(D,ax_tleg,'fontsize',h.fs(end)+2);


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