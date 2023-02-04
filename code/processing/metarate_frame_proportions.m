function [] = metarate_frame_proportions()

dbstop if error; 
h = metarate_helpers();

load([h.data_dir 'metarate_segmentdata.mat'],'TR');

units = h.units;

dt = 1/h.frame_rate;

%sanity check that all trials begin/end with sp
for i=1:length(units)
    nuu(i,1) = all(cellfun(@(c)strcmp(c{1},'sp'),TR.(units{i})));
    nuu(i,2) = all(cellfun(@(c)strcmp(c{end},'sp'),TR.(units{i})));
end
if any(nuu(:)~=1)
    fprintf('assumption that trial starts with sp violated\n'); return;
end

%%
for j=1:length(units)   
    for i=1:height(TR)
        
        status_str = status(sprintf('%s: %i/%i',units{j},i,height(TR))); %#ok<NASGU>

        [frpnts,prop_dur,UIX]  = calc_prop_durs(TR(i,:),units{j},dt);

        if j==1, TR.frt{i} = single(frpnts); end %save time-points vector

        TR.([units{j} '_pdur']){i} = single(prop_dur);
        TR.([units{j} '_pdur_map']){i} = uint8(UIX); %max of 256 units...       
        
    end 
end
status('reset');

%%
save([h.data_dir 'metarate_propdurs.mat'],'TR');

end

%% calculate proportional durations
function [frpnts,prop_dur,UIX] = calc_prop_durs(tr,unit,dt)
%first and last indexes of units

t0u = round(tr.([unit '_t0']){1},6)';
t1u = round(tr.([unit '_t1']){1},6)';

t0 = t0u(1);
t1 = t1u(end);

ix_sp = find(ismember(tr.(unit){1},'sp'));

frpnts = round(t0:dt:(t1-dt),6);

%unit times are rows, frame times are cols:
FRP = repmat(frpnts,length(t0u),1);
T0u = repmat(t0u,1,length(frpnts));
T1u = repmat(t1u,1,length(frpnts));

UF_MAP = (T0u<=FRP) & (T1u>FRP);

UIX = sum((1:length(t0u))'.*UF_MAP);

%unit_durs = t1u-t0u;
n_frames = cumsum(UF_MAP,2);

NfrU = n_frames(:,end);

%fr_unit_durs = unit_durs.*IX;

prop_dur = sum(UF_MAP./NfrU);

%sp proportional durations are 0
prop_dur(ismember(UIX,ix_sp)) = 0;
end