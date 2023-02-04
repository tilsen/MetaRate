function [xp,yp] = edge_line(whichedge,tref,x,y)

switch(whichedge)
    case 're'
        xp = tref-y/2;
        yp = y;
        ix_valid = find(xp-yp/2<=min(x),1,'first');
        xp = xp(1:ix_valid);
        yp = yp(1:ix_valid);
    case 'le'
        xp = tref+y/2; %centers of windows with left edges at 0
        yp = y;
        ix_valid = find(xp+yp/2>=max(x),1,'first');
        xp = xp(1:ix_valid);
        yp = yp(1:ix_valid);
end

end

