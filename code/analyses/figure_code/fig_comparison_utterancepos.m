function [] = fig_comparison_utterancepos()

dbstop if error; close all
h = metarate_helpers();

load([h.data_dir 'metarate_partialcorr_scalographs.mat'],'T');
load([h.figures_dir 'analysis_comparisons.mat'],'D');

D = tabindex(D,'exclusion',1);

D = analysis_differences(...
    D(ismember(D.winmethod,'beginanchored'),:),...
    D(ismember(D.winmethod,'endanchored'),:));

%define set/comparison (target, unit, inversion, exclusion, selection)
%targets = {'vowels_stress1'};
S.target = 'consonants_simplexcodas';
S.unit = 'phones';
S.datasel = 'bytarget';
S.inversion = 0;
S.winmethod = 'beginanchored';
S.exclusion = 1;

S = repmat(S,2,1);
S(2).winmethod = 'endanchored';

climsets = {[1 2],3};
colorbars = [0 1 1];
G = prep_subsets({S(1), S(2), S});        
SC = prep_scalographs(T,G,'climsets',climsets); 

%%
ax = stf([ones(3,3); 2 3 4; 2 3 4],[0.07 0.075 0.05 0.05],[0.05 0.10],'aspect',1.5);

%---comparison by target
hb = comparison_barplot(D,'d_avg_rho','parent',ax(1), ...
    'hatchfill',true,'textrotation',0,'offsetcycle',3,'fontsize',h.fs(end)+2);

%ax(1).YLim = [0 ax(1).YLim(2)];
axrescaley([0.045 0.075],ax(1));

ax_tleg = axes('position',[.70 .80 .295 .195]);
targets_legendr(D,ax_tleg,'fontsize',h.fs(end)+2);
ax_rleg = rates_legend(D,hb.bh,h,'north',3,h.fs(end)+2);
ax_rleg.Position(2) = sum(ax_tleg.Position([2 4]))-ax_rleg.Position(4);
ax_rleg.Position(1) = ax_tleg.Position(1)-ax_rleg.Position(3)-0.015;

%---scalograms
hh = plot_scalographs(SC,ax(2:end),h,colorbars);

%%
hh.ax(end).XLabel.String = {'abs. value of window center (s)','(distance from anchor)'};


hb.labh.String = [hb.labh.String ' (early - late)'];
set(hb.labh,'FontSize',h.fs(3),'rotation',90,'hori','center');

set(hh.ax,'XTick',[-1:0.1:1]);
slch = [hh.slc_re hh.slc_le];
set(slch(ishandle(slch)),'visible','off');

shiftposx([hh.ax(2) hh.cbh(2) hh.cb_th(2)] ,-0.04);

strs = {hh.th.String};
strs{1} = {'utterance-early data bias',strs{1}}; 
strs{2} = {'utterance-late data bias',strs{2}}; 
strs{3} = {'early bias - late bias',strs{3}{1}(1:end-2)}; 

for i=1:length(hh.th)
    hh.th(i).String = strs{i};
end

ax(end).YTickLabelMode = 'auto';
ax(end-1).XTickLabelRotation = 0;

stfig_panlab(ax(1:2),{'A' 'B'},'xoff',[-0.01 -0.05],'fontsize',h.fs(1));

%%
h.printfig(mfilename);

end