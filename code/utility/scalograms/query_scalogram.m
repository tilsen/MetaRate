function [x,y,z] = query_scalogram(X,Y,Z,query_type,varargin)

p = inputParser;

def_center_range = [-inf inf];
def_scale_range = [0 inf];

addRequired(p,'X');
addRequired(p,'Y');
addRequired(p,'Z');
addRequired(p,'query_type');
addParameter(p,'center_range',def_center_range);
addParameter(p,'scale_range',def_scale_range);

parse(p,X,Y,Z,query_type,varargin{:});

res = p.Results;

keep_x_ix = X>=res.center_range(1) & X<=res.center_range(2);
keep_y_ix = Y>=res.scale_range(1) & Y<=res.scale_range(2);

X = X(keep_x_ix);
Y = Y(keep_y_ix);
Z = Z(keep_y_ix,keep_x_ix);

switch(res.query_type)
    case {'max'}
        [rix,cix] = find(Z==max(Z(:)));
        y = Y(rix);
        x = X(cix);
        z = Z(rix,cix);
       
    case {'avg'}
        y = Y;
        x = X;
        z = nanmean(Z(:));        %#ok<NANMEAN> 

    otherwise
        fprintf('unrecognized query type: %s\n',res.query_type); return
end


end