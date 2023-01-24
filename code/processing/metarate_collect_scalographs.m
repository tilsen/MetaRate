function [] = metarate_collect_scalographs()

dbstop if error;

h = metarate_helpers();

ff = rdir([h.regress_dir 'scalogram_*.mat']);

T = [];
for i=1:length(ff)
    status_str = status('progress_full',i,length(ff)); %#ok<NASGU> 
    X = load(ff(i).name);
    T = [T; X.T];
end
status('reset');

T.sizes = T.scale; T.scale = [];

%utility functions:

sc_pars_in = {'target','rate_measure','inverse_rate','data_selection','window_method','target_exclusion'};
sc_pars_out = {'target','unit','inversion','datasel','winmethod','exclusion'};

for i=1:length(sc_pars_out)
    if ~strcmp(sc_pars_out{i},sc_pars_in{i})
        T.(sc_pars_out{i}) = T.(sc_pars_in{i});
        T.(sc_pars_in{i}) = [];
    end
end

PAR.RHO = grpstats(T,sc_pars_out,{'min','max'},'Datavars','rho');

for i=1:length(sc_pars_out)
    PAR.(sc_pars_out{i}) = unique(T.(sc_pars_out{i}));
end

PAR.index = @(T,target,unit,inversion,datasel,winmethod,exclusion)...
    T( ...
    ismember(T.target,target) &...
    ismember(T.unit,unit) & ...
    ismember(T.inversion,inversion) & ...
    ismember(T.datasel,datasel) & ...
    ismember(T.winmethod,winmethod) & ...
    ismember(T.exclusion,exclusion),:);

PAR.select = @(T,name)strjoin(unique(T.(name)),',');

T.Properties.UserData = PAR;

save([h.data_dir 'metarate_partialcorr_scalographs.mat'],'T');

end