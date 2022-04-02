function [] = fig_comparison_dataselection()

dbstop if error; close all
h = metarate_helpers();

load([h.data_dir 'metarate_partialcorr_scalographs.mat'],'T');
load([h.figures_dir 'analysis_comparisons.mat'],'D');

D = D(D.exclusion==1,:);

D = analysis_differences(...
    D(ismember(D.data_selection,'beginanchored'),:),...
    D(ismember(D.data_selection,'endanchored'),:));

%define set/comparison (target, unit, inversion, exclusion, selection)
targets = {'consonants_simplexcodas'};
inversion = 0;
exclusion = 1;
units = {'phones'};
datasels = {'beginanchored','endanchored'};

G{1} = { targets(1) units inversion exclusion datasels(1) };
G{2} = { targets(1) units inversion exclusion datasels(2) };
G{3} = { targets(1) units inversion exclusion datasels(1);
         targets(1) units inversion exclusion datasels(2)};

climsets = {[1 2],3};
colorbars = [0 1 1];

G = prep_subsets(G);        
SC = prep_scalographs(T,G,'climsets',climsets); 

%%
ax = stf([1 1 1; 2 3 4],[0.055 0.075 0.05 0.05],[0.05 0.10]);

%---comparison by target
hb = comparison_barplot(D,'d_avg_rho','parent',ax(1),'hatchfill',true);
axrescaley([0.075 0.075],ax(1));

ax_tleg = axes('position',[.60 .80 .395 .195]);
targets_legend(D,ax_tleg,'fontsize',h.fs(end)+2);
ax_rleg = rates_legend(D,hb.bh,h,'north',3,h.fs(end)+2);
ax_rleg.Position(2) = sum(ax_tleg.Position([2 4]))-ax_rleg.Position(4);
ax_rleg.Position(1) = ax_tleg.Position(1)-ax_rleg.Position(3)-0.015;

%---scalograms
hh = plot_scalographs(SC,ax(2:end),h,colorbars);

%%
hh.ax(end).XLabel.String = {'abs. value of window center (s)','(distance from anchor)'};


hb.labh.String = [hb.labh.String ' (early - late)'];
hb.labh.FontSize = h.fs(3);
hb.labh.Rotation = 90;
hb.labh.HorizontalAlignment = 'center';

set(hh.ax,'XTick',[-1:0.1:1]);
slch = [hh.slc_re hh.slc_le];
set(slch(ishandle(slch)),'visible','off');

shiftposx([hh.ax(2) hh.cbh(2) hh.cb_th(2)] ,-0.04);

strs = {hh.th.String};
strs{1} = {'utterance-early data bias',strs{1}}; 
strs{2} = {'utterance-late data bias',strs{2}}; 
strs{3} = ['early - late ',strs{3}{1}(1:end-2)]; 

for i=1:length(hh.th)
    hh.th(i).String = strs{i};
end

ax(end).YTickLabelMode = 'auto';

stfig_panlab(ax(1:2),{'A' 'B'},'xoff',[-0.01 -0.05],'fontsize',h.fs(1));

%%
h.printfig(mfilename);

end