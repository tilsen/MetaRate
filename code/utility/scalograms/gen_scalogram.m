function [X,Y,Z,varargout] = gen_scalogram(data,varargin)

dbstop if error;
%takes data table as input

%defaults:
dc = 0.001; % interpolation step for center
ds = 0.005; % interplation step for sizes

defaultdvar = 'acc_test';
defaultsteps = [dc ds];
defaultsmoothing = true;
defaultinterpolation = true;
defaultclipinvalid = true;
H.sigma = [1 1];
defaultfilter = H; %2D-gaussian filter properties
defaultgrid = false; %pre-interpolate to grid
defaultstat = 'mean';

p = inputParser;
addRequired(p,'data',@(c)istable(c));
addOptional(p,'dvar',defaultdvar,@ischar);
addOptional(p,'steps',defaultsteps);
addParameter(p,'smoothing',defaultsmoothing);
addParameter(p,'interpolation',defaultinterpolation);
addParameter(p,'clipinvalid',defaultclipinvalid);
addParameter(p,'filter',defaultfilter);
addParameter(p,'grid',defaultgrid);
addParameter(p,'stat',defaultstat);

parse(p,data,varargin{:});

H = p.Results.filter;
dvar = p.Results.dvar;
steps = p.Results.steps;

%% process table data for plotting

valid_center_fields = {'centers','center','location','loc'};
if ~ismember(valid_center_fields{1},data.Properties.VariableNames)
    ix = find(ismember(data.Properties.VariableNames,valid_center_fields), 1);
    if isempty(ix)
        fprintf('no valid centers field found\n'); return;
    else
        data = renamevars(data,data.Properties.VariableNames(ix),valid_center_fields(1));
    end
end

valid_size_fields = {'sizes','size','scale'};
if ~ismember(valid_size_fields{1},data.Properties.VariableNames)
    ix = find(ismember(data.Properties.VariableNames,valid_size_fields), 1);
    if isempty(ix)
        fprintf('no valid centers field found\n'); return;
    else
        data = renamevars(data,data.Properties.VariableNames(ix),valid_size_fields(1));
    end
end



%calculate means
switch(p.Results.stat)
    case 'sem'
        gs = grpstats(data,{'centers','sizes'},'sem','DataVars',dvar);
        scalogram_var = ['sem_' dvar];
        if p.Results.grid==true
            fprintf('warning: grid not compatible with non-default stat\n');
            return;
        end
    otherwise
        gs = grpstats(data,{'centers','sizes'},'mean','DataVars',dvar);
        scalogram_var = ['mean_' dvar];
end

Y = unique(data.sizes);

if p.Results.grid
    dd = data(data.sizes==Y(1),:);
    X = unique(dd.centers);
    Z = zeros(numel(Y),numel(X));
    gs = grpstats(dd,{'centers','sizes'},'mean','DataVars',dvar);
    Z(1,:) = gs.(scalogram_var);
    for i=2:length(Y)
        dd = data(data.sizes==Y(i),:);
        xc = unique(dd.centers);
        gs = grpstats(dd,{'centers','sizes'},'mean','DataVars',dvar);
        zi = interp1(xc,gs.(scalogram_var),X,'linear')';
        keepix = X>xc(1) & X<=xc(end);
        Z(i,keepix) = zi(keepix);
    end
 
else
    
    X = unique(data.centers);
    [~,gs.X_ix] = ismember(gs.centers,X);
    [~,gs.Y_ix] = ismember(gs.sizes,Y);
    
    Z = zeros(numel(Y),numel(X));
    for j=1:height(gs)
        Z(gs.Y_ix(j),gs.X_ix(j)) = gs.(scalogram_var)(j);
    end
end


varargout = {};
if p.Results.smoothing && p.Results.interpolation
    [X,Y,Z,Z_extrap,Z_filt] = smooth_scalogram(X,Y,Z,steps,H,p.Results.clipinvalid); 
    varargout{1} = Z_extrap;
    varargout{2} = Z_filt;
    
elseif p.Results.smoothing && ~p.Results.interpolation 
    [X,Y,Z,Z_extrap,Z_filt] = smooth_scalogram(X,Y,Z,[],H,p.Results.clipinvalid);
    varargout{1} = Z_extrap;
    varargout{2} = Z_filt;    
    
elseif p.Results.interpolation 
    [X,Y,Z] = smooth_scalogram(X,Y,Z,steps,p.Results.clipinvalid);
    
else
    [X,Y,Z] = smooth_scalogram(X,Y,Z,[],[],p.Results.clipinvalid);
end

X = double(X);
Y = double(Y);
Z = double(Z);

end

