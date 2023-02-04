function [thx] = line_spacing(TH,fac)
%changes line spacing of text object by converting each line to separate
%text object (only works without rotation)

for i=1:length(TH)

    th = TH(i);
    yext = th.Extent(4);

    switch(th.Parent.YDir)
        case 'reverse'
            ymid = th.Extent([2 4])*[1 -0.5]';
        otherwise
            ymid = th.Extent([2 4])*[1 0.5]';
    end

    nlines = length(th.String);

    if ~iscell(th.String) || nlines==1, return; end

    switch(th.VerticalAlignment)
        case 'middle'
            new_yext = yext*fac;
            switch(th.Parent.YDir)
                case 'reverse'
                    ymids = ymid - linspace(new_yext/2,-new_yext/2,nlines+2);
                otherwise
                    ymids = ymid + linspace(new_yext/2,-new_yext/2,nlines+2);
            end
            ymids = ymids(2:end-1);
            for i=1:nlines
                thx(i) = text(th.Position(1),ymids(i),th.String{i}, ...
                    'hori',th.HorizontalAlignment,'fontsize',th.FontSize, ...
                    'verti','mid','parent',th.Parent);
            end

    end

    delete(th);

end

end