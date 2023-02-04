function [cmap] = pastelize(cmap,fac)

if numel(fac)==1 %apply pastelization to colormap
    switch(sign(fac))
        case 1
            cmap = cmap+(1-cmap)*fac;
            cmap(cmap>1) = 1;
        case -1
            cmap = cmap+cmap*fac;
            cmap(cmap<0) = 0;
    end
else %apply pastelizations to single color
    cmap = repmat(cmap(1,:),length(fac),1);
    for i=1:size(cmap,1)
        cmap(i,:) = pastelize(cmap(i,:),fac(i));
    end
    
end

end