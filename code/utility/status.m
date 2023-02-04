function [status_str] = status(status_str,varargin)

status_exists = evalin('caller','exist(''status_str'',''var'')');

%% no input: clear:
if nargin==0
    if status_exists
        len_status = evalin('caller','length(status_str)');
        fprintf(repmat('\b',1,len_status));
        evalin('caller','clear(''status_str'')');        
    end
    return;
end

%% bare string input
if nargin==1 && ~ismember(status_str,{'clear' 'reset'})
    if status_exists
        len_status = evalin('caller','length(status_str)');
        fprintf(repmat('\b',1,len_status));
    end
    fprintf(status_str);
    return;
end

%% other modes
if status_exists
    len_status = evalin('caller','length(status_str)');
else
    len_status = 0;
end

%parse extra arguments
if numel(varargin)>=2
    iter = varargin{1};
    total = varargin{2};
else
    iter = nan;
    total = nan;
end

descr_str = 'processing:';
if numel(varargin)>=3
    descr_str = [varargin{3} ' '];
end

%start tic if necessary
tic_exists = evalin('caller','exist(''progress_tic'',''var'')');
time_hdr = 'time per iter:';  
elap_hdr = 'elapsed time:';
est_hdr = 'time remaining:';  
iter_hdr = 'iteration:';     

if ~tic_exists || ~status_exists
    evalin('caller','progress_tic=tic;');
    time_str = 'n/a';
    elap_str = sprintf('%1.1f',0);
    est_str = 'n/a';
    iter_str = sprintf('%i/%i',iter,total); 
else
    elapsed_t = evalin('caller','toc(progress_tic)');
    time_per_iter = elapsed_t/(iter-1);
    est_remaining = time_per_iter*(total-iter);
    time_str = sprintf('%1.2f',time_per_iter);
    elap_str = sprintf('%1.1f',elapsed_t);
    est_str = sprintf('%1.1f',est_remaining);
    iter_str = sprintf('%i/%i',iter,total);
end

%% non-erase conditions
switch(status_str)
    case {'reset' 'summarize'}

    otherwise
        %fprintf(repmat('\b',1,len_status));  
end

%% output conditions
switch(status_str)

    case 'reset'
        fprintf('\n'); evalin('caller','clear(''status_str'')');       

    case 'summarize'
        fprintf('\nTotal time: %1.1f\n',elapsed_t);
        evalin('caller','clear(''status_str'')'); 
        
    case 'clear' %clear instruction
        fprintf(repmat('\b',1,len_status));
        evalin('caller','clear(''status_str'')'); 

    case 'progress'
        hdrs = strjust(cell2mat(pad({descr_str;iter_hdr})),'right');
        vals = strjust(cell2mat(pad({''; iter_str;})),'left');
        lines = cellstr([hdrs repmat(' ',size(hdrs,1),1) vals]);
        status_str = strjoin(lines,'\n');
        fprintf([repmat('\b',1,len_status) '%s'],status_str);   

    case 'progress_full'
        hdrs = strjust(cell2mat(pad({iter_hdr;time_hdr;elap_hdr;est_hdr})),'right');
        vals = strjust(cell2mat(pad({iter_str; time_str; elap_str; est_str})),'left');
        lines = cellstr([hdrs repmat(' ',size(hdrs,1),1) vals]);
        lines = [{descr_str}; lines];
        status_str = strjoin(lines,'\n');
        fprintf([repmat('\b',1,len_status) '%s'],status_str);              
    
end

end


