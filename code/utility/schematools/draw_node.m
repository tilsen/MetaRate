function [h,N] = draw_node(N,varargin)

if height(N)>1
    for i=1:height(N)
        h(i) = draw_node(N(i,:),varargin{:});
        N.fh(i) = h(i).fh;
        N.th(i) = h(i).th;
    end
    return;
end

p = inputParser;

deffacealpha = 0.5;
defparent = gca;
deffontsize = 24;
definterpreter = {'none'};
defradius = [1 1];


addRequired(p,'N');
addParameter(p,'parent',defparent);
addParameter(p,'fontsize',deffontsize);
addParameter(p,'interpreter',definterpreter);
addParameter(p,'radius',defradius);

parse(p,N,varargin{:});
r = p.Results;

if ~(ismember('pos',N.Properties.VariableNames) || (all(ismember({'xc' 'yc'},N.Properties.VariableNames))))
   fprintf('error: node must include 2-element position vector or xcenter and ycenter\n'); return;
end

if ~all(ismember({'xc' 'yc'},N.Properties.VariableNames))
   N.xc = N.pos(:,1);
   N.yc = N.pos(:,2);
end

if ~ismember('facealpha',N.Properties.VariableNames)
    N.facealpha = deffacealpha;
end

if ~ismember('color',N.Properties.VariableNames)
    N.color = 'k';
end

if ~ismember('fontsize',N.Properties.VariableNames)
    N.fontsize = r.fontsize;
end

if ~ismember('interpreter',N.Properties.VariableNames)
    N.interpreter = r.interpreter;
end

if ~ismember('radius',N.Properties.VariableNames)
    N.radius = r.radius;
end

if numel(N.radius)==1, N.radius = N.radius*[1 1]; end

th = linspace(0,2*pi,1000);
h.fh = fill(N.radius(1)*cos(th)+N.xc,N.radius(2)*sin(th)+N.yc,N.color,...
    'facealpha',N.facealpha,'edgecolor','k','parent',r.parent); hold(r.parent,'on');

if all(ischar(N.label))
    h.th = text(N.xc,N.yc,N.label,'fontsize',N.fontsize,...
        'hori','center','verti','middle','parent',r.parent,'interp',N.interpreter{:});
else
    h.th = text(N.xc,N.yc,N.label{:},'fontsize',N.fontsize,...
        'hori','center','verti','middle','parent',r.parent,'interp',N.interpreter{:});    
end

end
