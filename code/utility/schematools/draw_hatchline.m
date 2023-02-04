function [h] = draw_hatchline(x,y,hatchlen,varargin)

p = inputParser;

defaultLineWidth = 1;
defaultHatchLineWidth = nan;
defaultColor = [0 0 0];
defaultParent = gca;

addRequired(p,'x');
addRequired(p,'y');
addRequired(p,'hatchlen');
addOptional(p,'linewidth',defaultLineWidth);
addOptional(p,'ticklinewidth',defaultHatchLineWidth);
addOptional(p,'color',defaultColor);
addOptional(p,'parent',defaultParent);

parse(p,x,y,hatchlen,varargin{:});

p = p.Results;

if isnan(p.ticklinewidth), p.ticklinewidth = p.linewidth; end

if numel(x)==1, x = x*[1 1]; end
if numel(y)==1, y = y*[1 1]; end

if x(1)==x(2) %vertical line
    h(1) = line(x,y,'color',p.color,'linewidth',p.linewidth,'linesty','-','parent',p.parent);
    h(2) = line(x(1)+hatchlen/2*[-1 1],y([1 1]),'color',p.color,'linewidth',p.ticklinewidth,'linesty','-','parent',p.parent);
    h(3) = line(x(1)+hatchlen/2*[-1 1],y([2 2]),'color',p.color,'linewidth',p.ticklinewidth,'linesty','-','parent',p.parent);    
elseif y(1)==y(2)
    h(1) = line(x,y,'color',p.color,'linewidth',p.linewidth,'linesty','-','parent',p.parent);
    h(2) = line(x([1 1]),y(1)+hatchlen/2*[-1 1],'color',p.color,'linewidth',p.ticklinewidth,'linesty','-','parent',p.parent);
    h(3) = line(x([2 2]),y(1)+hatchlen/2*[-1 1],'color',p.color,'linewidth',p.ticklinewidth,'linesty','-','parent',p.parent);
else
    h(1) = line(x,y,'color',p.color,'linewidth',p.linewidth,'linesty','-','parent',p.parent);
    th = atan2(diff(y),diff(x));
    pp = [x(1)+[(hatchlen/2)*cos(th+pi/2) (hatchlen/2)*cos(th-pi/2)];...
        y(1)+[(hatchlen/2)*sin(th+pi/2) (hatchlen/2)*sin(th-pi/2)]];
    h(2) = line(pp(1,:),pp(2,:),'color',p.color,'linewidth',p.ticklinewidth,'linesty','-','parent',p.parent);
    pp = [x(2)+[(hatchlen/2)*cos(th+pi/2) (hatchlen/2)*cos(th-pi/2)];...
        y(2)+[(hatchlen/2)*sin(th+pi/2) (hatchlen/2)*sin(th-pi/2)]];
    h(3) = line(pp(1,:),pp(2,:),'color',p.color,'linewidth',p.ticklinewidth,'linesty','-','parent',p.parent);    
end


end