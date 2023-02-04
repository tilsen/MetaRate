function [cmap] = stf_colormap(varargin)

p = inputParser;

defaultncol = 256;
defaultcol1 = [0 0 0];
defaultcol2 = [1 1 1];
defaultcol3 = [];

addOptional(p,'ncol',defaultncol);
iscolor = @(c)isvector(c) & length(c)==3 & all(c<=1) & all(c>=0);
addOptional(p,'col1',defaultcol1,iscolor);
addOptional(p,'col2',defaultcol2,iscolor);
addOptional(p,'col3',defaultcol3,iscolor);

parse(p,varargin{:});

ncol = p.Results.ncol;

nstep = 2;
col1 = p.Results.col1;
col2 = p.Results.col2;
if ~isempty(p.Results.col3)
    nstep=3;
    col3 = p.Results.col3;
end

switch(nstep)
    case 2
        cmap = [linspace(col1(1),col2(1),ncol)' linspace(col1(2),col2(2),ncol)' linspace(col1(3),col2(3),ncol)'];
    case 3
        cmap1 = [linspace(col1(1),col2(1),ceil(ncol/2))' linspace(col1(2),col2(2),ceil(ncol/2))' linspace(col1(3),col2(3),ceil(ncol/2))'];
        cmap2 = [linspace(col2(1),col3(1),floor(ncol/2))' linspace(col2(2),col3(2),floor(ncol/2))' linspace(col2(3),col3(3),floor(ncol/2))'];
        cmap = [cmap1(1:end,:); cmap2(2:end,:)];
            
end

end

