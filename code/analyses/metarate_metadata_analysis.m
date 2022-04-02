function [] = metarate_metadata_analysis()

dbstop if error;
h = metarate_helpers;

load([h.data_dir 'metarate_segmentdata.mat'],'TR');


TR.N_sp = cellfun(@(c)sum(ismember(c,'sp')),TR.words)-2;

fprintf('\nnumber of utterance-internal silent pauses per sentence:\n');
tabulate(TR.N_sp);

fprintf('\nnumber sentences per subject:\n');
tabulate(TR.subj)

%crosstable(TR.text,TR.subj);

fprintf('\nnumber trials per block by speaker:\n');
tt = crosstable(TR.block,TR.subj);
disp(tt);

tt = table2array(tt(:,2:end));

N_max = 180*ones(size(tt));
N_max(tt<150) = 120;

loss = N_max-tt;

total_missing = sum(loss(:));
total_expected = sum(N_max(:));

fprintf('proportion of missing trials: %1.3f\n',total_missing/total_expected);


end