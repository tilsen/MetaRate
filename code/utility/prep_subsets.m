function [gg] = prep_subsets(G)

%sc_pars = {'target','unit','inversion','datasel','winmethod','exclusion'};

if isstruct(G{1})

    for i=1:length(G)
        g = G{i};
        ff = fieldnames(g);
        for j=1:length(g)
            for k=1:length(ff)
                gg(i).subset(j).(ff{k}) = g(j).(ff{k});
            end
        end
    end
else
    for i=1:length(G)
        for j=1:size(G{i},1)
            gg(i).subset(j).target = G{i}{j,1};
            gg(i).subset(j).unit = G{i}{j,2};
            gg(i).subset(j).inversion = G{i}{j,3};
            gg(i).subset(j).datasel = G{i}{j,4};
            gg(i).subset(j).winmethod = G{i}{j,5};
            gg(i).subset(j).exclusion = G{i}{j,6};
        end
    end
end

end