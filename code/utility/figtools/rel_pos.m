function [] = rel_pos(obj1,loc1,obj2,loc2,xyoff)
% positions a corner of one object relative to another

if strcmp(loc1,'tr') && strcmp(loc2,'tl')
    obj1.Position(1) = obj2.Position(1)-xyoff(1)-obj1.Position(3);
    obj1.Position(2) = sum(obj2.Position([2 4]))-obj1.Position(4);
end


end