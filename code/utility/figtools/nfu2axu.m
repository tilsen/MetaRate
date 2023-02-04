function [varargout] = nfu2axu(x,y)

if nargin==1 && length(x)==4
    xx = x([1 3]);
    yy = y([2 4]);
    ispos = true;
    
elseif nargin==2 && all(size(x)==size(y))
    xx = x;
    yy = y;
    ispos=false;
else
    fprintf('invalid input\n'); return;    
end
    
funits = get(gcf,'units');

if ~strcmp(funits,'Normalized'), set(gcf,'units','normalized'); end
ax_xlims = get(gca,'xlim');
ax_ylims = get(gca,'ylim');

pos_fig = get(gcf,'Position');
ndx_fig = pos_fig(3);
ndy_fig = pos_fig(4);

%axfu = get(gca,'Position'); %this wont work if axes are set to 'equal' or 'square'
nfu_ax = plotboxpos;

ndx_ax = nfu_ax(3);
ndy_ax = nfu_ax(4);

%ratios of axes units to figure units
rx_ax_fig = ndx_ax/ndx_fig;
ry_ax_fig = ndy_ax/ndy_fig;

%ratio of data units to axes units
rx_data_ax = diff(ax_xlims)/ndx_ax;
ry_data_ax = diff(ax_ylims)/ndy_ax;

%changes of nfu per change of axes units
%xc = xx nfu * (rx_data_ax du/axu) * (rx_ax_fig axu/nfu);

xc = xx * rx_data_ax * rx_ax_fig;
yc = yy * ry_data_ax * ry_ax_fig;

if ~strcmp(funits,'Normalized'), set(gcf,'units',funits); end

if ispos
    varargout{1} = [xc(1) yc(1) xc(2) yc(2)];
else
    varargout{1} = xc;
    varargout{2} = yc;
end

end