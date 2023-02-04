function [] = adjwidth(obj,adj)

for i=1:numel(obj)
    if ~ishandle(obj(i)),continue; end
    obj(i).Position(3) =  obj(i).Position(3) + adj;
end
end