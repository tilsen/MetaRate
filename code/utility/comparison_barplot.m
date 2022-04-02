function [h] = comparison_barplot(D,plotvar,varargin)

p = inputParser;

def_plotvar = 'avg_rho';
def_orientation = 'vertical';
def_hatchfill = true;
def_parent = gca;
def_barwidth = 0.75;
def_fontsize = 14;
def_hatchspacing = 0.02; % relative to axes data range
def_labelfield = 'symb';

addRequired(p,'D',@(x)istable(x));
addOptional(p,'plotvar',def_plotvar,@(x)all(ischar(x)));
addParameter(p,'orientation',def_orientation);
addParameter(p,'hatchfill',def_hatchfill);
addParameter(p,'parent',def_parent);
addParameter(p,'barwidth',def_barwidth);
addParameter(p,'fontsize',def_fontsize);
addParameter(p,'hatchspacing',def_hatchspacing);
addParameter(p,'labelfield',def_labelfield);

parse(p,D, plotvar,varargin{:});

r = p.Results;
plotvar = r.plotvar;

lims = minmax(D.(plotvar)');
dlims = diff(lims);

axes(r.parent);

switch(r.orientation)
    case 'vertical'

        do = dlims*0.1;
        ylim(lims+0.125*dlims*[-1 1]);
        hold on;

        for i=1:height(D)
            val = D.(plotvar)(i);
            %h.bh(i) = bar(i,val,r.barwidth,'FaceColor',D.color(i,:));
            h.bh(i) = fill(i + [-1 1 1 -1]*r.barwidth/2,[0 0 val val],D.color(i,:),'EdgeColor','k','linewidth',0.5);

            oo = 0.005+mod(i-1,2)*do;

            val = max(0,val);

            h.th(i) = text(i,val+oo,D.(r.labelfield){i},...
                'fontsize',r.fontsize,'HorizontalAlignment','left','Rotation',90);

            if mod(i-1,2)>0
                toff = h.th(i).Extent(2);
                adj = do*[1 -1]*0.1;
                h.lh(i) = plot([i i],[val toff]+adj,':','linew',0.5,'color',0.5*[1 1 1]);
            end

        end
        set(gca,'XTick',[],'YGrid','on','fontsize',r.fontsize,'xlim',[1 height(D)] + [-1 1]);
        h.zerolh = plot(xlim,[0 0],'k-');

        switch(plotvar)
            case 'avg_rho'
                h.labh = ylabel('{\it{R}}^{\prime} ','fontsize',r.fontsize+4,'rotation',0,'hori','right');
            case 'd_avg_rho'
                h.labh = ylabel('\Delta{\it{R}}^{\prime} ','fontsize',r.fontsize+4,'rotation',0,'hori','right');
        end

    case 'horizontal'

        do = dlims*0.1;
        xlim(lims+0.125*dlims*[-1 1]);
        hold on;

        for i=1:height(D)
            val = D.(plotvar)(i);
            %h.bh(i) = barh(i,val,r.barwidth,'FaceColor',D.color(i,:));
            h.bh(i) = fill([0 0 val val],i + [-1 1 1 -1]*r.barwidth/2,D.color(i,:),'EdgeColor','k','linewidth',0.5);

            oo = 0.005; %+mod(i-1,2)*do;

            h.th(i) = text(val+oo,i,D.(r.labelfield){i},...
                'fontsize',r.fontsize,'HorizontalAlignment','left');

%             if mod(i-1,2)>0
%                 toff = h.th(i).Extent(1);
%                 adj = do*[1 -1]*0.1;
%                 h.lh(i) = plot([i i],[val toff]+adj,':','linew',0.5,'color',0.5*[1 1 1]);
%             end
        end
        set(gca,'YTick',[],'XGrid','on','fontsize',r.fontsize,'Ylim',[1 height(D)] + [-1 1]);
        h.zerolh = plot([0 0],ylim,'k-');

        switch(plotvar)
            case 'avg_rho'
                h.labh = xlabel('{\it{R}}^{\prime}','fontsize',r.fontsize+4);
            case 'd_avg_rho'
                h.labh = xlabel('\Delta{\it{R}}^{\prime}','fontsize',r.fontsize+4);
        end
        

end

if r.hatchfill
    quickhatch(h.bh(D.hatch),r.orientation,'w',0.5,r.hatchspacing);
    set(h.bh(D.hatch),'FaceAlpha',0.75);
end

set(gca,'tickdir','out','TickLen',0.003*[1 1]);

end
