function [axh,varargout] = staxpos(axn,margins)

if nargin==2,
    [axh,varargout{1}] = stfig_axpos(axn,margins);
else
     [axh,varargout{1}] = stfig_axpos(axn);
end


end