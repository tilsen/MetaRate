function [h] = draw_box(N,varargin)

p = inputParser;

deffacealpha = 0.5;
defparent = gca;
deffontsize = 24;
definterpreter = 'none';
deflinestyle = '-';
defedgecolor = 'k';

addRequired(p,'N');
addParameter(p,'parent',defparent);
addParameter(p,'fontsize',deffontsize);
addParameter(p,'interpreter',definterpreter);
addParameter(p,'linestyle',deflinestyle);
addParameter(p,'edgecolor',defedgecolor);

parse(p,N,varargin{:});
r = p.Results;

if ~ismember(N.Properties.VariableNames,'facealpha')
    N.facealpha = deffacealpha;
end

if ~ismember(N.Properties.VariableNames,'color')
    N.color = 'k';
end

if ~ismember(N.Properties.VariableNames,'fontsize')
    N.fontsize = r.fontsize;
end

if ~ismember(N.Properties.VariableNames,'interpreter')
    N.interpreter = r.interpreter;
end

if numel(N.radius)==1, N.radius = N.radius*[1 1]; end

thx = linspace(-N.radius(1),N.radius(1),1000);
thy = linspace(-N.radius(2),N.radius(2),1000);
zh = ones(size(thx));
boxx = [thx thx(end)*zh fliplr(thx) thx(1)*zh];
boxy = [thy(end)*zh fliplr(thy) thy(1)*zh thy];
h.fh = fill(boxx+N.xc,boxy+N.yc,N.color,...
    'facealpha',N.facealpha,'edgecolor',r.edgecolor,'parent',r.parent,'linestyle',r.linestyle); hold(r.parent,'on');

if all(ischar(N.label))
    h.th = text(N.xc,N.yc,N.label,'fontsize',N.fontsize,...
        'hori','center','verti','middle','parent',r.parent,'interp',N.interpreter{:});
else
    h.th = text(N.xc,N.yc,N.label{:},'fontsize',N.fontsize,...
        'hori','center','verti','middle','parent',r.parent,'interp',N.interpreter{:});    
end

end

%%
function [hN] = draw_node_old(h,N)

if ~isfield(N,'fa') || ~isnumeric(N.fa) || isempty(N.fa)
    if isfield(h,'fa')
        N.fa = h.fa;
    else
        N.fa = 0.5; 
    end
end

if ~isfield(N,'col')  || isempty(N.col)
    if isfield(h,'col')
        N.col = h.col;
    else
        N.col = [0 0 0]; 
    end
end

th = linspace(0,2*pi,200);
hN(1) = fill(N.rad(1)*cos(th)+N.xc,N.rad(2)*sin(th)+N.yc,N.col,'facealpha',N.fa,'edgecolor','k'); hold on;
hN(2) = text(N.xc,N.yc,N.lab,'fontsize',h.fontsize,'hori','center','verti','middle');

end
