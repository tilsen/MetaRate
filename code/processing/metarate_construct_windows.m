function [WIN] = metarate_construct_windows(method,varargin)

p = inputParser;

def_restrict_edges = true;
def_scale_step = 0.05;
def_center_step = 0.025;

addRequired(p,'method');
addRequired(p,'scale_range',@(x)isvector(x)&all(x>0));
addRequired(p,'center_range',@(x)isnumeric(x));
addParameter(p,'scale_step',def_scale_step);
addParameter(p,'center_step',def_center_step);
addParameter(p,'restrict_edges',def_restrict_edges);

parse(p,method,varargin{:});

winpars = p.Results;

%all windows
scales = winpars.scale_range(1):winpars.scale_step:winpars.scale_range(2);
centers = winpars.center_range(1):winpars.center_step:winpars.center_range(2);
win_sc = combvec(scales,centers)';
WIN.scale = win_sc(:,1);
WIN.center = win_sc(:,2);
WIN = struct2table(WIN);
WIN.edges = WIN.center + WIN.scale*[-1 1]/2;

WIN.Properties.UserData = winpars;

%default is to restrict window edges on the basis of their center:
if p.Results.restrict_edges
    switch(method)
        case {'bywindow'}

        otherwise
            %restrict windows to center range:
            ix_win_keep = WIN.edges(:,1)>=winpars.center_range(1) & WIN.edges(:,2)<=winpars.center_range(2);
            WIN = WIN(ix_win_keep,:);
    end
end

end