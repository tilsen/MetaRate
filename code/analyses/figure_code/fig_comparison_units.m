function [] = fig_comparison_units()

dbstop if error; close all;
h = metarate_helpers();

load([h.data_dir 'metarate_partialcorr_scalographs.mat'],'T');
load([h.figures_dir 'analysis_comparisons.mat'],'D');

D = D(ismember(D.winmethod,'extendwin'),:);
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
S.target = 'vowels_stress1';
S.unit = 'phones';
S.datasel = 'bytarget';
S.exclusion = 1;
S.inversion = 0;
S.winmethod = 'extendwin';

S = repmat(S,2,1);
S(2).unit = 'moras';

climsets = {[1 2],3};
colorbars = [0 1 1];

G = prep_subsets({S(1),S(2),S});        
SC = prep_scalographs(T,G,'climsets',climsets); 

%%
axpan = [reshape(repmat(1:4,3,1),1,[]);...
        reshape(repmat(5:7,4,1),1,[])];

htop = 7;
hbot = 3;
axpan = [repmat(axpan(1,:),htop,1); repmat(axpan(2,:),hbot,1)];

axpan = [1 1 1 2 2 2; 3 3 3 4 4 4; 5 5 6 6 7 7];

ax = stf(axpan,[0.085 0.075 0.05 0.05],[0.05 0.10],'aspect',1.2);

ax(3).Position(2) = ax(3).Position(2) + 0.05;
ax(4).Position(2) = ax(4).Position(2) + 0.05;
ax(6).Position(1) = ax(6).Position(1) - 0.045;

for i=1:4
    ax(i).Position(3) = ax(i).Position(3) + 0.04;
end

%----bar plots
for i=1:length(DX)
    DX{i}.color = repmat([.5 .5 .5],height(DX{i}),1);
    hb{i} = comparison_barplot(DX{i},'d_avg_rho','parent',ax(i), ...
        'hatchfill',true,'fontsize',h.fs(end),'textrotation',0,'textoffset',0.10,'orientation','vertical');
    if i==2 || i==4, delete(hb{i}.labh); end
    delete(hb{i}.zerolh);
end

%%

hh = plot_scalographs(SC,ax(5:end),h,colorbars);


%%
set(ax,'fontsize',h.fs(end));

axb = ax(1:4);
axis(axb,'tight');
ylims = getlims(axb,'y');

set(axb,'ylim',[0 ylims(2)]);
axrescaley([0 0.085], axb);
axrescalex(0.01, axb);
set(axb([2 4]),'YTickLabel',[]);

stfig_panlab(axb,comp_labs,'xoff',0,'hori','left','fontsize',h.fs(2),'fontweight','normal');

ax_tleg_pos = [ax(3).Position(1) ax(3).Position(2) 0 0];
wwx = 0.85;
hhy = 0.05;
ax_tleg_pos = ax_tleg_pos+[0 -hhy-0.005 wwx hhy];
ax_tleg = axes('position',ax_tleg_pos);

targets_legendr(DX{1},ax_tleg,'fontsize',h.fs(end)-1,'numcols',numel(unique(DX{1}.symb))/2);

ax(end).YTickLabelMode = 'auto';

stfig_panlab([axb(1) ax(5)],{'A' 'B'},'xoff',-0.05,'fontsize',h.fs(1));

%%

h.printfig(mfilename);

end