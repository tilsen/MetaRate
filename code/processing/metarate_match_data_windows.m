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

%default is to do window restrictions before data selection
switch(winpars.method)
    case {'bywindow','adaptivewin'}

    otherwise
        %restrict windows to center range:
        ix_win_keep = WIN.edges(:,1)>=winpars.center_range(1) & WIN.edges(:,2)<=winpars.center_range(2);
        WIN = WIN(ix_win_keep,:);
end

%add window limits:
switch(winpars.method)
    case 'extendwin'
        % add new limits to data table, extending them to compensate for 
        % the exclusion of the rate unit:
        D.we0 = D.tanch+min(WIN.edges(:,1))-D.rateunit_dur/2;
        D.we1 = D.tanch+max(WIN.edges(:,2))+D.rateunit_dur/2;

    case 'adaptivewin'
        % add new limits to data table, extending them to compensate for 
        % the exclusion of the rate unit:
        D.we0 = D.tanch+min(WIN.edges(:,1))-D.rateunit_dur/2;
        D.we1 = D.tanch+max(WIN.edges(:,2))+D.rateunit_dur/2;

        %do center-shifts if necessary:
        D.we0_d = D.we0-D.utt_t0; %negative for outofrange edges
        D.we1_d = D.we1-D.utt_t1;  

        D.we0_out = D.we0>=D.utt_t0;
        D.we1_out = D.we1<=D.utt_t1;

        %left-edge is out
        D.we0(D.we0_out) = D.utt_t0(D.we0_out);
        D.we1(D.we0_out) = D.we1(D.we0_out)-D.we0_d(D.we0_out); 

        %right-edge is out
        D.we1(D.we1_out) = D.utt_t1(D.we1_out);
        D.we0(D.we1_out) = D.we0(D.we1_out)-D.we1_d(D.we1_out);  

    otherwise
        % add new limits to data table:
        D.we0 = D.tanch+min(WIN.edges(:,1));
        D.we1 = D.tanch+max(WIN.edges(:,2));       

end

%impose window-based data selection unless method d/n call for it:
switch(winpars.method)
    case {'bywindow', 'adaptivewin'}
        %handle data selection in analysis loop
        ix_keep = (1:height(D))';
       
    otherwise       
        %only keep data where extended edges are valid
        %restrict windows to center range.     
        ix_keep = D.we0>=D.utt_t0 & ...
                  D.we1<=D.utt_t1;  
           
end

D = D(ix_keep,:);
end