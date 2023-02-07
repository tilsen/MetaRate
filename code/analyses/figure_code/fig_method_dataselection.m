function [] = fig_method_dataselection()

dbstop if error; close all;
h = metarate_helpers();

%%

panlabs = {...
    'utterance durations'
    'time from nearest utt. edge'
    'vowel durations'
    'prop. valid vowels (center = 0)'
    'prop. valid vowels (size = 0.5)'
    'prop. valid fast cond. (center = 0)'
    'avg. dist. from edge (center = 0)'
    'avg. dist. from begin (size = 0.5)'
    'avg. vowel dur. (center = 0)'    
    };

target = 'vowels';
unit = 'sylbs';
inversion = 0;
datasel = {'bytarget'};
exclusion = 1;
winmethod = {'extendwin'};

P(1).target = target;
P(1).unit = unit;
P(1).inversion = inversion;
P(1).datasel = datasel;
P(1).winmethod = winmethod;
P(1).exclusion = exclusion;

P = repmat(struct2table(P),2,1);

P.winmethod{2} = 'centered';
P.datasel{2} = 'bywindow';


%%

load([h.datasets_dir 'data_' target '.mat'],'D');

D.rateunit_t0 = D.([unit '_t0']);
D.rateunit_t1 = D.([unit '_t1']);
D.rateunit_dur = D.rateunit_t1-D.rateunit_t0;

D.utt_dur = D.utt_t1-D.utt_t0;

N_targets = height(D);

fprintf('%i targets\n',height(D));
fprintf('proportion normal condition: %1.2f\n',sum(ismember(D.rate,{'N'}))/height(D));

%densities

D.min_dist = min([D.t0-D.utt_t0 D.utt_t1-D.t1],[],2);
D.d_t0 = D.t0-D.utt_t0;
d = array2table({D.utt_dur, D.min_dist, D.dur}','VariableNames',{'x'});
d.labs = {'utterance durations' 'distances to nearest utterance edge' 'vowel durations'}';

max_utt_dur = max(d.x{1});
max_scale = round(max_utt_dur*10)/10-1;

for i=1:height(P)

    switch(P.winmethod{i})
        case {'begin_anchored'}
            scale_range = [0.5 max_scale];
            center_range = max_scale*[0 1];
            D.tanch = D.([P.unit{i} '_t1']);

        case {'end_anchored'}
            scale_range = [0.5 max_scale];
            center_range = max_scale*[-1 0];
            D.tanch = D.([P.unit{i} '_t0']);

        case {'centered','extendwin'}
            scale_range = [0.5 max_scale];
            center_range = max_scale*[-1 1];
            D.tanch = D.tmid;
    end

    WIN = metarate_construct_windows(P.datasel{i},scale_range,center_range);

    % calculate all absolute window edges
    [we0,we1] = metarate_data_window_edges(D,WIN,P.winmethod{i});
    %[we0x,we1x] = metarate_data_window_edges(D,WIN,P.winmethod{i+1});

    % exclude datapoints if selection method is bytarget
    switch(P.datasel{i})
        case 'bytarget'
            valid_ixs = we0>=D.utt_t0 & we1<D.utt_t1;
            WIN.N_valid = sum(valid_ixs,1)';            
            
        otherwise
            [WIN,valid_ixs] = count_vars_bywindow(D,WIN);

    end

    %avg distance to utt edge
    valid_ixs = double(valid_ixs);
    valid_ixs(valid_ixs==0) = nan;    
    WIN.avg_dist = nanmean(valid_ixs.*D.min_dist,1)'; %#ok<*NANMEAN> 
    WIN.avg_dt0 = nanmean(valid_ixs.*D.d_t0,1)';
    WIN.avg_dur = nanmean(valid_ixs.*D.dur,1)'; %#ok<*NANMEAN> 

    %proportion normal
    normal = repmat(strcmp(D.rate,{'N'}),1,height(WIN));
    WIN.N_normal = nansum(normal.*valid_ixs,1)'; %#ok<*NANSUM> 
    WIN.p_normal = WIN.N_normal ./ WIN.N_valid;

    %proportion valid
    WIN.p_valid = WIN.N_valid/N_targets;
    P.W{i} = WIN;

end

%%
panlab = [1 2 3; 4 5 6; 7 8 9];

ax = stf(panlab,[0.065 0.075 0.01 0.05],[0.085 0.125],'aspect',1.35);

%histograms
gcol = 0.75*[1 1 1];
for i=1:3
    axes(ax(i));
    x = d.x{i};
    edges = linspace(min(x)-0.0001,max(x)+0.01,25);
    histogram(d.x{i},edges,'facecolor',gcol);
end

%token proportions
colors = lines(height(P));
for j=1:3
    for i=1:height(P)
        win = P.W{i};
        switch(j)
            case 1
                ixs = win.center==0;
                xvals = win.scale(ixs);
                yvals1 = win.p_valid(ixs);
                yvals2 = win.avg_dist(ixs);
            case 2
                ixs = win.scale==0.5;
                xvals = win.center(ixs);
                yvals1 = win.p_valid(ixs);
                yvals2 = win.avg_dt0(ixs);

            case 3
                ixs = win.center==0;
                xvals = win.scale(ixs);
                yvals1 = 1-win.p_normal(ixs);
                yvals2 = win.avg_dur(ixs);
        end

        axes(ax(j+3));
        ph(j,i) = plot(xvals,yvals1,'-','color',colors(i,:),'linew',2); hold on;

        axes(ax(j+6));
        ph2(j,i) = plot(xvals,yvals2,'-','color',colors(i,:),'linew',2); hold on;
    end
end

%%
axh = ax(1:3);
axp = ax(4:6);
axq = ax(7:9);

defticks;
set(ax,'Box','off');

ylabel(axh,'count (thousands)');
ylabel(axp,'proportion');
ylabel(axq,'(s)');

xlabel(axh([1 3]),'duration (s)');
xlabel(axh(2),'time (s)');

xlabel(axq([1 3]),'window size (s)');
xlabel(axq(2),'window center (s)');

xlabel(axp([1 3]),'window size (s)');
xlabel(axp(2),'window center (s)');

set(axh,'YGrid','on');
set([axp axq],'XGrid','on','YGrid','on');

axis(ax,'tight');

axrescale(axh,0.025, [0 0.05]);

ylim(axp,getlims(axp,'y'));
axrescale([axp axq],[],[0 0.05]);

for i=1:length(axh)
    axh(i).YTickLabel = arrayfun(@(c){sprintf('%1.1f',c)},axh(i).YTick/1000);
end

legh(1) = legend(ph(1,:),{'across-window' 'by-window'});

th = stfig_panlab(ax,panlabs,'style','letter_title','fontsize',h.fs(2)-2);

th{1}(end-2).String = 'D^{\prime}';
th{1}(end-1).String = 'E^{\prime}';
th{1}(end-0).String = 'F^{\prime}';

obj_fontsize(gcf,'axes',h.fs(end)-2,'legend',h.fs(3),'label',h.fs(3)-2);

expand = @(c)c(:);
for i=4:9
    th{2}(i).String = expand(regexp(th{2}(i).String,'\s(?=\()','split','once'));
    th{2}(i).String{2} = [blanks(2) th{2}(i).String{2}]; 
    th{2}(i).VerticalAlignment = 'mid';
end

shiftposy(legh,-0.025);

%%
h.printfig(mfilename);

end

%% count valid by win
function [WIN,ix_valid] = count_vars_bywindow(D,WIN)

ix_valid = false(height(D),height(WIN));
for i=1:height(WIN)
    ix_valid(:,i) = ...
        (D.tanch + WIN.edges(i,1))>=D.utt_t0 & ...
        (D.tanch + WIN.edges(i,2))<=D.utt_t1;
end
    
WIN.N_valid = sum(ix_valid,1)';

%WIN.p_normal(i) = sum(ismember(D.rate(ix_valid),{'N'}))/WIN.N_valid(i);

end


