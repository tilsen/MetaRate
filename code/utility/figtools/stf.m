function [varargout] = stf(varargin)

dbstop if error;
p = inputParser;

default_axpan = [1 1];
default_aspect = Inf;
default_bare = true;
default_exmarg = [0.05 0.05 0.01 0.01];
default_inmarg = [0.05 0.05];
default_handlearray = 'vector';
default_parent = [];

addOptional(p,'axpan',default_axpan,@(x)isnumeric(x) || ishandle(x));
addOptional(p,'exmarg',default_exmarg,@(x)isnumeric(x));
addOptional(p,'inmarg',default_inmarg,@(x)isnumeric(x));
addParameter(p,'aspect',default_aspect);
addParameter(p,'bare',default_bare);
addParameter(p,'handlearray',default_handlearray);
addParameter(p,'parent',default_parent);

%parse(p,axpan,exmarg,inmarg,varargin{:});
parse(p,varargin{:});

make_bare = @(h)set(h,'menubar','none','toolbar','none','name','','numbertitle','off');

defpos = get(0,'defaultFigurePosition');

if nargin==0
    figh = figure('units','normalized','position',defpos);
    if p.Results.bare, make_bare(figh); end
    setaspect(p.Results.aspect,figh);
    varargout = {figh};
    return;
end

if isempty(p.Results.parent)
    figh = figure('units','normalized','position',defpos);
    if p.Results.bare, make_bare(figh); end

    if isinf(p.Results.aspect)
        set(figh,'WindowState','maximized');
    else
        setaspect(p.Results.aspect,figh);
    end
    restore_units = 'normalized';
    restore_pos = get(figh,'position');

else
    figh = p.Results.parent;
    restore_units = figh.Units;
    restore_pos = get(figh,'position');
    set(figh,'Units','normalized');
end

ax = stfig_axpos(p.Results.axpan,[p.Results.exmarg p.Results.inmarg]);

switch(p.Results.handlearray)
    case 'matrix'
        if all(size(p.Results.axpan)==[1 2])
            ax = reshape(ax,p.Results.axpan(2),[])';
        else
            ax = ax(p.Results.axpan);
        end
end

set(figh,'Units',restore_units,'Position',restore_pos);

varargout = {ax,figh};

end