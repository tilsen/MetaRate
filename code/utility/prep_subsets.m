function [gg] = prep_subsets(G)

for i=1:length(G)
    for j=1:size(G{i},1)
        gg(i).subset(j).target = G{i}{j,1};
        gg(i).subset(j).rate_meas = G{i}{j,2};
        gg(i).subset(j).inverse_rate = G{i}{j,3};
        gg(i).subset(j).target_exclusion = G{i}{j,4};
        gg(i).subset(j).data_selection = G{i}{j,5};
    end
end

end