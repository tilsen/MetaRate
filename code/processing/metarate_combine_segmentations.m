function [] = metarate_combine_segmentations()

%combines artic segmentation with phones/sylbs/words

dbstop if error; 
[h,~] = metarate_helpers();

load([h.data_dir 'metarate_segmentdata.mat']);

%%
X = load([h.data_dir 'metarate_segmentation_artic.mat']);

check_trial_match = cellfun(@(c,d)strcmp(c,d),TR.fname,X.TR.fname);

if ~all(check_trial_match)
    fprintf('mismatched data tables\n'); return;
end

copyf = {'artics' 'artics_t0' 'artics_t1'};

for i=1:length(copyf)
    TR.(copyf{i}) = X.TR.(copyf{i});
end

%add utterance duration info
TR.utt_t0 = cellfun(@(c)c(2),TR.words_t0);
TR.utt_t1 = cellfun(@(c)c(end-1),TR.words_t1);
TR.utt_dur = TR.utt_t1-TR.utt_t0;

%use only plural units names:
for i=1:length(h.units)
    unit = h.units{i};
    TR.Properties.VariableNames = ...
        regexprep(TR.Properties.VariableNames,[unit(1:end-1) '(_|^)'],[unit '$1']);
end

save([h.data_dir 'metarate_segmentdata.mat'],'TR');

end


