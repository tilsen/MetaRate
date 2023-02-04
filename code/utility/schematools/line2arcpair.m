function [h] = line2arcpair(lh,xg,yg,xs,ys,varargin)

if ishandle(lh)
    
    if numel(lh)>1
        delete(lh(2:end));
        lh = lh(1);
    end
    
    switch(lh.Type)
        case 'patch'
            
            switch(lh.Tag)
                case 'Arrow'
                    PP = reshape(lh.UserData([1 2 4 5]),2,2)';
            end
            
            
    end
    delete(lh);
    
else
    PP = lh;
end

PP = [PP(1,:); mean(PP); PP(2,:)];

PP1 = PP;
PP2 = PP;

PP1(2,:) = PP1(2,:) + -1*[xs ys];
PP2(2,:) = PP2(2,:) + 1*[xs ys];

PP1(:,1) = PP1(:,1) + -xg;
PP1(:,2) = PP1(:,2) + -yg;
PP2(:,1) = PP2(:,1) + xg;
PP2(:,2) = PP2(:,2) + yg;

h(1) = draw_arc(flipud(PP1),varargin{:});
h(2) = draw_arc(PP2,varargin{:});



end