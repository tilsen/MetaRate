function [C] = merge_tables(A,B)

if isempty(A)
    C = B; return;
end

if isempty(B)
    C = A; return;
end

Av = A.Properties.VariableNames;
Bv = B.Properties.VariableNames;

ab = setdiff(Av,Bv);
ba = setdiff(Bv,Av);

if isempty(ab) && isempty(ba)
    C = [A; B];
    return;
end

if ~isempty(ab)
    for i=1:length(ab)
        B.(ab{i}) = repmat(repvar(A.(ab{i})),height(B),1);
    end
end

if ~isempty(ba)
    for i=1:length(ba)
        A.(ba{i}) = repmat(repvar(B.(ba{i})),height(A),1);
    end
end  

C = [A; B];

end

%%
function [ro] = repvar(x)

if all(isnumeric(x))
    ro = nan;
else
    ro = {};
end

end
