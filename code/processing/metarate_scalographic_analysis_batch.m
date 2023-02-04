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
R.unit = {'phones' 'words' 'sylbs' 'moras' 'artics'};
R.target_exclusion = [true false];
R.window_method = {'extendwin','centered','adaptivewin','beginanchored','endanchored'};
R.data_selection = {'bytarget' 'bywindow'};
R.inverse_rate = 2; %(0: proper; 1: inverse; 2: do both in scalograph loop to save time)

%---table of analysis parameter combinations
[window_method,unit,target_exclusion,data_selection,inverse_rate] = ...
    ndgrid(R.window_method,R.unit,R.target_exclusion,R.data_selection,R.inverse_rate);

P.unit = unit(:);
P.target_exclusion = target_exclusion(:);
P.window_method = window_method(:);
P.data_selection = data_selection(:);
P.inverse_rate = inverse_rate(:);

P = struct2table(P);

%% rule out disallowed combinations:

% adaptive and extended windows must use target exclusion:
P = P(~(ismember(P.window_method,{'adaptivewin','extendwin'}) & ~P.target_exclusion),:);

% begin/end- anchor-windows must use exclusion and by-target data selection:
P = P(~(ismember(P.window_method,{'beginanchored','endanchored'}) & ~P.target_exclusion),:);
P = P(~(ismember(P.window_method,{'beginanchored','endanchored'}) & ~ismember(P.data_selection,{'bytarget'})),:);

% dont use adaptive windows with by-target data selection strategy:
P = P(~(ismember(P.window_method,{'adaptivewin'}) & ismember(P.data_selection,{'bytarget'})),:);

% everything else only use by-target data selection strategy:
P = P(~(~ismember(P.window_method,{'adaptivewin'}) & ismember(P.data_selection,{'bywindow'})),:);

%%
load([h.data_dir 'metarate_propdurs.mat'],'TR'); %load by-trial phase velocities
for i=1:length(targets)
    
    load_new_target = true;
    for j=1:height(P)
        
        outfile = sprintf('scalogram_target[%s]_unit[%s]_targexc[%i]_datasel[%s]_win[%s].mat',...
            targets{i}, P.unit{j},double(P.target_exclusion(j)),P.data_selection{j},P.window_method{j});        
        outfilepath = [h.regress_dir outfile];
        
        if ~overwrite && exist(outfilepath,'file'), continue; end
        
        if load_new_target
            load([h.datasets_dir 'data_' targets{i} '.mat'],'D'); %load target data
            load_new_target = false;
        end
        
        n = (height(P)*(i-1))+j;
        status_str = status('progress_full',n,length(targets)*height(P),['processing ' outfile]); %#ok<NASGU>
                
        T = metarate_scalographic_analysis(TR,D,...
            'unit',P.unit{j},...
            'target_exclusion',P.target_exclusion(j),...
            'window_method',P.window_method{j},...
            'data_selection',P.data_selection{j},...
            'inverse_rate',P.inverse_rate(j), ...
            'use_parallel',use_parallel);
        
        par = table2struct(P(j,:));
        par.target = targets{i};
        T.target = repmat(targets(i),height(T),1);

        save(outfilepath,'T','par');
        
    end
end

status('reset');

end
