function [D,SC] = metarate_comparison_general()

dbstop if error;
h = metarate_helpers();

if ~exist(h.figures_dir,'dir'), mkdir(h.figures_dir); end

scale_range = [0.5 inf]; %range of scales to consider for max and avg correlations
center_range = [-0.5 0.5]; %range of centers to consider for avg correlations

scale_slice = 0.5;  %table stores constant scale slice at this value
center_slice = 0.0; %table stores constant center slice at this value 

load([h.data_dir 'metarate_partialcorr_scalographs.mat'],'T');

%parameters will be sorted in this order:
sc_pars = {'target','unit','inversion','datasel','winmethod','exclusion'};

D = params_from_scalographs(T);

G=[];
for i=1:length(D)
    G(i).subset = D(i);
end
SC = prep_scalographs(T,G); 

for i=1:length(SC)

    status_str = status('progress_full',i,length(SC),'querying scalographs'); %#ok<NASGU> 

    % max corr (scale > 0.5)
    [D(i).max_center,D(i).max_scale,D(i).max_rho] = ...
        query_scalogram(SC(i).XX,SC(i).YY,SC(i).ZZ,'max',...
        'scale_range',scale_range); %#ok<*AGROW> 

    %avg corr (scale > 0.5)
    [~,~,D(i).avg_rho]  = ...
        query_scalogram(SC(i).XX,SC(i).YY,SC(i).ZZ,'avg',...
        'scale_range',scale_range,'center_range',center_range);    

    if ismember(D(i).datasel,{'bytarget'})

        switch(D(i).winmethod)
            case {'beginanchored','endanchored'}

            otherwise
                %constant center = 0
                [D(i).cent_slice_x,D(i).cent_slice_y,D(i).cent_slice_z] = ...
                    slice_scalogram(SC(i).XX,SC(i).YY,SC(i).ZZ,'center',center_slice);

                %constant re = 0
                [D(i).re_slice_x,D(i).re_slice_y,D(i).re_slice_z] = ...
                    slice_scalogram(SC(i).XX,SC(i).YY,SC(i).ZZ,'re',center_slice);

                %constant le = 0
                [D(i).le_slice_x,D(i).le_slice_y,D(i).le_slice_z] = ...
                    slice_scalogram(SC(i).XX,SC(i).YY,SC(i).ZZ,'le',center_slice);

                %constant scale = 0.5
                [D(i).scale_slice_x,D(i).scale_slice_y,D(i).scale_slice_z] = ...
                    slice_scalogram(SC(i).XX,SC(i).YY,SC(i).ZZ,'scale',scale_slice);
        end
    end
    
end
status('reset');

D = struct2table(D);
D = sortrows(D,sc_pars);

%---default colors by units:
units = h.units;
colors = lines(numel(units));
for i=1:length(units)
    ixs = ismember(D.unit,units{i});
    D.color(ixs,:) = repmat(colors(i,:),sum(ixs),1);
end

D.hatch = false(height(D),1);
D.hatch(D.inversion==1) = true;

% target symbols
TARG = metarate_targets;
[~,ia] = ismember(D.target,TARG.target);
D.symb = TARG.symb(ia);
D.descr = TARG.descr(ia);
D.description = TARG.description(ia);

D.ratio = repmat({''},height(D),1);
D.ratio(D.inversion==0) = {'proper'};
D.ratio(D.inversion==1) = {'inverse'};

%%

save([h.figures_dir 'analysis_comparisons.mat'],'D');

end




