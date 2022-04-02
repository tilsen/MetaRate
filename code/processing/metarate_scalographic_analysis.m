function [R,ds] = metarate_scalographic_analysis(TR,D,varargin)

dbstop if error;
h = metarate_helpers();
p = inputParser;

def_data_selection = 'bytarget';
def_inverse_rate = 2;
def_target_exclusion = true;
def_unit = 'phones';
def_frame_per = 1e-3;
def_center_step = 0.025;
def_scale_step = 0.050;
def_target_variable = 'dur';
def_return_datasets = false;

valid_data_selections = {
    'bywindow' 
    'bytarget' 
    'beginanchored' 
    'endanchored'
    'example1' 
    'example2'};

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
addParameter(p,'return_datasets',def_return_datasets);

parse(p,TR,D,varargin{:});

dt = p.Results.frame_per;

%% calculate window scales/centers for different data selection methods
switch(p.Results.data_selection)
    case 'bywindow'                     %use all data that fits in given window
        scale_range = [0.05 1.5];
        center_range = [-1 1];
        
    case 'bytarget'                     %(="across-window" strategy) only include data that fits in all windows 
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
end

WIN = metarate_construct_windows(p.Results.data_selection,...
    'scale_range',scale_range,'center_range',center_range);

[D,WIN] = metarate_match_data_windows(D,WIN);

%% setup proportional duration arrays

%add trial indices to data table:
D.TRix = cellfun(@(c)find(ismember(TR.fname,c)),D.fname);

%fieldnames specific to rate measure units:
f_pdur = [p.Results.unit '_ufr_prop_dur'];

%times of frames (for data rows): 
FRT = TR.frt(D.TRix);

%proportional durations (for data rows): 
PDUR = TR.(f_pdur)(D.TRix);
Nr = size(PDUR,1);

%target type
if ismember('phone',D.Properties.VariableNames)
    target_type = 'phone';
    target_identf = 'phone';
elseif ismember('sylb',D.Properties.VariableNames)
    target_type = 'sylb';
    target_identf = 'sylb_form';
end

rateunit_ufr_map = [p.Results.unit '_ufr_map'];
rateunit_identf = [p.Results.unit(1:end-1) '_ix'];

%% handle target exclusion:
switch(p.Results.target_exclusion)
    case true  

        %must exclude entire unit (used as rate measure) containing target unit 

        MAP = TR.(rateunit_ufr_map)(D.TRix); %contains by-frame unit indices for each data row

        if ~iscell(D.(rateunit_identf))
            ix_rem = cellfun(@(c,d){c==d},MAP,num2cell(D.(rateunit_identf))); %frames to be ignored for each data row
        else
            ix_rem = cellfun(@(c,d){ismember(c,d)},MAP,D.(rateunit_identf)); %frames to be ignored for each data row
        end

        % set pdur to NaN
        for i=1:Nr
            PDUR{i}(ix_rem{i}) = nan;
        end
end

% set pre-/post-utterance pdur to NaN (associated with init/final sp)
IXs_out_of_range = cellfun(@(c,d,e){c<d | c>e},FRT,num2cell(D.utt_t0),num2cell(D.utt_t1));
for i=1:Nr
    PDUR{i}(IXs_out_of_range{i}) = nan;
end

%% convert proportional duration arrays to target-aligned matrices

pad_samples = max(ceil(1.1*abs(center_range/dt))); %add exactly this many nan samples at beginning and end

pdur_lens = cellfun(@(c)length(c),PDUR);
max_len = max(pdur_lens); %maximum length

%end-pad to longest signal length
PDUR = cell2mat(cellfun(@(c){[c nan(1,max_len-length(c))]},PDUR)); 

%begin- and end-pad:
PDUR = [single(nan(size(PDUR,1),pad_samples)) PDUR single(nan(size(PDUR,1),pad_samples))]; 

%ix of frame that is tanch in padded signal
ix_fr_tanch = floor(D.tanch/dt)+pad_samples;

%logical indices of samples to keep centered on tanch
sampix = 1:size(PDUR,2);
ix_aligned = arrayfun(@(c){ismember(sampix,(c-pad_samples):(c+pad_samples))},ix_fr_tanch);

%matrix of aligned signals
rowix = (1:Nr)';
PDUR = cell2mat(arrayfun(@(c,d){PDUR(c,d{:})},rowix,ix_aligned));

Nfr = size(PDUR,2);

%% convert windows to indices of proportional duration matrix

WIN.edge_ixs = pad_samples+floor(WIN.edges/dt);
WIN.valid = all(WIN.edge_ixs(:,1)>0 & WIN.edge_ixs(:,2)<Nfr,2);
WIN = WIN(WIN.valid,:);
Nw = height(WIN);

%% run analyses

%array for results structures
switch(p.Results.inverse_rate)
    case {0,1}
        rr = repmat({[]},Nw,1);
    case 2
        rr = repmat({[]},2*Nw,1);
end

%loop over windows
for w=1:Nw
    
    winsc = [WIN.scale(w) WIN.center(w)];
    winsize = WIN.scale(w);
    ixs = WIN.edge_ixs(w,:);
    
    PDUR_win = PDUR(:,ixs(1):ixs(2));             %proportional durs in window
    
    PDUR_sum = nansum(PDUR_win,2);                %#ok<NANSUM> %sum of proportional durs in window
    PDUR_nan = sum(isnan(PDUR_win),2)*dt;         %excluded period in window
    
    rates_proper = PDUR_sum ./ (winsize - PDUR_nan);
    rates_inverse = 1./rates_proper;
    
    not_nan = ~isnan(rates_proper);
    not_inf = ~isinf(rates_inverse) & ~isinf(rates_proper);
    rixs = not_nan & not_inf;
    
    if ~any(rixs), continue; end %skip if no valid data

    VAR = D.(p.Results.target_variable)(rixs);
    RATES_PROPER = rates_proper(rixs);
    RATES_INVERSE = rates_inverse(rixs);
    TARGS = D.(target_identf)(rixs);
    SUBJS = D.subj(rixs);
    
    if p.Results.inverse_rate==0 %only proper
        
        rr{w} = partialcorr_rate(VAR,RATES_PROPER,TARGS,SUBJS);
        rr{w} = add_info(rr{w},winsc,not_nan,not_inf,p.Results,p.Results.inverse_rate,target_type);
        
    elseif p.Results.inverse_rate==1 %only inverse
        
        rr{w} = partialcorr_rate(VAR,RATES_INVERSE,TARGS,SUBJS);
        rr{w} = add_info(rr{w},winsc,not_nan,not_inf,p.Results,p.Results.inverse_rate,target_type);
        
    elseif p.Results.inverse_rate==2 %both
        
        rr{w} = partialcorr_rate(VAR,RATES_PROPER,TARGS,SUBJS);
        rr{w} = add_info(rr{w},winsc,not_nan,not_inf,p.Results,0,target_type);
        
        rr{w+Nw} = partialcorr_rate(VAR,RATES_INVERSE,TARGS,SUBJS);
        rr{w+Nw} = add_info(rr{w+Nw},winsc,not_nan,not_inf,p.Results,1,target_type);
        
    end

    % return input data for each analysis
    if p.Results.return_datasets
        switch(p.Results.inverse_rate)
            case 0
                ds(w,:) = {VAR,RATES_PROPER,TARGS,SUBJS};
            case 1
                ds(w,:) = {VAR,RATES_INVERSE,TARGS,SUBJS};
            case 2
                ds(w,:)    = {VAR,RATES_PROPER,TARGS,SUBJS};
                ds(w+Nw,:) = {VAR,RATES_INVERSE,TARGS,SUBJS};
        end
    end

end

R = struct2table(vertcat(rr{:}));

end

%%
function [R] = add_info(R,win,not_nan,not_inf,res,measinv,target_type)

R.rate_measure = res.unit;
R.target = target_type;
R.scale = win(1);
R.center = win(2);
R.data_selection = res.data_selection;
R.target_exclusion = res.target_exclusion;
R.inverse_rate = measinv;
R.N_tokens = numel(not_nan);
R.N_inf = sum(~not_inf);
R.N_nan = sum(~not_nan);
R.N_valid = sum(not_inf & not_nan);

end


%%
function [R] = partialcorr_rate(DURS,RATES,IDENT,SUBJ)
ID = dummyvar(categorical(IDENT));
SU = dummyvar(categorical(SUBJ));
[R.rho,R.pval] = partialcorri(DURS,RATES,[SU ID]);
end


%all windows
% scales = scale_range(1):p.Results.scale_step:scale_range(2);
% centers = center_range(1):p.Results.center_step:center_range(2);
% win_sc = combvec(scales,centers)';
% WIN.scale = win_sc(:,1);
% WIN.center = win_sc(:,2);
% WIN = struct2table(WIN);
% WIN.edges = WIN.center + WIN.scale*[-1 1]/2;

% %select data
% switch(p.Results.data_selection)
%     case 'bywindow'
%         %handle data selection in analysis loop
%         ix_keep = (1:height(D))';
%         
%     case {'bytarget','beginanchored','endanchored'}
%         %restrict windows to center range:
%         ix_win_keep = WIN.edges(:,1)>=center_range(1) & WIN.edges(:,2)<=center_range(2);
%         WIN = WIN(ix_win_keep,:);
%         
%         %only include data available for all windows
%         ix_keep = (D.tanch+min(WIN.edges(:,1)))>=D.utt_t0 & ...
%                   (D.tanch+max(WIN.edges(:,2)))<=D.utt_t1;
%            
% end
% 
% D = D(ix_keep,:);
