function [x,y,z] = slice_scalogram(X,Y,Z,slice_type,slice_constant,varargin)

p = inputParser;

def_valid_only = true;

addRequired(p,'X');
addRequired(p,'Y');
addRequired(p,'Z');
addRequired(p,'slice_type');
addRequired(p,'slice_constant');
addParameter(p,'valid_only',def_valid_only);

parse(p,X,Y,Z,slice_type,slice_constant,varargin{:});

res = p.Results;

%fixed window edge
refcn = @(scale,tref)tref-scale/2;
lefcn = @(scale,tref)tref+scale/2;

switch(res.slice_type)
    case {'constant_center','center'}
        cn_ix = find(X>=res.slice_constant,1,'first');
        y = Y(~isnan(Z(:,cn_ix)));
        x = X(cn_ix)*ones(size(y,1),1);
        z = Z(:,cn_ix);

    case {'constant_scale','scale'}
        sc_ix = find(Y>=res.slice_constant,1,'first');
        x = X(~isnan(Z(sc_ix,:)));
        y = Y(sc_ix)*ones(size(x,1),1);
        z = Z(sc_ix,~isnan(Z(sc_ix,:)));

    case {'constant_rightedge','rightedge','re'}
        y = Y;
        x = refcn(y,res.slice_constant);
        z = arrayfun(@(c,d){Z(find(Y>=d,1,'first'),find(X>=c,1,'first'))},x,Y);
        z(cellfun(@(c)isempty(c),z)) = {nan};
        z = cell2mat(z);

    case {'constant_leftedge','leftedge','le'}
        y = Y;
        x = lefcn(y,res.slice_constant);
        z = arrayfun(@(c,d){Z(find(Y>=d,1,'first'),find(X>=c,1,'first'))},x,Y);
        z(cellfun(@(c)isempty(c),z)) = {nan};
        z = cell2mat(z);       

    case {'point'}
        cn_ix = find(X>=res.slice_constant(1),1,'first');
        sc_ix = find(Y>=res.slice_constant(2),1,'first');
        x = X(cn_ix);
        y = Y(sc_ix);
        z = Z(sc_ix,cn_ix);

    otherwise
        fprintf('unrecognized slice type: %s\n',slice_type); return
end

x = x(:);
y = y(:);
z = z(:);

if res.valid_only
    ix = ~isnan(z);
    x = x(ix);
    y = y(ix);
    z = z(ix);
end


end