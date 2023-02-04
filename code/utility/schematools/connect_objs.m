function [C] = connect_objs(obj1,varargin)

if numel(obj1)==2
    obj2 = obj1(2);
    obj1 = obj1(1);
else
    obj2 = varargin{1};
end

ip = 50;
box2pnts = @(xx,yy)[linspace(xx(1),xx(2),ip) xx(2)*ones(1,ip) linspace(xx(2),xx(1),ip) xx(1)*ones(1,ip);...
               yy(1)*ones(1,ip) linspace(yy(1),yy(2),ip) yy(2)*ones(1,ip) linspace(yy(2),yy(1),ip)];
           
switch(obj1.Type)
    case 'text'
        xx = [obj1.Extent(1) sum(obj1.Extent([1 3]))];
        yy = [obj1.Extent(2) sum(obj1.Extent([2 4]))];
        PP1 = box2pnts(xx,yy);
        
    otherwise
        xd = obj1.XData;
        yd = obj1.YData;
        if ~iscolumn(xd), xd = xd'; yd= yd'; end
        PP1 = [xd yd]';
end

switch(obj2.Type)
    case 'text'
        xx = [obj2.Extent(1) sum(obj2.Extent([1 3]))];
        yy = [obj2.Extent(2) sum(obj2.Extent([2 4]))];
        PP2 = box2pnts(xx,yy);
        
    otherwise
        xd = obj2.XData;
        yd = obj2.YData;
        if ~iscolumn(xd), xd = xd'; yd= yd'; end
        PP2 = [xd yd]';
end

d = pdist2(PP1',PP2');

[r,c] = find(d==min(d(:)));
C = [PP1(:,r(1)) PP2(:,c(1))];

end


