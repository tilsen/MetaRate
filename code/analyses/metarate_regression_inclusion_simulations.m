function [] = metarate_regression_inclusion_simulations()

dbstop if error;
h = metarate_helpers;

S=[];
for Ns=3:2:21
    status_str = status(sprintf('simulating utterances with %i words...',Ns)); %#ok<NASGU> 
    s = run_sim(Ns);
    S = [S; s];
end
status('reset');

S = struct2table(S);

save([h.figures_dir 'regression_inclusion_simulations.mat'],'S');

end

%%
function [S,R] = run_sim(Ns)

S.Ns = Ns;

%Ns = 7;        % number of segments
N = 10000;     % number of datapoints
Nreps = 200;   % number of reps
sigma = 0.025;
targ_ix = ceil(Ns/2);
nontarget_ixs = setdiff(1:Ns,targ_ix);

mu = 0;
rate_effect = 1;
cl_effect = 0.05;

%segment classes
cl = zeros(N,Ns);
cl(1:2:end,targ_ix) = 1/2;
cl(2:2:end,targ_ix) = -1/2;
D.cl = cl;

D = struct2table(D);

rate_lims = [0.2 0.4]; %seconds/unit



%%
for i=1:Nreps

    %generate underlying rates
    D.sr = rate_lims(1)+diff(rate_lims)*rand(N,1);

    %segment durations
    D.dur = mu + cl_effect*D.cl + rate_effect*D.sr + sigma*randn(N,Ns);

    %empirical rates    
    D.rate_excl = mean(D.dur(:,nontarget_ixs),2);
    D.rate_incl = mean(D.dur,2);    

    D.targ_dur = D.dur(:,targ_ix);
    D.targ_cl = D.cl(:,targ_ix);

    %
    lm_excl = fitlm(D,'targ_dur ~ -1 + rate_excl + targ_cl');
    lm_incl = fitlm(D,'targ_dur ~ -1 + rate_incl + targ_cl');   
    lm_excl0 = fitlm(D,'targ_dur ~ -1 + rate_excl');
    lm_incl0 = fitlm(D,'targ_dur ~ -1 + rate_incl');       

    R(i).coeffs_excl = lm_excl.Coefficients.Estimate';
    R(i).coeffs_incl = lm_incl.Coefficients.Estimate';
    R(i).Rsq_excl = lm_excl.Rsquared.Adjusted;
    R(i).Rsq_incl = lm_incl.Rsquared.Adjusted;   
    R(i).AIC_excl = lm_excl.ModelCriterion.AIC;
    R(i).AIC_incl = lm_incl.ModelCriterion.AIC;
    R(i).AIC_excl0 = lm_excl0.ModelCriterion.AIC;
    R(i).AIC_incl0 = lm_incl0.ModelCriterion.AIC;    
    R(i).pcorr_excl = partialcorri(D.targ_dur,D.rate_excl,D.targ_cl);
    R(i).pcorr_incl = partialcorri(D.targ_dur,D.rate_incl,D.targ_cl);
    R(i).corr_rate_excl = corr(D.sr,D.rate_excl);
    R(i).corr_rate_incl = corr(D.sr,D.rate_incl);
    R(i).corr_rate_class_excl = corr(D.targ_cl,D.rate_excl);
    R(i).corr_rate_class_incl = corr(D.targ_cl,D.rate_incl);
    
end

R = struct2table(R);

R.Rsq = [R.Rsq_incl R.Rsq_excl];
R.AIC = [R.AIC_incl R.AIC_excl];
R.AIC0 = [R.AIC_incl0 R.AIC_excl0];
R.dAIC = R.AIC-R.AIC0;
R.pcorr = [R.pcorr_incl R.pcorr_excl ];
R.intercept = [R.coeffs_incl(:,1) R.coeffs_excl(:,1)];
R.ratecoef = [R.coeffs_incl(:,end-1) R.coeffs_excl(:,end-1)];
R.classcoef = [R.coeffs_incl(:,end) R.coeffs_excl(:,end)];
R.corr_rate = [R.corr_rate_incl R.corr_rate_excl];
R.corr_rate_class = [R.corr_rate_class_incl R.corr_rate_class_excl];


vars = {'Rsq','AIC','AIC0','dAIC','corr_rate','pcorr','ratecoef','classcoef','intercept','corr_rate_class'};
for i=1:length(vars)
    S.(vars{i}) = mean(R.(vars{i}));
    S.([vars{i} '_sd']) = std(R.(vars{i}));    
end


end