function [D] = analysis_differences(D1,D2)

%this ensures that conditions are matched
init_sort_order = {'target' 'unit' 'ratio' 'exclusion' 'datasel'};
D1 = sortrows(D1,init_sort_order);
D2 = sortrows(D2,init_sort_order);

D = D1;
D.d_avg_rho = D1.avg_rho - D2.avg_rho;
D = sortrows(D,'d_avg_rho','descend');

end