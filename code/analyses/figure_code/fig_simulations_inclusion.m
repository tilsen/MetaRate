function [] = fig_regression_inclusion()

dbstop if error; close all;
h = metarate_helpers;

load([h.figures_dir 'regression_inclusion_simulations.mat'],'S');

%%
ax = stf([1 2 3; 4 5 6],[0.05 0.085 0.01 0.05],[0.075 0.10]);

colors = flipud(lines(2));
vars = {'pcorr','corr_rate','ratecoef','classcoef','corr_rate_class','dAIC'};
% var_strs = {'{\itr}^2','{\it}r^{\prime}(\Omega_{emp} , dur)','corr(\Omega , \Omega_{emp})',...
%     '\beta_{\Omega}','\beta_{class}','corr(class , \Omega_{emp})'};
var_strs = {'{\it}r^{\prime}(\Omega_{emp} , dur)','corr(\Omega , \Omega_{emp})',...
    '\beta_{\Omega}','\beta_{class}','corr(class , \Omega_{emp})','\DeltaAIC (w/class - w/o class)'};

oo = 0.25;
for i=1:length(vars)
    axes(ax(i))
    x = S.(vars{i});
    sd = S.([vars{i} '_sd']);

    set(gca,'XLim',[minmax(S.Ns')+[-1 1]]); hold(gca,'on');

    for k=1:height(S)
        for j=1:2
            draw_hatchline(S.Ns(k)+oo*(j-1.5),x(k,j)+[-1 1]*sd(k,j),0.2,...
                'color',colors(j,:),'linew',2); hold on;
        end
    end
    for j=1:2
        ph(i,j) = plot(S.Ns+oo*(j-1.5),x(:,j),'o-','color',colors(j,:),'markerfacecolor','w','linew',2); hold on;
    end
end

axis(ax,'tight');
axrescalex(0.05,ax);
axrescaley(0.05,ax);

set(ax(3),'YLim',[0.975 1.025]);

%%
set(ax(1:length(vars)),'YGrid','on','XTick',S.Ns,'tickdir','out','fontsize',h.fs(end),'ticklen',0.003*[1 1]);

legstrs = {...
    'incl: dur\sim\beta_{cl}\cdotclass + \beta_{\Omega}\cdot\Omega_{incl}',...
    'excl: dur\sim\beta_{cl}\cdotclass + \beta_{\Omega}\cdot\Omega_{excl}'};

legend(ph(3,:),legstrs,'location','north','fontsize',h.fs(3));

stfig_panlab(ax(1:length(vars)),var_strs,'xoff',0,'fontsize',h.fs(3),'hori','left','fontweight','normal');

xlabel(ax(4:6),'number of units','fontsize',h.fs(3));

stfig_panlab(ax,[],'xoff',-0.05,'fontsize',h.fs(2),'hori','right','yoff',0.03);

%%
h.printfig(mfilename);

end