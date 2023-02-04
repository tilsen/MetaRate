function [R,ds] = metarate_scalographic_analysis(TR,D,varargin)

dbstop if error;
p = inputParser;

def_data_selection = 'bytarget';
def_window_method = 'centered';
def_inverse_rate = 2;
def_target_exclusion = true;
def_target_ident_field = 'phones';
def_unit = 'phones';
def_frame_per = 1e-3;
def_scale_range = nan;
def_center_range = nan;
def_center_step = 0.025;
def_scale_step = 0.050;
def_target_variable = 'dur';
def_return_datasets = false;
def_use_parallel = false;
def_n_threads = 6;

valid_data_selections = {
    'bywindow' 
    'bytarget'};

valid_window_methods = {
    'centered'
    'beginanchored' 
    'endanchored'
    'example1' 
    'example2'
    'extendwin'
    'adaptivewin'};

addRequired(p,'TR',@(x)istable(x));
addRequired(p,'D',@(x)istable(x));
addParameter(p,'data_selection',def_data_selection,@(x)ismember(x,valid_data_selections));
addParameter(p,'inverse_rate',def_inverse_rate,@(x)ismember(x,[0 1 2]));
addParameter(p,'target_exclusion',def_target_exclusion,@(x)islogical(x));
addParameter(p,'window_method',def_window_method,@(x)ismember(x,valid_window_methods));
addParameter(p,'unit',def_unit,@(x)validate_unit(x,tabcols(TR),tabcols(D)));
addParameter(p,'frame_per',def_frame_per);
addParameter(p,'center_range',def_center_range);
addParameter(p,'scale_range',def_scale_range);
addParameter(p,'center_step',def_center_step);
addParameter(p,'scale_step',def_scale_step);
addParameter(p,'target_variable',def_target_variable);
addParameter(p,'target_ident_field',def_target_ident_field);
addParameter(p,'return_datasets',def_return_datasets); %only works with use_parallel=false
addParameter(p,'use_parallel',def_use_parallel);
addParameter(p,'n_threads',def_n_threads);

parse(p,TR,D,varargin{:});

res = p.Results;
res.D=[]; %dont need this
res.TR=[];

dt = res.frame_per;

switch(p.Results.use_parallel)
    case 1
        poolobj = gcp('nocreate');
        if isempty(poolobj), poolobj = parpool(p.Results.n_threads); end %#ok<NASGU> 
end

%% add rate unit times:
D.rateunit_t0 = D.([p.Results.unit '_t0']);
D.rateunit_t1 = D.([p.Results.unit '_t1']);            
D.rateunit_dur = D.rateunit_t1-D.rateunit_t0;

%% check for compatibility of data selection method
switch(p.Results.data_selection)
    case {'extendwin' 'adaptivewin'}
        if ~p.Results.target_exclusion
            fprintf('ERROR: data selection method: %s should only be used with target exclusion\n',p.Results.data_selection);
            R=[]; ds=[];
            return;
        end
end

%% define window scales/centers for different data selection methods
switch(res.window_method)

    %centered method (default)
    case 'centered'            
        switch(res.data_selection)
            case 'bywindow'
                scale_range = [0.05 1.5];
                center_range = [-1 1];
            case 'bytarget'
                scale_range = [0.05 1];
                center_range = [-0.5 0.5];
        end
        
    %ends of windows anchored to beginnings of target units
    case 'endanchored'                  
        scale_range = [0.05 1.0];
        center_range = [-1.0 0];        %up to 1.5 sec before unit
        
    %beginnings of windows anchored to ends of target unit
    case 'beginanchored'                
        scale_range = [0.05 1.0];
        center_range = [0 1.0];         %up to 1.5 sec after unit

    %to get data for illustrating regressions    
    case 'example1'
        scale_range = [0.50 0.50];
        center_range = [-0.25 0.25];   

    case 'example2'
        scale_range = [0.50 0.50];
        center_range = [-0.5 0];  

    %extends the window edges to compensate for exclusion (d/n make sense with inclusion)   
    case 'extendwin'
        scale_range = [0.05 1.0];
        center_range = [-0.5 0.5];  

    %extends range to compensate for exclusion and shifts center if
    %necessary (d/n discard tokens in utterances smaller than window scale)
    case 'adaptivewin' 
        scale_range = [0.5 floor(max(TR.utt_dur)/0.5)*0.5];
        center_range = [-0.5 0.5];
        res.scale_step = 0.200;
        res.center_step = 0.100;

end

%overwrite scale/center range parameters if not specified
if isnan(res.scale_range)
    res.scale_range = scale_range;
end
if isnan(res.center_range)
    res.center_range = center_range;
end

WIN = metarate_construct_windows(p.Results.data_selection, ...
    res.scale_range,res.center_range, ...
    'scale_step',res.scale_step, ...
    'center_step',res.center_step);

%% prepare data table

%add trial indices to data table:
[~,D.TRix] = ismember(D.fname,TR.fname);

D = D(:,{'t0' 't1' 'rateunit_t0' 'rateunit_t1' 'utt_t0' 'utt_t1' ...
    'TRix' res.target_ident_field 'subj' res.target_variable});

%round to avoid precision errors
timef = {'t0' 't1' 'rateunit_t0' 'rateunit_t1' 'utt_t0' 'utt_t1'};
for i=1:length(timef)
    D.(timef{i}) = round(D.(timef{i}),6);
end

%midpoint of target phone
D.tmid = (D.t0+D.t1)/2;

%dur of rate unit (for extendwin method)
D.rateunit_dur = (D.rateunit_t1-D.rateunit_t0);

%anchorpoint for pre-exclusion:
switch(res.data_selection)
    case 'beginanchored'
        D.tanch = D.rateunit_t1;

    case 'endanchored'
        D.tanch = D.rateunit_t0;

    otherwise
        D.tanch = D.tmid;
end

%% get proportional duration array

%fieldnames specific to rate measure units:
f_pdur = [p.Results.unit '_pdur'];

%times of frames (for data rows): 
FRT = TR.frt(D.TRix);

%avoids precision errors
FRT = cellfun(@(c){round(c,6)},FRT);

%proportional durations (for data rows): 
PDUR = TR.(f_pdur)(D.TRix);
Nr = size(PDUR,1);

%% handle utterance edges

% set pre-/post-utterance intervals to Inf/NaN (associated with init/final sp)
IXs_out_of_range = cellfun(@(c,d,e){c<d | c>=e},FRT,num2cell(D.utt_t0),num2cell(D.utt_t1));

switch(p.Results.window_method)
    case 'adaptivewin' %for this method we set out-of-utterance samples to nan,
        %so that no data are excluded if the window is larger than the
        %utterance:
        for i=1:length(PDUR)
            PDUR{i}(IXs_out_of_range{i}) = nan;
        end

    otherwise %for all other methods we set out-of-utterance samples to inf, 
        % so that targets will be excluded:
        for i=1:length(PDUR)
            PDUR{i}(IXs_out_of_range{i}) = inf;
        end
end

%% handle target exclusion:
switch(p.Results.target_exclusion)
    case true  %under target exclusion we set the rate-unit portion of
         % the proportional duration timeseries to nan so that it is not
         % counted:
     D.rateunit_t0_ix = ceil(D.rateunit_t0/dt)+1;   
     D.rateunit_t1_ix = floor(D.rateunit_t1/dt);  

     for i=1:length(PDUR) 
         PDUR{i}(D.rateunit_t0_ix(i):D.rateunit_t1_ix(i)) = nan;
     end

end

%convert prop.dur array to matrix:
lens = max(unique(cellfun('length',PDUR)));
PDUR = cellfun(@(c){[c nan(1,lens-length(c))]},PDUR);
PDUR = cell2mat(PDUR);

zero_sample = 1; %keep track of time=0 sample.

%% calculate all absolute window edges
[we0,we1] = metarate_data_window_edges(D,WIN,p.Results.window_method);

%% exclude datapoints if selection method is bytarget
switch(p.Results.data_selection)
    case 'bytarget'
        valid_win = all(we0>=D.utt_t0 & we1<D.utt_t1,2);
        D = D(valid_win,:);
        we0 = we0(valid_win,:);
        we1 = we1(valid_win,:);
        PDUR = PDUR(valid_win,:);
end

%% matrix of proportional duration timepoints
pdur_times = (0:(size(PDUR,2)-1))*p.Results.frame_per;
pdur_times = pdur_times-pdur_times(zero_sample);
pdur_times = repmat(pdur_times,height(D),1);

%% run analyses

switch(p.Results.inverse_rate)
    case 2
        rr = repmat({[]},height(WIN),2);    
        inv_ixs = 0:1;
    case 1
        rr = repmat({[]},height(WIN),1);
        inv_ixs = 0;
    case 0
        rr = repmat({[]},height(WIN),1);      
        inv_ixs = 1;
end

if p.Results.return_datasets
    ds = cell(height(WIN),1);
end

%cell array of inputs to partial correlation function
Da = table2cell(D(:,{res.target_variable, res.target_ident_field, 'subj'}));

%loop over windows
switch(p.Results.use_parallel)
    case 1
        Nw = height(WIN);
        Nr = height(D);
        rx1 = repmat({[]},Nw,1);
        rx2 = repmat({[]},Nw,1);
        not_nan = false(Nw,Nr);
        not_inf = false(Nw,Nr);
        valid_ixs = false(Nw,Nr);
        scales = WIN.scale;
        centers = WIN.center;
        res = p.Results;        

        parfor w=1:height(WIN)
            win = metarate_propdur_windows(we0(:,w),we1(:,w),pdur_times);
            [rx1{w},rx2{w},not_nan(w,:),not_inf(w,:),valid_ixs(w,:)] = calc_rates(PDUR.*win,dt);
        end

        for w=1:height(WIN)
            rr{w,1} = partialcorr_rate(Da(valid_ixs(w,:),:),rx1{w}(valid_ixs(w,:)));
            rr{w,2} = partialcorr_rate(Da(valid_ixs(w,:),:),rx2{w}(valid_ixs(w,:)));

            rr{w,1} = add_info(rr{w,1},scales(w),centers(w),not_nan(w,:),not_inf(w,:),res,0);
            rr{w,2} = add_info(rr{w,2},scales(w),centers(w),not_nan(w,:),not_inf(w,:),res,1);         
        end

    case 0

        RR = {};
        for w=1:height(WIN)

            win = metarate_propdur_windows(we0(:,w),we1(:,w),pdur_times);

            [RR{1},RR{2},not_nan,not_inf,valid_ixs] = calc_rates(PDUR.*win,dt);

            for i=1:length(inv_ixs)
                rx = partialcorr_rate(Da(valid_ixs,:),RR{inv_ixs(i)+1}(valid_ixs));
                rr{w,i} = add_info(rx,WIN.scale(w),WIN.center(w),not_nan,not_inf,res,inv_ixs(i));                
            end

            if p.Results.return_datasets
                ds{w} = D(:,{res.target_variable res.target_ident_field 'subj'});
                ds{w}.valid_ixs = valid_ixs;
                ds{w}.not_nan = not_nan;
                ds{w}.not_inf = not_inf;
                ds{w}.rate_proper = RR{1};
                ds{w}.rate_inverse = RR{2};
            end

        end
end

R = struct2table(vertcat(rr{:}));

end

%% calculate rates from pdur
function [rates_proper,rates_inverse,not_nan,not_inf,valid_ixs] = calc_rates(pdur,dt)
PDUR_sum = nansum(pdur,2);                              %#ok<NANSUM> %sum of proportional durs in window
PDUR_per = sum(~isnan(pdur) & ~isinf(pdur),2)*dt;        %actual period of time in window

rates_proper = PDUR_sum ./ PDUR_per;
rates_inverse = 1./rates_proper;

not_nan = ~isnan(rates_proper);
not_inf = ~isinf(rates_inverse) & ~isinf(rates_proper);
valid_ixs = not_nan & not_inf;
end

%%
function [valid] = validate_unit(unit,segf,dataf)
valid = ...
    (ismember([unit '_t0'],dataf) & ismember([unit '_t1'],dataf));

if ~valid
    fprintf('ERROR: containing rate unit times must be specified in target data table\n');
    return;
end

valid = (ismember([unit '_pdur'],segf));

if ~valid
    fprintf(['ERROR: utterance segmentation table must contain field of ' ...
        'proportional durations named %s_pdur\n'],unit);
    return;
end

end

%%
function [R] = add_info(R,scale,center,not_nan,not_inf,res,inversion)

R.unit = res.unit;
R.target = res.target_ident_field;
R.scale = scale;
R.center = center;
R.winmethod = res.window_method;
R.datasel = res.data_selection;
R.exclusion = res.target_exclusion;
R.inversion = inversion;
R.N_tokens = numel(not_nan);
R.N_inf = sum(~not_inf);
R.N_nan = sum(~not_nan);
R.N_valid = sum(not_inf & not_nan);

end


%%
function [R] = partialcorr_rate(Dvars,RATES)
ID = dummyvar(categorical(Dvars(:,2)));
SU = dummyvar(categorical(Dvars(:,3)));
[R.rho,R.pval] = partialcorri(vertcat(Dvars{:,1}),RATES,[SU ID]);
end
