function [] = text_color_threshold(imh,th,varargin)

p = inputParser;

def_colors = [0 0 0; 1 1 1];
def_thresholds = 127.5;

addRequired(p,'imh',@(x)ishandle(imh) && numel(imh.CData)==numel(th));
addRequired(p,'th',@(x)all(ishandle(th),'all'));
addParameter(p,'thresholds',def_thresholds);
addParameter(p,'colors',def_colors);

parse(p,imh,th,varargin{:});

r = p.Results;

if size(r.colors,1)~=(numel(r.thresholds)+1)
    fprintf('error: number of colors must equal number of thresholds + 1\n');
    return;
end

cmap = get(imh.Parent,'Colormap');
cdata = imh.CData;
clim = get(imh.Parent,'CLim');

for i=1:numel(cdata)
    sc = (cdata(i)-clim(1))/range(clim);
    ix = min(1+floor(sc*size(cmap,1)),size(cmap,1));
    colors(i,:) = cmap(ix,:);
end

colors = colors*255;

f = [.299 .587 .114];
hsp = sqrt(sum(f.*colors.^2,2));

set(th,'color',r.colors(1,:));
for i=1:length(r.thresholds)
    set(th(hsp>r.thresholds(i)),'Color',r.colors(i+1,:));
end

end