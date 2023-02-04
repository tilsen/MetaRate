function [varargout] = stfig(varargin)

dbstop if error;

if nargin==0
    varargout{1} = stfig_max();    
    return;
end

varargout = {};
if isempty(get(0,'CurrentFigure'))
    varargout{end+1} = stfig_max(); drawnow;
end

switch(varargin{1})
    case 'max'
        varargout{end+1} = stfig_max();
    case 'axpos'
        varargout{end+1} = stfig_axpos(varargin{2:end});
    case {'setaspect','aspect'}
        varargout{end+1} = stfig_setaspect(varargin{2:end});
    case 'bare'
        varargout{end+1} = stfig_bare();
    case 'panlab'
        varargout{end+1} = stfig_panlab(varargin{2:end});
end


    

end