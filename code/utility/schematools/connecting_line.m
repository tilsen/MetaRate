function [CC] = connecting_line(obj1,obj2,varargin)

p = inputParser;

def_bounds = 'extent';
def_anchors = 'center';

validobjs = @(x)ishandle(x);
addRequired(p,'obj1',@(x)validobjs(x));
addRequired(p,'obj2',@(x)validobjs(x));
addOptional(p,'bounds',def_bounds);
addOptional(p,'anchors',def_anchors);

parse(p,obj1,obj2,varargin{:});

if ~iscell(p.Results.bounds)
    bounds = {p.Results.bounds};
end
if ~iscell(p.Results.anchors)
    anchors = {p.Results.anchors};
end

if length(bounds)==1, bounds = repmat(bounds,1,2); end
if length(anchors)==1, anchors = repmat(anchors,1,2); end


np = 100;
box2pnts = @(xx,yy)[linspace(xx(1),xx(2),np) xx(2)*ones(1,np) linspace(xx(2),xx(1),np) xx(1)*ones(1,np);...
    yy(1)*ones(1,np) linspace(yy(1),yy(2),np) yy(2)*ones(1,np) linspace(yy(2),yy(1),np)];

%get object boundaries
OBJ = {obj1,obj2};
BB = {[],[]};
for i=1:length(OBJ)
    switch(OBJ{i}.Type)
        case 'patch'
            BB{i} = [OBJ{i}.XData(:) OBJ{i}.YData(:)];
        case 'text'
            xx = [OBJ{i}.Extent(1) sum(OBJ{i}.Extent([1 3]))];
            yy = [OBJ{i}.Extent(2) sum(OBJ{i}.Extent([2 4]))];
            BB{i} = box2pnts(xx,yy)';
    end
end

%get anchor points
CC = nan(2);
for i=1:length(OBJ)
    mm = minmax(BB{i}')';
    switch(anchors{i})
        case 'center'
            CC(i,:) = mean(mm); %#ok<*UDIM>
        case {'N','top'}
            CC(i,:) = [mean(mm(:,1)) max(mm(:,2))]; 
        case {'NE','topr'}
            CC(i,:) = [max(mm(:,1)) max(mm(:,2))]; 
        case {'NW','topl'}
            CC(i,:) = [min(mm(:,1)) max(mm(:,2))]; 
        case {'S','bot'}
            CC(i,:) = [mean(mm(:,1)) min(mm(:,2))]; 
        case {'SE','botr'}
            CC(i,:) = [max(mm(:,1)) min(mm(:,2))]; 
        case {'SW','botl'}
            CC(i,:) = [min(mm(:,1)) min(mm(:,2))]; 
        case {'E','r'}
            CC(i,:) = [max(mm(:,1)) mean(mm(:,2))]; 
        case {'W','l'}
            CC(i,:) = [min(mm(:,1)) mean(mm(:,2))]; 
        case 'closest'
            ixo = mod(i,2)+1;
            d = pdist2(BB{i},BB{ixo});
            [r,~] = find(d==min(d(:)));
            CC = BB{i}(r(1),:);
    end
end


%% apply bounding areas
if ismember('extent',bounds)
    %get fine-grained line points
    np = 1000;
    PP = [linspace(CC(1,1),CC(end,1),np)' linspace(CC(1,2),CC(end,2),np)'];
    for i=1:2
        switch(bounds{i})
            case 'extent'
                [in,~] = inpolygon(PP(:,1),PP(:,2),BB{i}(:,1),BB{i}(:,2));
                PP = PP(~in,:);
        end
    end
    if ~isempty(PP)
        CC = PP([1 end],:);
    end
end


end


