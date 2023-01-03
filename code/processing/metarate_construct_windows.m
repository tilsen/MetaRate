function [WIN] = metarate_construct_windows(method,varargin)

p = inputParser;

def_scale_range = nan;
def_center_range = nan;
def_scale_step = 0.05;
def_center_step = 0.025;

addRequired(p,'method');
addParameter(p,'scale_range',def_scale_range);
addParameter(p,'center_range',def_center_range);
addParameter(p,'scale_step',def_scale_step);
addParameter(p,'center_step',def_center_step);

parse(p,method,varargin{:});

winpars = p.Results;

%----scale ranges
if isnan(winpars.scale_range)
    switch(winpars.method)
        case 'bywindow'  %use all data that fits in given window
            winpars.scale_range = [0.05 1.5];
        case 'bytarget'  %only include data that fits in all windows
            winpars.scale_range = [0.05 1];
        case {'endanchored','beginanchored'}
            winpars.scale_range = [0.05 1.5];
        case 'extendwin'
            winpars.scale_range = [0.05 1.0];            
        case 'adaptivewin'
            winpars.scale_range = [0.05 inf];
    end
end

%----centers :
if isnan(winpars.center_range)
    switch(winpars.method)
        case 'bywindow'                     
            winpars.center_range = [-1 1];
        case 'bytarget'
            winpars.center_range = [-0.5 0.5];
        case 'endanchored'
            winpars.center_range = [-1.5 0];     
        case 'beginanchored'
            winpars.center_range = [0 1.5];  
        case 'extendwin'
            winpars.center_range = [-0.5 0.5];                  
        case 'adaptivewin'
            winpars.center_range = [-1 1];            
    end
end

%

%all windows
scales = winpars.scale_range(1):winpars.scale_step:winpars.scale_range(2);
centers = winpars.center_range(1):winpars.center_step:winpars.center_range(2);
win_sc = combvec(scales,centers)';
WIN.scale = win_sc(:,1);
WIN.center = win_sc(:,2);
WIN = struct2table(WIN);
WIN.edges = WIN.center + WIN.scale*[-1 1]/2;

WIN.Properties.UserData = winpars;


end