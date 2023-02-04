function [h] = draw_arc(C,varargin)

defaultnpoints = 100;
defaultconntype = 'forward';
defaultarrowprops = {'length',8,'tipangle',30};
defaultlinewidth = 1;
defaultlinestyle = '-';
defaultlinecolor = 'k';
defaultparent = gca;

p = inputParser;
addRequired(p,'C');
addParameter(p,'npoints',defaultnpoints,@(x)isinteger(x));
addParameter(p,'conntype',defaultconntype);
addParameter(p,'arrowprops',defaultarrowprops);
addParameter(p,'linewidth',defaultlinewidth);
addParameter(p,'linestyle',defaultlinestyle);
addParameter(p,'linecolor',defaultlinecolor);
addParameter(p,'parent',defaultparent);

parse(p,C,varargin{:});

set(gcf,'currentaxes',p.Results.parent);

if size(C,2)>2
    C = C';
end

fo = cscvn(C');
arc = fnplt(fo);

%if isempty(varargin), return; end

for i=1:2
    arci(i,:) = interp1(arc(i,:),linspace(1,size(arc,2),p.Results.npoints));
end

arc = arci;

h.lh = plot(arc(1,:),arc(2,:),'linestyle',p.Results.linestyle,'linewidth',p.Results.linewidth,'color',p.Results.linecolor,'parent',p.Results.parent);

switch(p.Results.conntype)
    case 'forward'   
        h.ch = arrow(arc(:,end-1),arc(:,end),p.Results.arrowprops{:},'linewidth',p.Results.linewidth);
    case 'backward'
        h.ch = arrow(arc(:,2),arc(:,1),p.Results.arrowprops{:},'linewidth',p.Results.linewidth);
    case 'both'
        h.ch(1) = arrow(arc(:,end-1),arc(:,end),p.Results.arrowprops{:},'linewidth',p.Results.linewidth);
        h.ch(2) = arrow(arc(:,2),arc(:,1),p.Results.arrowprops{:},'linewidth',p.Results.linewidth);
    otherwise

end



end