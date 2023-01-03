function [R,ds] = metarate_scalographic_analysis(TR,D,varargin)

dbstop if error;
h = metarate_helpers();
p = inputParser;

def_data_selection = 'bytarget';
def_inverse_rate = 2;
def_target_exclusion = true;
def_target_ident_field = 'phone';
def_unit = 'phones';
def_frame_per = 1e-3;
def_center_step = 0.025;
def_scale_step = 0.050;
def_target_variable = 'dur';
def_return_datasets = false;
def_use_parallel = false;
def_n_threads = 6;

valid_data_selections = {
    'bywindow' 
    'bytarget' 
    'beginanchored' 
    'endanchored'
    'example1' 
    'example2'
    'extendwin'
    'adaptivewin'};

valid_units = {'phones' 'moras' 'sylbs' 'words' 'artics'};

addRequired(p,'TR',@(x)istable(x));
addRequired(p,'D',@(x)istable(x));
addParameter(p,'data_selection',def_data_selection,@(x)ismember(x,valid_data_selections));
addParameter(p,'inverse_rate',def_inverse_rate,@(x)ismember(x,[0 1 2]));
addParameter(p,'target_exclusion',def_target_exclusion,@(x)islogical(x));
addParameter(p,'unit',def_unit,@(x)ismember(x,valid_units));
addParameter(p,'frame_per',def_frame_per);
addParameter(p,'center_step',def_center_step);
addParameter(p,'scale_step',def_scale_step);
addParameter(p,'target_variable',def_target_variable);
addParameter(p,'target_ident_field',def_target_ident_field);
addParameter(p,'return_datasets',def_return_datasets); %only works with use_parallel=false
addParameter(p,'use_parallel',def_use_parallel);
addParameter(p,'n_threads',def_n_threads);

parse(p,TR,D,varargin{:});

res = p.Results;

dt = res.frame_per;

D = add_rate_unit_info(D,p);

%% check for compatibility of data selection method
switch(p.Results.data_selection)
    case {'extendwin' 'adaptivewin'}
        if ~p.Results.target_exclusion
            fprintf('ERROR: data selection method: %s should only be used with target exclusion\n',p.Results.data_selection);
            R=[]; ds=[];
            return;
        end
end

%% calculate window scales/centers for different data selection methods
switch(p.Results.data_selection)

    %uses all data that fits in given window
    case 'bywindow'                     
        scale_range = [0.05 1.5];
        center_range = [-1 1];

    %(="across-window" strategy) only include data that fits in all windows 
    case 'bytarget'                     
        scale_range = [0.05 1];
        center_range = [-0.5 0.5];
        
    %ends of windows anchored to beginnings of units, 
    %only include data that fits in all windows 
    case 'endanchored'                  
        scale_range = [0.05 1.0];
        center_range = [-1.0 0];        %up to 1.5 sec before unit
        
    %beginnings of windows anchored to ends of units,
    %only include data that fits in all windows
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
        TR.utt_t0 = cellfun(@(c)c(2),TR.words_t0);
        TR.utt_t1 = cellfun(@(c)c(end-1),TR.words_t1);
        TR.utt_dur = TR.utt_t1-TR.utt_t0;        
        scale_range = [0.05 floor(max(TR.utt_dur)/0.5)*0.5];
        center_range = [-0.5 0.5];

end

WIN = metarate_construct_windows(p.Results.data_selection,...
    'scale_range',scale_range,'center_range',center_range);

[D,WIN] = metarate_match_data_windows(D,WIN);

%% get proportional duration array

%add trial indices to data table:
[~,D.TRix] = ismember(D.fname,TR.fname);

%fieldnames specific to rate measure units:
f_pdur = [p.Results.unit '_ufr_prop_dur'];

%times of frames (for data rows): 
FRT = TR.frt(D.TRix);

%proportional durations (for data rows): 
PDUR = TR.(f_pdur)(D.TRix);
Nr = size(PDUR,1);

% set pre-/post-utterance intervals to NaN (associated with init/final sp)
IXs_out_of_range = cellfun(@(c,d,e){c<d | c>e},FRT,num2cell(D.utt_t0),num2cell(D.utt_t1));

for i=1:Nr
    PDUR{i}(IXs_out_of_range{i}) = nan;
end

%% handle target exclusion:
%removes rateunit from each proportional duration timeseries

switch(p.Results.target_exclusion)
    case true  
     D.rateunit_t0_ix = floor(D.rateunit_t0/dt);   
     D.rateunit_t1_ix = ceil(D.rateunit_t1/dt);  

     %set rate unit interval to inf

     for i=1:Nr
        PDUR{i} = PDUR{i}([1:(D.rateunit_t0_ix(i)-1) (D.rateunit_t1_ix(i)+1):end]);
     end

end

%convert prop.dur array to matrix:
lens = max(unique(cellfun('length',PDUR)));
PDUR = cellfun(@(c){[c nan(1,lens-length(c))]},PDUR);
PDUR = cell2mat(PDUR);

zero_sample = 1; %keep track of time=0 sample.

pad_samples = ceil(size(PDUR,2)/2); %add exactly this many nan samples at beginning and end

%begin- and end-pad:
PDUR = [single(nan(size(PDUR,1),pad_samples)) PDUR single(nan(size(PDUR,1),pad_samples))]; 

zero_sample = zero_sample+pad_samples;

%% choose window anchor
switch(p.Results.data_selection)
    case 'beginanchored'
        D.t_anch = D.t1;
    case 'endanchored'
        D.t_anch = D.t0;
    case 'adaptivewin'
        D.t_anch = (D.we0+D.we1)/2;
    otherwise
        D.t_anch = D.tmid;
end

%% centers proportion duration signals on t_anch
anch_samples = arrayfun(@(c)floor(c/dt),D.t_anch)+zero_sample;
center_sample = ceil(size(PDUR,2)/2);
shifts = anch_samples-center_sample;

%anchorpoint is center_sample
Nfr = size(PDUR,2);
for i=1:Nfr
    PDUR(i,:) = circshift(PDUR(i,:),-shifts(i));
end

%% prepare windows that multiply proportional duration matrix

%update window edge indices to reflect signal-centering in previous block
WIN.edge_ixs = center_sample+floor(WIN.edges/dt); 

%remove unnecessary right-edge samples of proportional dur:
max_ix = max(WIN.edge_ixs(:,2));
PDUR = PDUR(:,1:max_ix);

%remove unnecessary left-edge samples:
min_ix = min(WIN.edge_ixs(:,1));
PDUR = PDUR(:,min_ix:end);
center_sample = center_sample-(min_ix-1);
WIN.edge_ixs = center_sample+floor(WIN.edges/dt); %update edge indices again

%select only valid windows
Nfr = size(PDUR,2);
WIN.valid = all(WIN.edge_ixs(:,1)>0 & WIN.edge_ixs(:,2)<=Nfr,2);

switch(p.Results.data_selection)
    case 'adaptivewin'
        if any(~WIN.valid)
            fprintf('ERROR: unexpected invalid windows in adaptivewin method\n');
            return;
        end    
end

WIN = WIN(WIN.valid,:);
Nw = height(WIN);
WIN.samp_ixs = single(nan(height(WIN),size(PDUR,2)));
for i=1:height(WIN)
    WIN.samp_ixs(i,WIN.edge_ixs(i,1):WIN.edge_ixs(i,2)) = 1;
end

%% run analyses

switch(p.Results.inverse_rate)
    case 2
        rr = repmat({[]},Nw,2);
        ds = repmat({[]},Nw,2);        
        inv_ixs = 0:1;
    case 1
        rr = repmat({[]},Nw,1);
        ds = repmat({[]},Nw,1);
        inv_ixs = 0;
    case 0
        rr = repmat({[]},Nw,1);
        ds = repmat({[]},Nw,1);        
        inv_ixs = 1;
end

Da = table2cell(D(:,{res.target_variable, res.target_ident_field, 'subj'}));

%proportional durations for each window

switch(p.Results.use_parallel)
    case 1
        poolobj = gcp('nocreate');
        if isempty(poolobj), poolobj = parpool(p.Results.n_threads); end
end

%loop over windows
switch(p.Results.use_parallel)
    case 1
        rx1 = repmat({[]},Nw,1);
        rx2 = repmat({[]},Nw,1);
        not_nan = false(Nw,Nr);
        not_inf = false(Nw,Nr);
        valid_ixs = false(Nw,Nr);
        samp_ixs = WIN.samp_ixs;
        scales = WIN.scale;
        centers = WIN.center;
        res = p.Results;

        parfor w=1:height(WIN)
            [rx1{w},rx2{w},not_nan(w,:),not_inf(w,:),valid_ixs(w,:)] = calc_rates(PDUR.*samp_ixs(w,:),dt);
        end

        for w=1:height(WIN)
            rr{w,1} = partialcorr_rate(Da(valid_ixs(w,:),:),rx1{w}(valid_ixs(w,:)));
            rr{w,2} = partialcorr_rate(Da(valid_ixs(w,:),:),rx2{w}(valid_ixs(w,:)));
        end

        for w=1:height(WIN)
            rr{w,1} = add_info(rr{w,1},scales(w),centers(w),not_nan(w,:),not_inf(w,:),res,0);
            rr{w,2} = add_info(rr{w,2},scales(w),centers(w),not_nan(w,:),not_inf(w,:),res,1);         
        end

    case 0

        RR = {};
        for w=1:height(WIN)
            [RR{1},RR{2},not_nan,not_inf,valid_ixs] = calc_rates(PDUR.*WIN.samp_ixs(w,:),dt);

            for i=1:length(inv_ixs)
                rx = partialcorr_rate(Da(valid_ixs,:),RR{inv_ixs(i)+1}(valid_ixs));

                rr{w,i} = add_info(rx,WIN.scale(w),WIN.center(w),not_nan,not_inf,res,inv_ixs(i));

                if p.Results.return_datasets
                    ds{2*(w-1)+i} = {...
                        D.(res.target_variable)(valid_ixs),...
                        rates_proper(valid_ixs),...
                        D.(res.target_ident_field)(valid_ixs),...
                        D.subj(valid_ixs)};
                end
                
            end

        end
end

R = struct2table(vertcat(rr{:}));

end

%% calculate rates from pdur
function [rates_proper,rates_inverse,not_nan,not_inf,valid_ixs] = calc_rates(pdur,dt)
PDUR_sum = nansum(pdur,2);                %#ok<NANSUM> %sum of proportional durs in window
PDUR_per = sum(~isnan(pdur),2)*dt;        %actual period of time in window

rates_proper = PDUR_sum ./ PDUR_per;
rates_inverse = 1./rates_proper;

not_nan = ~isnan(rates_proper);
not_inf = ~isinf(rates_inverse) & ~isinf(rates_proper);
valid_ixs = not_nan & not_inf;
end

%%
function [D] = add_rate_unit_info(D,p)

switch(p.Results.unit)
    case 'phones'
        D.rateunit_t0 = D.t0;
        D.rateunit_t1 = D.t1;
    otherwise
        D.rateunit_t0 = D.([p.Results.unit(1:end-1) '_t0']);
        D.rateunit_t1 = D.([p.Results.unit(1:end-1) '_t1']);
end

D.rateunit_dur = D.rateunit_t1-D.rateunit_t0;

end


%%
function [R] = add_info(R,scale,center,not_nan,not_inf,res,inversion)

R.rate_measure = res.unit;
R.target = {''}; %fill in later
R.scale = scale;
R.center = center;
R.data_selection = res.data_selection;
R.target_exclusion = res.target_exclusion;
R.inverse_rate = inversion;
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
