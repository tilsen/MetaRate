function [D,WIN] = metarate_match_data_windows(D,WIN)

%restricts windows and data, depending on method
%determines anchorpoint (D.tanch) for method

winpars = WIN.Properties.UserData;

%----anchor points
switch(winpars.method)
    case 'endanchored'
        D.tanch = D.t0;        %beginnings of windows anchored to ends of units, only include data that fits in all windows
    case 'beginanchored'
        D.tanch = D.t1;
    otherwise                   
        D.tanch = D.tmid;
        
end


%select data
switch(winpars.method)
    case 'bywindow'
        %handle data selection in analysis loop
        ix_keep = (1:height(D))';
        
    otherwise
        %restrict windows to center range:
        ix_win_keep = WIN.edges(:,1)>=winpars.center_range(1) & WIN.edges(:,2)<=winpars.center_range(2);
        WIN = WIN(ix_win_keep,:);
        
        %only include data available for all windows
        ix_keep = (D.tanch+min(WIN.edges(:,1)))>=D.utt_t0 & ...
                  (D.tanch+max(WIN.edges(:,2)))<=D.utt_t1;
           
end

D = D(ix_keep,:);
end