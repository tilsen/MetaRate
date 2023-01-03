function [] = metarate_scalographic_analysis_batch()

h = metarate_helpers;

overwrite = true;
use_parallel = false;

switch(use_parallel)
    case 1
        poolobj = gcp('nocreate');
        if isempty(poolobj), parpool(6); end
end

if ~exist(h.regress_dir,'dir'), mkdir(h.regress_dir); end

%target datasets:
TARGS = metarate_targets;
targets = TARGS.target;

%% analysis parameters
R.unit = {'artics' 'phones' 'moras' 'sylbs' 'words'};
R.target_exclusion = [true false];
R.data_selection = {'adaptivewin','extendwin','bytarget','bywindow','beginanchored','endanchored'};
R.inverse_rate = 2; %(0: proper; 1: inverse; 2: do both in scalograph loop to save time)

%---table of analysis parameter combinations
[unit,target_exclusion,data_selection,inverse_rate] = ndgrid(R.unit,R.target_exclusion,R.data_selection,R.inverse_rate);

P.unit = unit(:);
P.target_exclusion = target_exclusion(:);
P.data_selection = data_selection(:);
P.inverse_rate = inverse_rate(:);

P = struct2table(P);

%%
load([h.data_dir 'metarate_propdurs.mat'],'TR'); %load by-trial phase velocities
for i=1:length(targets)
    
    load_new_target = true;
    for j=1:height(P)
        
        switch(P.target_exclusion(j))
            case 0
                if ismember(P.data_selection{j},{'extendwin','adaptivewin'})
                    continue;
                end
        end

        outfile = sprintf('scalogram_target[%s]_unit[%s]_targexc[%i]_datasel[%s].mat',...
            targets{i}, P.unit{j},double(P.target_exclusion(j)),P.data_selection{j});        
        outfilepath = [h.regress_dir outfile];
        
        if ~overwrite && exist(outfilepath,'file'), continue; end
        
        if load_new_target
            load([h.datasets_dir 'data_' targets{i} '.mat'],'D'); %load target data
            load_new_target = false;
        end
        
        n = (length(targets)-1)*i+j;
        status_str = status('progress_full',n,length(targets)*height(P),['processing ' outfile]); %#ok<NASGU>
                
        tic
        T = metarate_scalographic_analysis(TR,D,...
            'unit',P.unit{j},...
            'target_exclusion',P.target_exclusion(j),...
            'data_selection',P.data_selection{j},...
            'inverse_rate',P.inverse_rate(j), ...
            'use_parallel',use_parallel);

        toc
        
        par = table2struct(P(j,:));
        par.target = targets{i};
        T.target = repmat(targets(i),height(T),1);

        save(outfilepath,'T','par');
        
    end
end

status('reset');

end
