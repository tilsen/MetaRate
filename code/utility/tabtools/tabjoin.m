function [Torig] = tabjoin(Tnew,Torig,ixs_orig)
%updates original, larger table with values from all columns of newer
%table, which is smaller

if length(ixs_orig)>=height(Torig)
    fprintf('ERROR: Tnew expected to be smaller\n');
    return;
end

ff = Tnew.Properties.VariableNames;

for i=1:length(ff)
    switch(size(Tnew.(ff{i}),2))
        case 1
            Torig.(ff{i})(ixs_orig) = Tnew.(ff{i});
        otherwise
            Torig.(ff{i})(ixs_orig,:) = Tnew.(ff{i});
    end
end

end