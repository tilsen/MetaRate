function [] = axrescale(varargin)


%first input is axes object handle(s)
if all(ishandle(varargin{1}))
    ax = varargin{1};

    [rsx,rsy] = parse_rs_input(varargin{2:end});

else
    ax = gca;

    [rsx,rsy] = parse_rs_input(varargin{:});

end

if ~any(isnan(rsx))
    for j=1:numel(ax)
        axrescalex(rsx,ax(j));
    end
end
    
if ~any(isnan(rsy))
    for j=1:numel(ax)
        axrescaley(rsy,ax(j));
    end
end

end


%
function [rsx,rsy] = parse_rs_input(varargin)

rsx = nan;
rsy = nan;

if ~isempty(varargin{1})
    rsx = varargin{1};
end

if numel(varargin)>1
    rsy = varargin{2};
end

if numel(rsx)==1, rsx = [-abs(rsx) abs(rsx)]; end
if numel(rsy)==1, rsy = [-abs(rsy) abs(rsy)]; end

end
