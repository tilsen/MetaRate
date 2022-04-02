function [] = metarate_segment_articulator_vel()

dbstop if error;
[h,PH] = metarate_helpers();

%% 
min_peak_distance = 0.05;
min_peak_prominence = 0.03;

Fs = h.frame_rate;

%%
load([h.data_dir 'metarate_artic_vel.mat'],'TR');

velfs = {'sysvel','sumvel'};

velf = 'sysvel'; 
rmf = setdiff(velfs,velf);
TR = removevars(TR,rmf);

for i=1:height(TR)

    status_str = status(sprintf('processing %05i/%05i',i,height(TR))); %#ok<NASGU> 

    x = -TR.(velf){i};
    x = x-min(x);
    x = x/max(x);

    [~,minixs] = findpeaks(x,'MinPeakProminence',min_peak_prominence,'MinPeakDistance',min_peak_distance);

    utt_tspan = [TR.utt_t0(i) TR.utt_t1(i)];
    utt_ixs = round(h.frame_rate*utt_tspan);

    %check if no valid starting index
    ix0 = find(minixs<utt_ixs(1),1,'last');
    if isempty(ix0) %fallback: add segment boundary halfway between utterance begin and signal start
        minixs = [round(mean([1 utt_ixs(1)])) minixs]; %#ok<*AGROW> 
    else
        minixs = minixs(ix0:end);
    end

    %check if no valid starting index
    ix1 = find(minixs>utt_ixs(2),1,'first');
    if isempty(ix1) %%fallback: add segment boundary halfway between utterance end and signal end
        minixs = [minixs round(mean([length(x) utt_ixs(2)])) ]; 
    else
        minixs = minixs(1:ix1);
    end    

    %add sps
    minixs = unique([1 minixs length(x)]);

    artics = [{'sp'} arrayfun(@(c){sprintf('a%02i',c)},1:numel(minixs)-3) {'sp'}];

    TR.artics{i} = artics;
    TR.artics_t0{i} = TR.t{i}(minixs(1:end-1));
    TR.artics_t1{i} = TR.t{i}(minixs(2:end));

end
status('reset');

%%

save([h.data_dir 'metarate_segmentation_artic.mat'],'TR');

end
