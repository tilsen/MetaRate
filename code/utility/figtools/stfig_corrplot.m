function [H] = stfig_corrplot(X,ax,varargin)

p = inputParser;

default_rows = 'pairwise';
default_ax = '';
default_rowlabels = {};
default_collabels = {};


addRequired(p,'X',@(x)(ismatrix(x) & size(x,1)>=size(x,2))|istable(X));
addOptional(p,'ax',default_ax,@(x)all(ishandle(x),'all'));
addParameter(p,'rows',default_rows);
addParameter(p,'rowlabels',default_rowlabels);
addParameter(p,'collabels',default_collabels);

parse(p,X,ax,varargin{:});

r = p.Results;

if istable(X)
    if isempty(r.rowlabels)
        r.rowlabels = X.Properties.VariableNames;
    end
    if isempty(r.collabels)
        r.collabels = X.Properties.VariableNames;
    end    
    X = table2array(X);
end


Nvar = size(X,2);

switch(isempty(p.Results.ax))
    case 1
        H.ax = stf([Nvar Nvar],[0.05 0.05 0.01 0.05],[0.01 0.01],'handlearray','matrix');
    otherwise
        if size(ax,1)~=size(ax,2)
            H.ax = reshape(ax,Nvar,[]);
        else
            H.ax = p.Results.ax;
        end
end

C = corr(X,'rows',r.rows);

for a=1:Nvar
    for b=1:Nvar
        set(gcf,'currentaxes',H.ax(b,a));
        if a==b
            H.histh(a) = histogram(X(:,a)); hold on;
        else
            H.ph(a,b) = scatter(X(:,a),X(:,b),'ko'); hold on;
        end
    end
end

end
