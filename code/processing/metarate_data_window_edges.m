function [we0,we1] = metarate_data_window_edges(D,W,method)

%given a data table, window specifications table, and method parameters,
%generates a matrices of window edge times for each datapoint

if nargin==2, method = ''; end

%% specified windows in absolute times
we0 = D.tanch + W.edges(:,1)';
we1 = D.tanch + W.edges(:,2)';

%% calculate excluded dur for each window for some methods
switch(method)
    case {'extendwin','adaptivewin'}

        excluded_dur = (we1-we0) - ...
            max(0,D.rateunit_t0-we0) - ...
            max(0,we1-D.rateunit_t1);

end

%% do extension for some methods
switch(method)
    case {'extendwin','adaptivewin'}

        %overlap conditions for left/right edge adjustments:
        ext0 = (we0 > D.rateunit_t0) & (we0 < D.rateunit_t1);
        ext1 = (we1 > D.rateunit_t0) & (we1 < D.rateunit_t1);

        we0 = ext0.*(D.rateunit_t0 - excluded_dur/2) + (1-ext0).*(we0-excluded_dur/2); 
        we1 = ext1.*(D.rateunit_t1 + excluded_dur/2) + (1-ext1).*(we1+excluded_dur/2); 

end

%% adaptive window
switch(method)

    case 'adaptivewin'

        utt_t0 = repmat(D.utt_t0,1,size(we0,1));
        utt_t1 = repmat(D.utt_t1,1,size(we0,1));

        %determine whether extended window extends beyond utterance edges:
        we0_d = max(0,utt_t0-we0); %positive for out-of-range edges
        we1_d = max(we1-utt_t1,0); %positive for out-of-range edges

        % even if the window is larger than available utterance,
        % d/n matter what order the adjustments are done, b/c this method d/n
        % exclude data on the basis of out of range windows:
        we0 = we0+we0_d-we1_d;
        we1 = we1+we0_d-we1_d;
       
        %in case shift caused overlap, we extend asymmetrically:

        %overlap conditions for left/right edge adjustments:
        ext0 = (we0 >= D.rateunit_t0) & (we0 < D.rateunit_t1);
        ext1 = (we1 >= D.rateunit_t0) & (we1 < D.rateunit_t1);

        overlap_dur = max(0,we0-D.rateunit_t0).*ext0 + max(0,D.rateunit_t1-we1).*ext1;        

        we0 = ext0.*(D.rateunit_t0 - overlap_dur) + (1-ext0).*we0; 
        we1 = ext1.*(D.rateunit_t1 + overlap_dur) + (1-ext1).*we1; 

end


end

