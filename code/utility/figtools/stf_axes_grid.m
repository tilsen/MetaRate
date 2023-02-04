function [axgrid] = stf_axes_grid(nax,varargin)

p = inputParser;

addRequired(p,'nax',@(x)isnumeric(x));
addParameter(p,'ncols',nan);
addParameter(p,'nrows',nan);
addParameter(p,'mincols',nan);
addParameter(p,'minrows',nan);
addParameter(p,'maxcols',nan);
addParameter(p,'maxrows',nan);

parse(p,nax,varargin{:});

r = p.Results;

if isnan(r.ncols) && isnan(r.nrows)
    
    if ~isnan(r.mincols) || ~isnan(r.maxcols)
        r.ncols = min(max(ceil(sqrt(nax)),r.mincols),r.maxcols);
        r.nrows = ceil(nax/r.ncols);
    else
        r.nrows = min(max(ceil(sqrt(nax)),r.minrows),r.maxrows);
        r.ncols = ceil(nax/r.nrows);
    end

elseif isnan(r.ncols)

    r.ncols = floor(nax/r.nrows);

elseif isnan(r.nrows)

    r.nrows = floor(nax/r.ncols);
end

npan = r.ncols*r.nrows;
axgrid = reshape(1:npan,r.ncols,[]);
axgrid((nax+1):end) = nan;
axgrid = axgrid';

end