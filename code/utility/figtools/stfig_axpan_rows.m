function [axpan] = stfig_axpan_rows(R)

for i=1:length(R)
    if ~iscolumn(R{i}), R{i} = R{i}'; end
end

nrows = cellfun(@(c)length(c),R);

nr(1) = nrows(1);
for j=2:length(nrows)
    nr(j) = lcm(nrows(j-1),nrows(j));
end

nr = nr(end);

for i=1:length(R)
    R{i} = reshape(repmat(R{i}',nr/nrows(i),1),[],1);
end

axpan = horzcat(R{:});

end