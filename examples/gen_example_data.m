%This script generate the example data from the full dataset
h = metarate_helpers;

sel_subj = 'F01'; %choose some participant here
sel_phones = {'P','B'}; %choose some phones here

load([h.data_dir 'metarate_propdurs.mat']);
TR = TR(ismember(TR.subj,sel_subj),:);
save(['.' filesep 'examples' filesep 'example_propdurs_table.mat'],'TR');

load([h.data_dir 'metarate_durdata_consonants.mat'],'D');
D = D(ismember(D.phones,sel_phones) & ismember(D.subj,sel_subj),:);
save(['.' filesep 'examples' filesep 'example_targets_table.mat'],'D');