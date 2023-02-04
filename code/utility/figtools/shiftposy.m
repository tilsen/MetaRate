function [] = shiftposy(obj,shift)

if numel(obj)>1 && length(shift)==1
    shift = shift(ones(1,numel(obj)));
end

for i=1:numel(obj)    
    if ~ishandle(obj(i)),continue; end
    obj(i).Position(2) =  obj(i).Position(2) + shift(i);
end
end