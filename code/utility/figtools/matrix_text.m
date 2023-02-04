function [th] = matrix_text(M,varargin)

dbstop if error;

p = inputParser;

def_fontsize = get(0,'defaultaxesFontSize');
def_fontcolor = get(0,'defaultaxesColor');
def_fontweight = 'normal';
def_color_threshold = nan;
def_formatstr = '%1.2f';
def_parent = nan;
def_x = nan;
def_y = nan;

addRequired(p,'M',@(x)ismatrix(x) | iscell(x));
addParameter(p,'fontsize',def_fontsize);
addParameter(p,'fontcolor',def_fontcolor);
addParameter(p,'fontweight',def_fontweight);
addParameter(p,'color_threshold',def_color_threshold);
addParameter(p,'formatstr',def_formatstr);
addParameter(p,'parent',def_parent);
addParameter(p,'x',def_x);
addParameter(p,'y',def_y);

parse(p,M,varargin{:});

res = p.Results;

if ~ishandle(res.parent)
    res.parent = gca;
end

if ismatrix(M)
    Mstr = arrayfun(@(c)sprintf(res.formatstr,c),M,'un',0);
    Mstr(isnan(M)) = {''};
else
    Mstr = M;
end

if ~isnan(res.color_threshold) && size(res.fontcolor,1)==1
    res.fontcolor = repmat(res.fontcolor,2,1);
end

if isnan(res.x)
    res.x = 1:size(M,2);
end
if isnan(res.y)
    res.y = 1:size(M,1);
end

for r=1:size(M,1)
    for c=1:size(M,2)

        
        color = res.fontcolor(1,:);  
        
        if ~isnan(res.color_threshold)
            if M(r,c)<=res.color_threshold
                color = res.fontcolor(1,:);
            else
                color = res.fontcolor(2,:);
            end       
        end

        

        th(r,c) = text(res.x(c),res.y(r),Mstr{r,c},...
            'hori','center', ...
            'verti','mid', ...
            'color',color, ...
            'fontsize',res.fontsize, ...
            'fontweight',res.fontweight, ...
            'parent',res.parent);
    end
end


end