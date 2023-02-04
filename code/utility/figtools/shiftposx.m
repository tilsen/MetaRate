function [] = shiftposx(obj,shift)

if numel(shift)==1
    shift = repmat(shift,1,length(obj));
end

for i=1:numel(obj)
    if ~ishandle(obj(i)),continue; end
    obj(i).Position(1) =  obj(i).Position(1) + shift(i);
end
end