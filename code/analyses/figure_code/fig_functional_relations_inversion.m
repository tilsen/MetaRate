function [] = fig_functional_relations_inversion()

dbstop if error; close all;
h = metarate_helpers();

load([h.figures_dir 'analysis_comparisons.mat'],'D');

%% regression data
load([h.figures_dir 'example1_data.mat'],'X');
%load([h.figures_dir 'example2_data.mat'],'X');

ivars= {'rate_prop_resid','rate_inv_resid'};
dvar = 'dur_resid';

%reverse proper rate scale
%X.(ivars{1}) = -X.(ivars{1});

Np = 1000;
polyorder = 3;

for i=1:length(ivars)

    reg{i} = fitlm(X,['dur_resid~' ivars{i}]);
    Xd{i} = X.(ivars{i});
    Yd{i} = X.(dvar);

    xx{i} = linspace(min(Xd{i}),max(Xd{i}),Np);
    yy{i} = reg{i}.feval(xx{i});

    pp{i} = polyfit(Xd{i},X.dur_resid,polyorder);
    yysp{i} = polyval(pp{i},xx{i});

    prctiles_x(i,:) = prctile(Xd{i},[0.1 100-0.1]);
    prctiles_y(i,:) = prctile(Yd{i},[0.1 100-0.1]);

end


%%

D = D(ismember(D.data_selection,'bytarget'),:);
D = D(D.exclusion==1,:);
D = D(ismember(D.unit,{'phones'}),:);
D = D(ismember(D.target,{'vowels','consonants'}),:);

D = sortrows(D,{'ratio' 'target' 'unit'},{'descend','descend','ascend'});

ls = {'-',':'}';
D.ls = repmat(ls,height(D)/numel(ls),1);

for i=1:height(D)/2
    D.cent_slice_dz{i} = D.cent_slice_z{i} - D.cent_slice_z{i+height(D)/2};
    D.scale_slice_dz{i} = D.scale_slice_z{i} - D.scale_slice_z{i+height(D)/2};
end

D = D(1:end/2,:);

%%

plabs = {'proper - inverse (constant center = 0.0 s)','proper - inverse (constant scale = 0.5 s)',...
    'C\bullet dur \sim proper phone rate','C\bullet dur \sim inverse phone rate'};

xlabs = {'window scale (s)','window center (s)',...
    'residual proper rate (phn/s)','residual inverse rate (s/phn)'};

%%
ax = stf([1 2; 3 4],[0.085 0.085 0.01 0.055],[0.10 0.15],'handlearray','matrix','aspect',1.25);

%----constant center slices
axes(ax(1));
for i=1:height(D)
    phs(i) = plot(D.cent_slice_y{i},D.cent_slice_dz{i},...
        'color',D.color(i,:),'linew',3,'linestyle',D.ls{i}); hold on;
end

%----constant scale slices
axes(ax(2));
for i=1:height(D)
    plot(D.scale_slice_x{i},D.scale_slice_dz{i},...
        'color',D.color(i,:),'linew',3,'linestyle',D.ls{i}); hold on;
end

%----regression examples
axes(ax(3));
scatter(X.rate_prop_resid,X.dur_resid,...
    'o','sizedata',16,'markerfacealpha',0.1,...
    'markerfacecolor',.5*[1 1 1],'MarkerEdgeColor','none'); hold on;

plot(xx{1},yy{1},'r-','linew',3);
plot(xx{1},yysp{1},'c-','linew',3);

axes(ax(4));
scatter(X.rate_inv_resid,X.dur_resid,...
    'o','sizedata',16,'markerfacealpha',0.1,...
    'markerfacecolor',.5*[1 1 1],'MarkerEdgeColor','none'); hold on;

ph(1) = plot(xx{2},yy{2},'r-','linew',3);
ph(2) = plot(xx{2},yysp{2},'c-','linew',3);

%%
axis(ax,'tight');

set(ax(3),'XDir','reverse');

set(ax(3),'XLim',prctiles_x(1,:));
set(ax(4),'XLim',prctiles_x(2,:));

set(ax(3:4),'YLim',minmax(prctiles_y(:)'));

ylims = getlimss(ax(1:2),'y');
set(ax(1:2),'YLim',ylims);

axrescalex(0.025,ax);
axrescaley(0.025,ax);
for i=1:2
    plot(ax(i).XLim,[0 0],'k--','parent',ax(i));
end

set(ax,'Box','off','ygrid','on','xgrid','on','fontsize',h.fs(end),'tickdir','out');

xlabel(ax(1),xlabs{1},'FontSize',h.fs(2));
xlabel(ax(2),xlabs{2},'FontSize',h.fs(2));

xlabel(ax(3),xlabs{3},'FontSize',h.fs(2));
xlabel(ax(4),xlabs{4},'FontSize',h.fs(2));

ylabel(ax(1:2),'\Delta{\it{r}}^{\prime}','FontSize',h.fs(2),'Rotation',0,'verti','mid','hori','right');
ylabel(ax(3:4),'residual dur.','FontSize',h.fs(2));

legend(ph,{'linear fit','nonlinear fit'},'fontsize',h.fs(3),'location','northeast');

legstrs = cellfun(@(c,d)[upper(c(1)) ' ~ ' d],D.target,D.unit,'un',0);
legend(phs,legstrs,'fontsize',h.fs(3),'location','southeast','NumColumns',1);

plh1 = stfig_panlab(ax(:),arrayfun(@(c){char(c+64)},1:numel(ax)),...
    'fontweight','bold','fontsize',h.fs(1),'xoff',-0.05,'hori','right');

plh2 = stfig_panlab(ax(:),plabs, 'fontweight','normal','fontsize',h.fs(2),'xoff',0,'hori','left');

plh1(3).Position(1) = max(ax(3).XLim)+0.05*diff(ax(3).XLim);
plh2(3).Position(1) = max(ax(3).XLim);

%%
h.printfig(mfilename);

end



