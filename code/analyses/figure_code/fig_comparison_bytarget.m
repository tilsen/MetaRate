function [] = fig_comparison_bytarget()

dbstop if error; close all;
h = metarate_helpers();

load([h.data_dir 'metarate_partialcorr_scalographs.mat'],'T');

%define set/comparison (target, unit, inversion, exclusion, selection)
datasel = {'bytarget'};
unit = {'phones'};
inversion = 0;
exclusion = 1;

G = {};
G{end+1} = { {'consonants_simplexcodas'} unit inversion exclusion datasel};
G{end+1} = { {'consonants_simplexonsets'} unit inversion exclusion datasel};
G{end+1} = { {'consonants_simplexcodas'} unit inversion exclusion datasel;
             {'consonants_simplexonsets'} unit inversion exclusion datasel};

G{end+1} = { {'vowels_stress1'} unit inversion exclusion datasel};
G{end+1} = { {'vowels_stress0'} unit inversion exclusion datasel};
G{end+1} = { {'vowels_stress1'} unit inversion exclusion datasel;
             {'vowels_stress0'} unit inversion exclusion datasel};

climsets = {[1 2],3,[4 5],6};
colorbars = [0 1 1 0 1 1];

G = prep_subsets(G);        
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