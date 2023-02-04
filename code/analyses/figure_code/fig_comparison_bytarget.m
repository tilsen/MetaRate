function [] = fig_comparison_bytarget()

dbstop if error; close all;
h = metarate_helpers();

load([h.data_dir 'metarate_partialcorr_scalographs.mat'],'T');

%define set/comparison (target, unit, inversion, exclusion, selection)
S.winmethod = 'extendwin';
S.unit = 'phones';
S.inversion = 0;
S.exclusion = 1;
S.datasel = 'bytarget';
S.target = 'consonants_simplexcodas';

S = repmat(S,4);
S(1).target = 'consonants_simplexcodas';
S(2).target = 'consonants_simplexonsets';
S(3).target = 'vowels_stress1';
S(4).target = 'vowels_stress0';

climsets = {[1 2],3,[4 5],6};
colorbars = [0 1 1 0 1 1];

G = prep_subsets({S(1),S(2),S(1:2),S(3),S(4),S(3:4)});        
SC = prep_scalographs(T,G,'climsets',climsets); 

for i=1:length(SC)
    if iscell(SC(i).panlab)
        SC(i).panlab = [SC(i).panlab{1} SC(i).panlab{2}];
    end
end

nr = 2;
ax = stf(reshape(1:length(G),nr,[]),[0.055 0.065 0.065 0.055],[0.05 0.075],...
    'handlearray','matrix');

hh = plot_scalographs(SC,ax,h,colorbars);

%%
set(ax(:,end),'YTickLabelMode','auto');

cbix = [2 5];
shiftx = -0.045;
shiftposx([ax(:,2)],shiftx);
shiftposx([hh.cbh(cbix) hh.cb_th(cbix)],shiftx);

cbix = [3 6];
shiftposx([hh.cbh(cbix) hh.cb_th(cbix)],0);

stfig_panlab(ax([1 2]),[],'fontsize',h.fs(1),'xoff',-0.05);

%%
h.printfig(mfilename);

end