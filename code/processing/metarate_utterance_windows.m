function [] = metarate_utterance_windows()

h = metarate_helpers;

%% add unit counts to each to utterance
load([h.data_dir 'metarate_segmentdata.mat']);

%number of units
units = setdiff(h.units,'artics');

for i=1:length(units)
    TR.(['nraw_' units{i}]) = cellfun(@(c)length(c),TR.(units{i}));
    TR.(['nsil_' units{i}]) = cellfun(@(c)sum(ismember(c,'sp')),TR.(units{i}));
    TR.(['n_' units{i}]) = TR.(['nraw_' units{i}])-2; 
end

%%
TARGS = metarate_targets;
targets = TARGS.target;

%processing for each target
T = [];
for i=1:length(targets)

    status_str = status(sprintf('%i/%i',i,length(targets))); %#ok<NASGU> 

    load([h.datasets_dir 'data_' targets{i} '.mat'],'D');

    %add utterance indices
    [~,D.utt_ix] = ismember(D.trcode,TR.trcode);    

    %add raw utterance_dur and containing unit durs
    D.utt_dur = D.utt_t1-D.utt_t0;
    for j=1:length(units)
        D.([units{j} '_dur']) = D.([units{j} '_t1'])-D.([units{j} '_t0']);
    end
    
    %determine rate-unit exclusive utterance duration
    for j=1:length(units)

        nunitf = ['n_' units{j}];
        uttdurf = ['utt_dur_rate_' units{j}];
               
        %copy unit numbers
        D.(nunitf) = TR.(nunitf)(D.utt_ix);

        %calculate rate denominator (exclusive), subtracts the
        %containing-rate-unit duration
        D.(uttdurf) = D.utt_dur - D.([units{j} '_dur']);

        for k=0:1 %inversion
            for m=0:1 %exclusion

                T(end+1).target = targets{i};
                T(end).unit = units{j};
                T(end).exclusion = m;
                T(end).inversion = k;

                switch(m)
                    case 0 %inclusion
                        rates = D.(nunitf) ./ D.utt_dur;
                    case 1 %exclusion
                        rates = (D.(nunitf)-1) ./ D.(uttdurf);
                end

                if k==1
                    rates = 1./rates;
                end
                
                R = partialcorr_rate(D.dur,rates,D.phones,D.subj);

                T(end).rho = R.rho;
            end
        end
    end

end
status('reset');

T = struct2table(T);

%%

save([h.data_dir 'metarate_corr_fullutt.mat'],'T');

end


function [R] = partialcorr_rate(DURS,RATES,IDENT,SUBJ)
ID = dummyvar(categorical(IDENT));
SU = dummyvar(categorical(SUBJ));
[R.rho,R.pval] = partialcorri(DURS,RATES,[SU ID]);
end
