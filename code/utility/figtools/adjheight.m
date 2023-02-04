function [] = adjheight(obj,adj)

for i=1:numel(obj)
    if ~ishandle(obj(i)),continue; end
    obj(i).Position(4) =  obj(i).Position(4) + adj;
end
end