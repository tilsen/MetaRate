function [] = defticks(varargin)

if nargin==0
    set(findall(allchild(gcf),'Type','axes'),'tickdir','out','ticklen',0.003*[1 1]);
else
    set(ax,'tickdir','out','ticklen',0.003*[1 1]);
end

end