function [ch,C] = draw_connection(C,varargin)

if istable(C)
    for i=1:height(C)
        ch{i} = draw_connection(C.conn{i}',varargin{:});
        C.ch{i} = ch{i};
    end
    return;
end

defaultconntype = 'forward';
defaultarrowprops = {'length',8,'tipangle',30};
defaultlinewidth = 1;
defaultlinecolor = 'k';
defaultlinestyle = '-';
defaultparent = gca;

p = inputParser;
addRequired(p,'C');
addParameter(p,'conntype',defaultconntype);
addParameter(p,'arrowprops',defaultarrowprops);
addParameter(p,'linewidth',defaultlinewidth);
addParameter(p,'linecolor',defaultlinecolor);
addParameter(p,'linestyle',defaultlinestyle);
addParameter(p,'parent',defaultparent);

parse(p,C,varargin{:});

set(gcf,'currentaxes',p.Results.parent);

switch(p.Results.conntype)
    case 'forward'
        ch = arrow(C(:,1),C(:,2),p.Results.arrowprops{:},'linewidth',p.Results.linewidth,'color',p.Results.linecolor);
    case 'backward'
        ch = arrow(C(:,2),C(:,1),p.Results.arrowprops{:},'linewidth',p.Results.linewidth,'color',p.Results.linecolor);
    case 'both'
        ch(1) = arrow(C(:,1),C(:,2),p.Results.arrowprops{:},'linewidth',p.Results.linewidth,'color',p.Results.linecolor);
        ch(2) = arrow(C(:,2),C(:,1),p.Results.arrowprops{:},'linewidth',p.Results.linewidth,'color',p.Results.linecolor);
    case 'none'
        ch = line(C(1,:),C(2,:),'linewidth',p.Results.linewidth,'color',p.Results.linecolor,...
            'linestyle',p.Results.linestyle,'parent',p.Results.parent);
end


end

