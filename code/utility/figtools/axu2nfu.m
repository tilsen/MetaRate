function [varargout] = axu2nfu(x,y)

if nargin==1 && length(x)==4
    xx = x([1 3]);
    yy = y([2 4]);
    ispos = false;
    
elseif nargin==2 && all(size(x)==size(y))
    xx = x;
    yy = y;
    ispos==true;
    
else
    fprintf('invalid input\n'); return;    
end
    
funits = get(gcf,'units');

if ~strcmp(funits,'Normalized'), set(gcf,'units','normalized'); end
xlims = get(gca,'xlim');
ylims = get(gca,'ylim');

axfu = get(gca,'Position');

%ratios of normalized axis

%changes of nfu per change of axes units
dnfux 


if ~strcmp(funits,'Normalized'), set(gcf,'units',funits); end

if ispos
    varargout{1} = [xx(1) yy(1) xx(2) yy(2)];
else
    varargout{1} = xx;
    varargout{2} = yy;
end

end