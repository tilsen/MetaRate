function [] = metarate_collect_scalographs()

dbstop if error;

h = metarate_helpers();

ff = rdir([h.regress_dir 'scalogram_*.mat']);

T = [];
for i=1:length(ff)
    X = load(ff(i).name);
    target = regexp(ff(i).name,'_target\[(\w+)\]_','tokens','once');
    X.T.target = repmat(target,height(X.T),1);
    T = [T; X.T];
end

T.sizes = T.scale; T.scale = [];

%utility functions:

PAR.RHO = grpstats(T,{'target','rate_measure','inverse_rate','data_selection','target_exclusion'},{'min','max'},'Datavars','rho');
PAR.targets = unique(T.target);
PAR.rate_measures = unique(T.rate_measure);
PAR.inverse_rate = unique(T.inverse_rate);
PAR.target_exclusion = unique(T.target_exclusion);
PAR.data_selection = unique(T.data_selection);

PAR.index = @(T,targets,rate_measures,inverse_rate,target_exclusion,data_selection)...
    T(ismember(T.target,targets) &...
    ismember(T.rate_measure,rate_measures) & ...
    ismember(T.inverse_rate,inverse_rate) & ...
    ismember(T.target_exclusion,target_exclusion) & ...
    ismember(T.data_selection,data_selection),:);

PAR.select = @(T,name)strjoin(unique(T.(name)),',');

T.Properties.UserData = PAR;

save([h.data_dir 'metarate_partialcorr_scalographs.mat'],'T');

end