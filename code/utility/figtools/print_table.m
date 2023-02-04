function [STR] = print_table(T,varargin)

p = inputParser;

def_number_format = {'%1.2f'};
def_separator = '\t';
def_print_headers = true;
def_print_rownames = true; %only if present
def_headers = [];
def_print = true;

addRequired(p,'T',@(x)istable(x));
addParameter(p,'number_format',def_number_format);
addParameter(p,'separator',def_separator);
addParameter(p,'print_headers',def_print_headers);
addParameter(p,'print_rownames',def_print_rownames);
addParameter(p,'headers',def_headers);
addParameter(p,'print',def_print);

parse(p,T,varargin{:});

res = p.Results;

%convert numeric columns to strings:
ff = T.Properties.VariableNames;
for i=1:length(ff)
    col_isnumeric(i) = isnumeric(T.(ff{i}));
end

number_format = res.number_format;
if numel(number_format)<sum(col_isnumeric)
    number_format = repmat(number_format(1),sum(col_isnumeric),1);
end

col_numeric = find(col_isnumeric);
for i=1:length(col_numeric)
    colf = ff{(col_numeric(i))};
    T.(colf) = arrayfun(@(c){sprintf(number_format{i},c)},T.(colf));
end

ncol = width(T);
seps = [repmat({[res.separator]},1,ncol-1) {'\n'}];

STR = table2array(T);
for a=1:size(STR,1)
    for b=1:size(STR,2)
        if iscategorical(STR{a,b})
            STR{a,b} = char(STR{a,b});
        end
        STR{a,b} = [STR{a,b} seps{b}];
    end
end

if res.print_headers
    if isempty(res.headers)
        headers = T.Properties.VariableNames;
    else
        headers = res.headers;
    end
    HDR = cellfun(@(c,d){sprintf(['%s' d],c)},headers,seps);

    STR = [HDR; STR];
end

if res.print_rownames
    if ~all(cellfun('isempty',T.Properties.RowNames))
        rownames = [{' '}; T.Properties.RowNames];
        rownames = cellfun(@(c){sprintf(['%s' seps{1}],c)},rownames);
        STR = [rownames STR];
    end
end

if res.print
    for a=1:size(STR,1)
        for b=1:size(STR,2)
            fprintf(STR{a,b});
        end
    end
end


end