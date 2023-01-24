function [we0,we1] = metarate_data_window_edges(D,W,method)

%given a data table, window specifications table, and method parameters,
%generates a matrices of window edge times for each datapoint

if nargin==2, method = ''; end

%% specified windows in absolute times
we0 = D.tanch + W.edges(:,1)';
we1 = D.tanch + W.edges(:,2)';

%% methods with window adjustment
switch(method)
    case {'extendwin'} %extend window

        overlap_dur = ((we0<D.rateunit_t1) & (we1>=D.rateunit_t0)) .* (min(we1,D.rateunit_t1)-max(we0,D.rateunit_t0));

        %overlap conditions for left/right edge adjustments:
        ext0 = (we0 > D.rateunit_t0) & (we0 < D.rateunit_t1);
        ext1 = (we1 > D.rateunit_t0) & (we1 < D.rateunit_t1);

        we0 = ext0.*(D.rateunit_t0 - overlap_dur/2) + (1-ext0).*(we0-overlap_dur/2); 
        we1 = ext1.*(D.rateunit_t1 + overlap_dur/2) + (1-ext1).*(we1+overlap_dur/2);         

    case {'adaptivewin'}

        %first, slide to utterance boundary if window is out of range:
        we0_d = max(0,D.utt_t0-we0); %positive for out-of-range edges
        we1_d = max(we1-D.utt_t1,0); %positive for out-of-range edges

        we0 = we0+we0_d-we1_d;
        we1 = we1+we0_d-we1_d;     

        %second, extend away from closest boundary if overlap
        overlap_dur = ((we0<D.rateunit_t1) & (we1>=D.rateunit_t0)) .* (min(we1,D.rateunit_t1)-max(we0,D.rateunit_t0));
        isov = overlap_dur>0;

        %closer to utterance beginning
        closest = (we0 - D.utt_t0) > (D.utt_t1 - we1);

        we0 = isov.*(   (min(D.rateunit_t0,we0)-overlap_dur).*closest +  we0                                .*(1-closest)   ) + (1-isov).*we0;
        we1 = isov.*(    we1                                .*closest + (max(D.rateunit_t1,we1)+overlap_dur).*(1-closest)   ) + (1-isov).*we1;            


end


end

