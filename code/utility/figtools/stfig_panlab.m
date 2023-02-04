function [th] = stfig_panlab(ax,labs,varargin)

defaultlocation = 'northwest';
defaultverticalalignment = 'bottom';
defaulthorizontalalignment = 'right';
defaultfontsize = 30;
defaultfontweight = 'bold';
defaultyoffset = 0;
defaultxoffset = 0.01;
defaultpositionmode = 'dataunits';
defaultinterpreter = 'tex';
defaultstyle = '';

ax = ax(:);

p = inputParser;
addRequired(p,'ax',@(x)all(ishandle(x)));
addRequired(p,'labs');
addParameter(p,'location',defaultlocation);
addParameter(p,'horizontalalignment',defaulthorizontalalignment);
addParameter(p,'verticalalignment',defaultverticalalignment);
addParameter(p,'fontsize',defaultfontsize);
addParameter(p,'fontweight',defaultfontweight);
addParameter(p,'yoffset',defaultyoffset);
addParameter(p,'xoffset',defaultxoffset);
addParameter(p,'positionmode',defaultpositionmode);
addParameter(p,'interpreter',defaultinterpreter);
addParameter(p,'style',defaultstyle);

if isempty(labs)
    labs = arrayfun(@(c){char(c+64)},1:length(ax));
elseif isnumeric(labs)
    labs = arrayfun(@(c){char(c+64)},labs);
end

parse(p,ax,labs,varargin{:});
r = p.Results;

%% pre-defined styles
switch(r.style)
    case 'letter_title'
        th{1} = stfig_panlab(r.ax,[],'xoff',0,'yoff',0.01,'fontsize',r.fontsize,'hori','right','fontweight','bold');
        th{2} = stfig_panlab(r.ax,r.labs,'xoff',0.02,'yoff',0.01,'fontsize',r.fontsize-2,'hori','left','fontweight','normal');
        return;

    case 'plain_title'
        th = stfig_panlab(r.ax,r.labs,'xoff',0.00,'yoff',0.02,'fontsize',r.fontsize,'hori','left','fontweight','normal');
        return;

    case 'letter'
        th = stfig_panlab(r.ax,[],'xoff',0,'yoff',0.01,'fontsize',r.fontsize,'hori','right','fontweight','bold');
        return;
        
    case 'inner_label'
        th = stfig_panlab(r.ax,r.labs,'xoff',0.01,'yoff',0,'fontsize',r.fontsize,'hori','left','verti','top','fontweight','bold');
        return;        

    otherwise

end

%%

if ischar(labs)
    labs = {labs};
end

%expand yoffset and xoffset 
if numel(r.yoffset)~=length(ax)
    r.yoffset = r.yoffset(:)';
    r.yoffset = repmat(r.yoffset,length(ax),1);
end

if numel(r.xoffset)~=length(ax)
    r.xoffset = r.xoffset(:)';
    r.xoffset = repmat(r.xoffset,length(ax),1);
end

if numel(r.fontsize)~=length(ax)
    r.fontsize = r.fontsize(:)';
    r.fontsize = repmat(r.fontsize,length(ax),1);
end

if ~iscell(r.verticalalignment), r.verticalalignment = {r.verticalalignment}; end
if numel(r.verticalalignment)~=length(ax)
    r.verticalalignment = r.verticalalignment(:)';
    r.verticalalignment = repmat(r.verticalalignment,length(ax),1);
end

if ~iscell(r.horizontalalignment), r.horizontalalignment = {r.horizontalalignment}; end
if numel(r.horizontalalignment)~=length(ax)
    r.horizontalalignment = r.horizontalalignment(:)';
    r.horizontalalignment = repmat(r.horizontalalignment,length(ax),1);
end


switch(p.Results.positionmode)
    case 'outerposition'
        axbak = stbgax;
end

for i=1:length(ax)
    if isempty(labs{i}), continue; end
   
    switch(p.Results.positionmode)
        case 'outerposition'
            xlims = ax(i).OuterPosition([1 3])*[1 0; 1 1]';
            ylims = ax(i).OuterPosition([2 4])*[1 0; 1 1]';
            textax = axbak;
            scaleax = axbak;
    
        otherwise
            xlims = ax(i).XLim;
            ylims = ax(i).YLim;
            textax = ax(i);
            scaleax = ax(i);
    end
            
    switch(r.location)
        case 'northwest'
            xpos = xlims(1);
            ypos = ylims(2);
        case 'northeast'
            xpos = xlims(2);
            ypos = ylims(2);
        case 'north'
            xpos = mean(xlims);
            ypos = ylims(2);
        case 'southwest'
            xpos = xlims(1);
            ypos = ylims(1);
        case 'southeast'
            xpos = xlims(2);
            ypos = ylims(1);
        case 'south'
            xpos = mean(xlim);
            ypos = ylims(1);            
    end

    
    th(i) = text(xpos,ypos,labs{i},...
        'fontsize',r.fontsize(i),'hori',r.horizontalalignment{i},'verti',r.verticalalignment{i},...
        'parent',textax,'fontweight',r.fontweight,'interpreter',r.interpreter);
    
    th(i).Position(2) = th(i).Position(2) + r.yoffset(i)*diff(scaleax.YLim);
    th(i).Position(1) = th(i).Position(1) + r.xoffset(i)*diff(scaleax.XLim);
end
        

end