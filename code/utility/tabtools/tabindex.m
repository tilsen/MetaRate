function [T,ixs] = tabindex(T,varargin)

f = varargin(1:2:end);
v = varargin(2:2:end);

ixs = (1:height(T))';

for i=1:length(f)
    
    if f{i}(1)=='~'
        f{i} = f{i}(2:end);
        negate = true;
    else
        negate = false;
    end

    switch(iscell(T.(f{i})))
        case 1
            ix_keep = ismember(T.(f{i}),v{i});

        case 0
            ix_keep = any(T.(f{i})==v{i},2);

     end

     if negate, ix_keep = ~ix_keep; end

     ixs = ixs(ix_keep);
     T = T(ix_keep,:);            

end

end