function [frpnts,prop_dur,UIX] = metarate_calc_prop_durs(tr,unit,dt)
%first and last indexes of units

t0 = tr.([unit '_t0']){1}(1);
t1 = tr.([unit '_t1']){1}(end);

t0u = tr.([unit '_t0']){1}';
t1u = tr.([unit '_t1']){1}';

ix_sp = find(ismember(tr.(unit){1},'sp'));

frpnts = t0:dt:t1;

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