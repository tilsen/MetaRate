function [P] = params_from_scalographs(T)
%gets all subsets of paramters from scalographs

ff = {'target','unit','datasel','winmethod','exclusion','inversion'};

P = unique(T(:,ff),'rows');
P = table2struct(P);

end