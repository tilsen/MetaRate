function [D,SC] = metarate_comparison_general()

dbstop if error;
h = metarate_helpers();

if ~exist(h.figures_dir,'dir'), mkdir(h.figures_dir); end

scale_range = [0.5 inf]; %range of scales to consider for max and avg correlations
center_range = [-0.5 0.5]; %range of centers to consider for avg correlations

scale_slice = 0.5;  %table stores constant scale slice at this value
center_slice = 0.0; %table stores constant center slice at this value

load([h.data_dir 'metarate_partialcorr_scalographs.mat'],'T');

TARGS = metarate_targets;

%define set/comparison (target, unit, inversion, exclusion, selection)
datasel = {'bytarget','endanchored','beginanchored'};
targets = TARGS.target;
units = {'phones','moras','sylbs','words','artics'};
inversions = [0 1];
inversion_strs = {'proper' 'inverse'};
exclusions = [0 1];

G = {};
D = [];
for a=1:length(targets)
    for b=1:length(units)
        for c=1:length(inversions)
            for d=1:length(exclusions)
                for e=1:length(datasel)
                    G{end+1} = {targets(a) units(b) inversions(c) exclusions(d) datasel(e)};
                    D(end+1).target = targets{a};
                    D(end).unit = units{b};
                    D(end).ratio = inversion_strs(c);
                    D(end).exclusion = exclusions(d);
                    D(end).data_selection = datasel{e};
                    D(end).description = TARGS.description{a};
                    D(end).descr = TARGS.descr{a};   
                    D(end).symb = TARGS.symb{a};
                end
            end
        end
    end
end

G = prep_subsets(G);  
SC = prep_scalographs(T,G); 

for i=1:length(SC)

    % max corr (scale > 0.5)
    [D(i).max_center,D(i).max_scale,D(i).max_rho] = ...
        query_scalogram(SC(i).XX,SC(i).YY,SC(i).ZZ,'max',...
        'scale_range',scale_range); %#ok<*AGROW> 

    %avg corr (scale > 0.5)
    [~,~,D(i).avg_rho]  = ...
        query_scalogram(SC(i).XX,SC(i).YY,SC(i).ZZ,'avg',...
        'scale_range',scale_range,'center_range',center_range);    

    if ismember(D(i).data_selection,'bytarget')
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

D = struct2table(D);

D = sortrows(D,{'exclusion' 'target' 'unit' 'ratio'},{'ascend' 'ascend' 'descend' 'descend'});

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




