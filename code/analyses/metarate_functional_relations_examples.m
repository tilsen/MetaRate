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
        'unit','phones','data_selection',datasets{i},'return_datasets',true);

    %{VAR,RATES,TARGS,SUBJS};

    X.dur = ds{1,1};
    X.rate_prop = ds{1,2};
    X.rate_inv = ds{2,2};
    X.targs = ds{1,3};
    X.subjs = ds{1,4};
    X = struct2table(X);

    %residualize target variable and rates:
    lm_dur = fitlm(X,'dur~targs+subjs');
    lm_prop = fitlm(X,'rate_prop~targs+subjs');
    lm_inv = fitlm(X,'rate_inv~targs+subjs');

    X.dur_resid = double(lm_dur.Residuals.Raw);
    X.rate_prop_resid = double(lm_prop.Residuals.Raw);
    X.rate_inv_resid = double(lm_inv.Residuals.Raw);

    save(outputfile,'X');
    clear('X');
end


end