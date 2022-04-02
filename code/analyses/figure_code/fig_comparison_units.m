function [] = fig_comparison_units()

dbstop if error; close all;
h = metarate_helpers();

load([h.data_dir 'metarate_partialcorr_scalographs.mat'],'T');
load([h.figures_dir 'analysis_comparisons.mat'],'D');

D = D(ismember(D.data_selection,'bytarget'),:);
D = D(D.exclusion==1,:);

%---comparisons of rate units
comps = {'moras','sylbs','words','artics'};
comp_labs = {
    'phone rate - \mu rate';
    'phone rate - \sigma rate';
    'phone rate - word rate';
    'phone rate - artic. event rate'};

for i=1:length(comps)
    DX{i} = analysis_differences(D(ismember(D.unit,'phones'),:),D(ismember(D.unit,comps{i}),:));
end

%---scalograms
datasel = {'bytarget'};
target = {'vowels_stress1'};
inversion = 1;
exclusion = 1;

G{1} = { target {'phones'} inversion exclusion datasel};
G{2} = { target {'moras'}  inversion exclusion datasel};
G{3} = { target {'phones'} inversion exclusion datasel;
         target {'moras'}  inversion exclusion datasel};   

climsets = {[1 2],3};
colorbars = [0 1 1];

G = prep_subsets(G);        
SC = prep_scalographs(T,G,'climsets',climsets); 

%%
axpan = [reshape(repmat([1:4],3,1),1,[]);...
        reshape(repmat([5:7],4,1),1,[])];
ax = stf(axpan,[0.065 0.075 0.05 0.05],[0.05 0.10]);

for i=1:4
    ax(i).Position(3) = ax(i).Position(3) + 0.04;
end

%----bar plots
for i=1:length(DX)
    DX{i}.color = repmat([.5 .5 .5],height(DX{i}),1);
    hb{i} = comparison_barplot(DX{i},'d_avg_rho','parent',ax(i),'hatchfill',true);
    if i>1, delete(hb{i}.labh); end
end

%%

hh = plot_scalographs(SC,ax(5:end),h,colorbars);

%%
set(ax,'fontsize',h.fs(end));

axb = ax(1:4);
axis(axb,'tight');
ylims = getlims(axb,'y');

set(axb,'ylim',ylims+[0 0.1]);
axrescaley([-0.01 0.075], axb);
set(axb(2:end),'YTickLabel',[]);

stfig_panlab(axb,comp_labs,'xoff',0,'hori','left','fontsize',h.fs(2),'fontweight','normal');

ax_tleg = axes('position',[.075 .8350 .325 .115]);
targets_legend(DX{1},ax_tleg,'fontsize',h.fs(end)-1);

shiftposx([hh.ax(2) hh.cbh(2) hh.cb_th(2)],-0.04);
ax(end).YTickLabelMode = 'auto';

stfig_panlab([axb(1) ax(5)],{'A' 'B'},'xoff',-0.05,'fontsize',h.fs(1));

%%

h.printfig(mfilename);

end