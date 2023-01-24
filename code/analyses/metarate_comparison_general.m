function [D,SC] = metarate_comparison_general()

dbstop if error;
h = metarate_helpers();

if ~exist(h.figures_dir,'dir'), mkdir(h.figures_dir); end

scale_range = [0.5 inf]; %range of scales to consider for max and avg correlations
center_range = [-0.5 0.5]; %range of centers to consider for avg correlations

scale_slice = 0.5;  %table stores constant scale slice at this value
center_slice = 0.0; %table stores constant center slice at this value 

load([h.data_dir 'metarate_partialcorr_scalographs.mat'],'T');
PAR = T.Properties.UserData;

TARGS = metarate_targets;

%define set/comparison (target, unit, inversion, exclusion, selection)

sc_pars = {'target','unit','inversion','datasel','winmethod','exclusion'};

for i=1:length(sc_pars)
    P.(sc_pars{i}) = unique(T.(sc_pars{i}));
end

G = {};
D = [];

[p1,p2,p3,p4,p5,p6] = ndgrid(P.(sc_pars{1}),P.(sc_pars{2}),P.(sc_pars{3}),P.(sc_pars{4}),P.(sc_pars{5}),P.(sc_pars{6}));

PP = {p1(:),p2(:),p3(:),p4(:),p5(:),p6(:)};

for i=1:length(sc_pars)
    D.(sc_pars{i})=PP{i};
end

D = struct2table(D);

inversion_strs = {'proper' 'inverse'};
D.ratio = inversion_strs(D.inversion+1)';

[~,ixa] = ismember(D.target,TARGS.target);
D.description = TARGS.description(ixa);
D.descr = TARGS.descr(ixa);
D.symb = TARGS.symb(ixa);

for i=1:height(D)
    status_str = status('progress_full',i,height(D),'checking subsets'); %#ok<NASGU> 
    Tx = PAR.index(T,D.target{i},D.unit{i}, D.inversion(i), D.datasel{i},D.winmethod{i},D.exclusion(i));    
    D.num(i) = height(Tx);
end
status('reset');

D = D(D.num>0,:);
G = table2cell(D(:,sc_pars));
G = arrayfun(@(c){G(c,:)},(1:size(G,1))');

G = prep_subsets(G);  
SC = prep_scalographs(T,G); 

D = table2struct(D);

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
%D = sortrows(D,{'exclusion' 'target' 'unit' 'ratio'},{'ascend' 'ascend' 'descend' 'descend'});
D = sortrows(D,sc_pars);

%---default colors by units:
units = {'phones' 'sylbs' 'words' 'moras' 'artics'};
colors = lines(numel(units));
for i=1:length(units)
    ixs = ismember(D.unit,units{i});
    D.color(ixs,:) = repmat(colors(i,:),sum(ixs),1);
end

D.hatch = false(height(D),1);
D.hatch(ismember(D.ratio,{'inverse'})) = true;

%%

save([h.figures_dir 'analysis_comparisons.mat'],'D');

end




