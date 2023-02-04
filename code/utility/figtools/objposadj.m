function [] = objposadj(h,adj)

h = h(:);
if length(h)>1 && size(adj,1)<numel(h)
    adj = repmat(adj,length(h),1);
end

for i=1:length(h)
    if ~ishandle(h), continue; end    
    h(i).Position(1:size(adj,2)) = h(i).Position(1:size(adj,2))+adj(i,:);
end

end

