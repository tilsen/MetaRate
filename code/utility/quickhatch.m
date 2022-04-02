function [] = quickhatch(ph,orientation,color,linew,hatchsp)

xlims = ph(1).Parent.XLim;
ylims = ph(1).Parent.YLim;

for i=1:length(ph)
    if ~strcmp(ph(i).Type,'patch'), continue; end
    
    pp = ph(i).Vertices;

    minx = min(pp(:,1));
    miny = min(pp(:,2));
    maxx = max(pp(:,1));
    maxy = max(pp(:,2));
    

    switch(orientation)
        case 'vertical' %vertical bars
            sp = hatchsp*diff(ylims);
            yoff = miny:sp:(maxy+sp);
            xx = [minx maxx]+(maxx-minx)*0.001*[1 -1];
            X = repmat([xx nan],1,length(yoff)-1);
            Y = reshape([yoff(1:end-1); yoff(2:end); nan(1,length(yoff)-1)],1,[]);            
            Y(Y>maxy) = nan;
            Y(Y<miny) = nan;
            X(X>=maxx) = nan;
            X(X<=minx) = nan;
            line(X,Y,'linewidth',linew,'color',color);
            

        case 'horizontal' %horizontal bars
            sp = hatchsp*diff(xlims);
            xoff = minx:sp:(maxx+sp);
            yy = [miny maxy]+(maxy-miny)*0.001*[1 -1];
            Y = repmat([yy nan],1,length(xoff)-1);
            X = reshape([xoff(1:end-1); xoff(2:end); nan(1,length(xoff)-1)],1,[]);            
            X(X>maxx) = nan;
            X(X<minx) = nan;
            Y(Y>=maxy) = nan;
            Y(Y<=miny) = nan;
            line(X,Y,'linewidth',linew,'color',color);            

    end

end

end