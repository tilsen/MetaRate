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

save([h.data_dir 'metarate_segmentdata.mat'],'TR');

end


