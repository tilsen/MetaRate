function [T] = crosstable(x,y,varargin)

p = inputParser;

addRequired(p,'x');
addRequired(p,'y');
addParameter(p,'Proportions','none');
addParameter(p,'Columntotals',false);
addParameter(p,'Rowtotals',false);
addParameter(p,'VariableNames','');

parse(p,x,y,varargin{:});

[tbl,~,~,labels] = crosstab(x,y);

cols = labels(~cellfun('isempty',labels(:,2)),2);
rows = labels(~cellfun('isempty',labels(:,1)),1);

if ~isempty(p.Results.VariableNames)
    cols = p.Results.VariableNames;
end

if p.Results.Columntotals
    tbl = [tbl; sum(tbl)];
    rows = [rows; {'TOTAL'}];
end

tbl_counts = tbl;
switch(p.Results.Proportions)
    case 'full'
        tbl = tbl/sum(tbl(:));
    case 'row'
        tbl = tbl./sum(tbl,2);
    case 'column'
        tbl = tbl./sum(tbl,1);
end

T = array2table(tbl,'VariableNames',cols);
T = addvars(T,rows,'before',1);

if p.Results.Rowtotals
    T.TOTAL = sum(tbl_counts,2);
end

end