function [win] = metarate_propdur_windows(we0,we1,pdur_times)

%given absolute window edges length of proportional duration timesries an
%multiply by proportional duration array

win = nan(size(pdur_times));
win(pdur_times>=we0 & pdur_times<=we1)=1;

end

