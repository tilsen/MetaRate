function [] = fig_comparison_asymmetries()

dbstop if error; close all;
h = metarate_helpers;

load([h.figures_dir 'analysis_comparisons.mat'],'D');

D = tabindex(D,'winmethod','extendwin','exclusion',1);

%%

%----all values (exclusion)
D = D(ismember(D.unit,{'phones'}) & ismember(D.ratio,{'proper'}),:);

classes = {'consonants_simplexcodas','consonants_simplexonsets','vowels_stress1','vowels_stress0'};
D = D(ismember(D.target,classes),:);

D.ls = {'-' '-' ':' ':'}';
D.lw = 4*ones(height(D),1);
D.color = hsv(height(D));

%%
ax = stf([1 2],[0.065 0.115 0.01 0.075],[0.10 0.01],'aspect',2.5);

axes(ax(1));
for i=1:height(D)
    ph(i) = plot(D.cent_slice_y{i},D.cent_slice_z{i},...
        'linew',D.lw(i),'color',D.color(i,:),'linestyle',D.ls{i}); hold on;   
end

axes(ax(2))
for i=1:height(D)
    n = min([numel(D.re_slice_z{i}) numel(D.le_slice_z{i})]);
    dz = D.re_slice_z{i}(1:n) - D.le_slice_z{i}(1:n);
    plot(D.re_slice_y{i}(1:n),dz,...
        'linew',D.lw(i),'color',D.color(i,:),'linestyle',D.ls{i}); hold on;
end

%%
set(ax,'Box','off','XGrid','on','YGrid','on','fontsize',h.fs(end),'Tickdir','out','ticklen',0.003*[1 1]);

axis(ax,'tight');

ylim(ax(2),max(abs(ax(2).YLim))*[-1 1]);
axrescaley([-0.025 0.10],ax(1));
axrescaley(0.025,ax(2));
axrescalex(0.025,ax);
plot(ax(2).XLim,[0 0],'k--','parent',ax(2));
plot([0 0],ax(1).YLim,'k--','parent',ax(1));


legstrs = cellfun(@(c,d){[' ' c ' ' d]},D.symb,D.description);
legend(ph,legstrs,'fontsize',h.fs(2)+2,'location','southeast','NumColumns',1);

plabs = {
    {'scale dependence','(center = 0.0 s)'};
    'pre-target - post-target windows'};
ylabs = {'r^{\prime}','\Delta r^{\prime}'};
xlabs = {'window center (s)', 'window size (s)'};

for i=1:length(ax)
    ylabel(ax(i),ylabs{i},'fontsize',h.fs(1),'rotation',0,'hori','right');
    xlabel(ax(i),xlabs{i},'fontsize',h.fs(2));
end

stfig_panlab(ax,plabs,'fontsize',h.fs(1),'xoff',0.05,'hori','left',...
    'verti',{'mid' 'bot'},'fontweight','normal');
stfig_panlab(ax,[],'fontsize',h.fs(1),'xoff',0,'hori','right');


%%

h.printfig(mfilename);

end