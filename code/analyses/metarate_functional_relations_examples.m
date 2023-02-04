function [] = metarate_functional_relations_examples()

dbstop if error;
h = metarate_helpers;

overwrite_data = true;

load([h.datasets_dir 'data_consonants_codas.mat'],'D'); %load target data
load([h.data_dir 'metarate_propdurs.mat'],'TR'); %load by-trial phase velocities

datasets = {'example1','example2'};

for i=1:length(datasets)

    outputfile = [h.figures_dir datasets{i} '_data.mat'];
    if exist(outputfile,'file') && ~overwrite_data, continue; end

    [R,ds] = metarate_scalographic_analysis(TR,D,...
        'unit','phones', ...
        'window_method',datasets{i}, ...
        'return_datasets',true, ...
        'data_selection','bytarget');

    %{VAR,RATES,TARGS,SUBJS};

    X = ds{1};
    X = X(X.valid_ixs,:);

    %residualize target variable and rates:
    lm_dur = fitlm(X,'dur~1+phones+subj');
    lm_prop = fitlm(X,'rate_proper~1+phones+subj');
    lm_inv = fitlm(X,'rate_inverse~1+phones+subj');

    X.dur_resid = double(lm_dur.Residuals.Raw);
    X.rate_prop_resid = double(lm_prop.Residuals.Raw);
    X.rate_inv_resid = double(lm_inv.Residuals.Raw);

    save(outputfile,'X');
    clear('X');
end


end