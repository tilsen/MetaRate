function [T] = tabulater(x,varargin)

p = inputParser;

def_sort = true;
def_sortby = 'percent';
def_sortdir = 'descend';

addRequired(p,'tbl');
addParameter(p,'sort',def_sort);
addParameter(p,'sortby',def_sortby);
addParameter(p,'sortdir',def_sortdir);

parse(p,x,varargin{:});

r = p.Results;

tbl = tabulate(x);


if iscell(tbl)
    T.cond = tbl(:,1);
    T.count = cell2mat(tbl(:,2));
    T.percent = cell2mat(tbl(:,3));
else
    T.cond = tbl(:,1);
    T.count = tbl(:,2);
    T.percent = tbl(:,3);
end

T = struct2table(T);

if r.sort
      T = sortrows(T,r.sortby,r.sortdir);
end

end