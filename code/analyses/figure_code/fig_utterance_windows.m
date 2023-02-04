function [] = fig_utterance_windows()

dbstop if error; close all;
h = metarate_helpers();

TARGS = metarate_targets;

% plot_units = {'phones' 'sylbs'};
% plot_units = {'sylbs' 'words'};
% plot_units = {'moras' 'sylbs'}; %moras do better than syllables
plot_units = {'phones' 'sylbs'};

scale = 1.0;

%fixed window size data
load([h.data_dir 'metarate_partialcorr_scalographs.mat'],'T');
T.rho(T.inversion==0)=-T.rho(T.inversion==0);

%extended win:
X1 = tabindex(T,'winmethod','extendwin','center',0,'inversion',0,'target','vowels_stress1','unit','phones');

%adaptive win
X2 = tabindex(T,'winmethod','adaptivewin','center',0,'inversion',0,'target','vowels_stress1','unit','phones');

%1 second, centered windows:
T = T(ismember(T.winmethod,'extendwin'),:);
T = T(T.sizes==scale & T.center==0,:);


%d/n compare artics
T = T(~ismember(T.unit,'artics'),:);

[~,ix] = ismember(T.target,TARGS.target);
T.symb = TARGS.symb(ix);

%utterance window data
x = load([h.data_dir 'metarate_corr_fullutt.mat']); U = x.T; clear('x');

[~,ix] = ismember(U.target,TARGS.target);
U.symb = TARGS.symb(ix);
U.description = TARGS.description(ix);

U = sortrows(U,{'target' 'unit' 'exclusion' 'inversion'});
U.rho(U.inversion==0)=-U.rho(U.inversion==0);

%comparison
X3 = tabindex(U,'inversion',X1.inversion(1),'target',X1.target{1},'unit',X1.unit{1},'exclusion',1);
X4 = tabindex(U,'inversion',X1.inversion(1),'target',X1.target{1},'unit',X1.unit{1},'exclusion',0);

%%

%by-target comparisons (proper rates, phones)
%by-target comparisons (proper rates, sylbs)
%inclusion effect in full utterance windows
%inversion effect

ax = stf([1 2; 3 5; 4 5],[0.055 0.05 0.01 0.05],[0.075 0.075],'aspect',1.45);

adjheight(ax(5),-0.15);
shiftposy(ax(5),0.025);

colors = [0.85*ones(1,3); 0.5*ones(1,3)];

for j=1:4

    axes(ax(j));

    switch(j)
        case {1,2}
            Tx = tabindex(T,'inversion',0,'exclusion',1,'unit',plot_units{j});
            Ux = tabindex(U,'inversion',0,'exclusion',1,'unit',plot_units{j});

            Tx = sortrows(Tx,'rho','descend');
            [~,ix] = ismember(Tx.target,Ux.target);
            Ux = Ux(ix,:);
            Y = [Tx.rho Ux.rho];
            bh = bar(Y);
            for i=1:height(Tx)
                text(i,0,Tx.symb{i},'hori','center','verti','top','fontsize',h.fs(3));
            end
            for i=1:2, bh(i).FaceColor = colors(i,:); end
            legh(j) = legend(bh,{'1 sec' 'utterance'},'fontsize',h.fs(3));


        case 4
            Ux = tabindex(U,'inversion',0,'exclusion',1,'target',{'vowels_stress1','consonants'});
            Ux = sortrows(Ux,{'target','rho'},{'descend','descend'});
            xpos = [1:4 6:9];
            colors = lines(4);
            colors = colors([1 4 2 3],:);
            Ux.color = repmat(colors,2,1);
            Ux.ratelab = repmat({'ph','\mu','\sigma','wrd'}',2,1);
            for i=1:height(Ux)
                bh(i) = bar(xpos(i),Ux.rho(i),'FaceColor',Ux.color(i,:)); hold on;
                text(xpos(i),Ux.rho(i),Ux.ratelab{i},'fontsize',h.fs(2),'verti','bot','hori','center')
            end

            text(2.5,0,Ux.symb{1},'hori','center','verti','top','fontsize',h.fs(3));
            text(7.5,0,Ux.symb{5},'hori','center','verti','top','fontsize',h.fs(3));

        case 3
            Ux = tabindex(U,'exclusion',0,'unit',plot_units{1});
            Ux.matched = circshift(Ux.rho,-1);
            Ux = sortrows(Ux(1:2:end,:),'rho','descend');
            bh = bar([Ux.rho Ux.matched]);
            for i=1:height(Ux)
                text(i,0,Ux.symb{i},'hori','center','verti','top','fontsize',h.fs(3));
            end
            for i=1:2, bh(i).FaceColor = colors(i,:); end
            legh(i) = legend(bh,{'proper' 'inverse'},'fontsize',h.fs(3));
            tlegU = Ux;
    end
end

axes(ax(5));
X = {X3,X4,X1,X2};
colors = [0 0 0; .5 .5 .5;lines(2)];
for i=1:length(X)
    x = X{i};
    switch(i)
        case {3,4}
            sph(i) = plot(x.sizes,x.rho,'-','color',colors(i,:),'linew',3); hold on;
            plot(x.sizes,x.rho,'o','color',colors(i,:),'linew',1,'markerfacecolor','w'); hold on;
        case {1,2}
            sph(i) = plot([0 max(X{4}.sizes)],x.rho*[1 1],'--','linew',2,'color',colors(i,:)); hold on;
    end
end


%%

axis(ax,'tight');
axb = ax(1:end-1);
ylim(axb,getlims(axb,'y'));
axrescale(axb,0.02,[0 0.05]);
axrescale(ax(end),0.01,0.05);

set(ax,'fontsize',h.fs(end),'Box','off','YGrid','on', ...
    'TickDir','out','TickLen',0.003*[1 1]);

set(axb,'XTick',[],'YTick',0:0.1:0.5);
xlabel(ax(end),'scale (s)','fontsize',h.fs(3));

set(ax(end),'XGrid','on');

comp_labs = {...
    'proper phone rate: 1 sec. vs. utterance windows'
    'proper sylb rate: 1 sec. vs. utterance windows'
    'utterance win. phone rate: proper vs. inverse rate'
    'utterance win: comparison of proper rate units'    
    'scale dependence of correlation (prim. stress vowels)'};

stfig_panlab(ax,comp_labs,'xoff',0,'hori','left','fontsize',h.fs(3),'fontweight','normal');

axw = 0.40; axh = 0.10;
ax_tleg = axes('position',[0.98-axw ax(end).Position*[0 1 0 1.12]' axw axh]);
targets_legendr(tlegU,ax_tleg,'fontsize',h.fs(end),'numcols',3);

stfig_panlab(ax,{'A' 'B' 'C' 'D' 'E'},'xoff',-0.015,'fontsize',h.fs(2));

ylabel(ax,'{\it{r}}^{\prime}  ','fontsize',h.fs(2),'rotation',0,'hori','right');

set(legh,'fontsize',h.fs(end),'location','northeast');

sclegstrs = {'utterance window (rate unit excl.)','utterance win. (rate unit incl.)','across-window data selection','adaptive window'};
sclegh = legend(sph, sclegstrs, 'fontsize',h.fs(3),'location','southeast');

%%

h.printfig(mfilename);

end