function [] = fig_rate_parameters()

%parses words/segments into syllables

dbstop if error; close all;
addpath('M:\Projects\toolboxes\hatchfill2_r8\');

[h,PH] = metarate_helpers();

load([h.data_dir 'metarate_segmentdata.mat'],'TR');

ix = 1; TR = TR(ix,:);
wavname = TR.trcode{1};
wavname = [wavname(1:4) 'B' wavname(5:7) 'S' wavname(8:10) 'R0' wavname(11:end)];
wavf = rdir([h.corpus_dir '**' filesep wavname '.wav']);
[wav,Fs] = audioread(wavf.name);
wav = 0.95*wav/max(abs(wav));
wavt = (0:length(wav)-1)/Fs;

W = table(TR.words{:}',TR.words_t0{:}',TR.words_t1{:}','VariableNames',{'lab','t0','t1'});
S = table(TR.sylbs{:}',TR.sylbs_t0{:}',TR.sylbs_t1{:}','VariableNames',{'lab','t0','t1'});
P = table(TR.phones{:}',TR.phones_t0{:}',TR.phones_t1{:}','VariableNames',{'lab','t0','t1'});

%add word indices
for i=1:height(S)
    S.ix(i) = find(W.t0<=S.t0(i) & W.t1>=S.t1(i));
end
S.nix = double(diff([0; S.ix])==0);
for i=2:height(S)
    if S.nix(i)==1
        S.rix(i) = S.rix(i-1)+1;
    else
        S.rix(i) = 0;
    end
end

%add sylb indices
for i=1:height(P)
    P.ix(i) = find(S.t0<=P.t0(i) & S.t1>=P.t1(i));
end

P.nix = double(diff([0; P.ix])==0);
for i=2:height(P)
    if P.nix(i)==1
        P.rix(i) = P.rix(i-1)+1;
    else
        P.rix(i) = 0;
    end
end

%targ_ix = find(ismember(P.lab,'UW1'),1,'last'); winrng = [-0.0 0.2];
targ_ix = find(ismember(P.lab,'UW1'),1,'first');

winrng = [
    -0.25 0.25;
    -0.35 0.35;
    -0.05 0.65];

%indicate excluded periods
P.exc = false(height(P),1);
P.exc(targ_ix) = true;
P.lab_generic = repmat({'{\it{ph}}'},height(P),1);
P.lab_generic([1 end]) = [{'',''}];

S.exc = false(height(S),1);
S.exc(P.ix(P.exc)) = true;
S.lab_generic = repmat({'\sigma'},height(S),1);
S.lab_generic([1 end]) = [{'',''}];

W.exc = false(height(W),1);
W.exc(S.ix(S.exc)) = true;

UX = {S,P};
TRG_t0 = P.t0(targ_ix);
TRG_t1 = P.t1(targ_ix);

t_anch = (TRG_t0+TRG_t1)/2;

rate_win = t_anch+winrng;

%%
axpan = [[1 1 1 1 1]' [2 3 4 5 5]'];
ax = stf(axpan,[0.01 0.11 0.005 0.075],[0.10 0.01],'aspect',2);
fs = [36 28 18 16];

%% ----classification---
axes(ax(1));
labs = {{'rate measurement','methods'},'signal-based','event-based',{'instantaneous', 'events'},{'extended events','(intervals)'},'non-exclusive','unit-based'};
N = array2table(labs','VariableNames',{'lab'});
N.ypos = [0 -1 -1 -2 -2 -3 -3]';
N.xpos = [0 -1  1  0  2  1 3]';

for i=1:height(N)
    th(i) = text(N.xpos(i),N.ypos(i),N.lab{i},...
        'hori','center','verti','mid','fontsize',fs(2),'Backgroundcolor','w'); hold on;
end

CC = [1 2; 1 3; 3 4; 3 5; 5 6; 5 7];
ylim([-3.5 0.5]);
xlim([-2 4]);
for i=1:size(CC,1)
    cc = connecting_line(th(CC(i,1)),th(CC(i,2)),'anchors','center','bounds','none');
    %cc = cc';
    PP = cc(1,:);
    PP(2,:) = PP(1,:)+[0 -0.5];
    PP(3,:) = [cc(2,1) PP(2,2)];
    PP(4,:) = [PP(3,1) cc(2,2)];

    %plot(cc(1,:),cc(2,:),'k-'); hold on;
    plot(PP(:,1),PP(:,2),'k-','linew',2); hold on;
end

for i=1:length(th)
    th(i) = text(N.xpos(i),N.ypos(i),N.lab{i},...
        'hori','center','verti','mid','fontsize',fs(2),'Backgroundcolor','w','edgecolor',[.7 .7 .7]); hold on;
end

%% ----waveform-------------
axes(ax(2));
plot(wavt,wav,'color','k'); hold on;

%% ----units
YO = [0.5 0.5];
ucol = [.5 .5 .5];
rot = 0;
FS = [12 8];
LW = [1 1 1];
axix = [3 4];
colors = lines(3);
fa = 0.5;

%----intervals
for i=1:length(UX)
    U = UX{i};
    U.midt = (U.t0+U.t1)/2;
    set(gcf,'currentaxes',ax(axix(i)));
    for j=1:height(U)
        if j>1
            line(U.t0(j)*[1 1],[0 1],'color',ucol,'linew',LW(i)); hold on;
        end
        if j<height(U)
            line(U.t1(j)*[1 1],[0 1],'color',ucol,'linew',LW(i)); hold on;
        end
        yo = YO(i);
        text(U.midt(j),yo,U.lab_generic{j},'fontsize',FS(i),'hori','center','rotation',rot,'verti','mid');
    end
end

%----fills
for i=1:length(UX)
    set(gcf,'currentaxes',ax(axix(i)));
    U = UX{i};
    ixs = find(U.t1>(rate_win(1,1)) & U.t0<=(rate_win(1,2)));

    for j=ixs'
        tt = min(max([U.t0(j) U.t1(j)],rate_win(1,1)),rate_win(1,2));
        p = diff(tt)/(U.t1(j)-U.t0(j));
        fap = max(fa*p,0.25);
        fh(i,j) = fill(tt([1 2 2 1]),[0 0 1 1],colors(i,:),'facealpha',fap,'edgecolor','none');
        if U.exc(j)
            if i==1
                %draw patch object for target segment in this tier
%                 tt = [TRG_t0 TRG_t1];
%                 fhtemp = fill(tt([1 2 2 1]),[0 0 1 1],colors(i,:),'facealpha',fap,'edgecolor','none');
%                 hatchfill2(fhtemp,'single','HatchDensity',100,...
%                     'HatchColor',0.85*[1 1 1],'HatchLineWidth',3,'HatchAngle',85);
                hatchfill2(fh(i,j),'single','HatchDensity',100,...
                    'HatchColor',0.85*[1 1 1],'HatchLineWidth',3,'HatchAngle',85);
            elseif i==2
                hatchfill2(fh(i,j),'single','HatchDensity',100,...
                    'HatchColor',0.85*[1 1 1],'HatchLineWidth',3,'HatchAngle',85);
            end
        end

        UX{i}.p(j) = p;
    end
end

%% ----rate windows
axes(ax(end));
oy = 0.05;
for i=1:size(rate_win,1)
    rw = rate_win(i,:);
    draw_hatchline(rw,-i,0.1,'color','k','linew',2); hold on;
    center = mean(rw);
    scale = diff(rw);
    plot(center,-i,'r.','markersize',30);
    text(rw(2)+0.025,-i,sprintf('loc: %1.2f, scale: %1.2f s',center-t_anch,scale),...
        'verti','mid','hori','left','fontsize',fs(3));

    if i==1
        rate = sum(UX{1}.p)/scale;
        str = ['$\frac{' num2str(rate,'%1.1f') '\sigma}{\mathrm{s}}\sim\frac{' num2str(1/rate,'%1.1f') '\mathrm{s}}{\sigma}$'];
        thr(i)=text(center,-i+0.1,str,'verti','bot','hori','center','fontsize',fs(2),'interp','latex');
    end
end
ylim([-i-1 0]+0.75);

%%
plot(t_anch*[1 1],ax(2).YLim,'r--','linew',2,'parent',ax(2));

%%
ax_meas = ax(2:end);
set(ax_meas,'XLim',minmax(wavt));
panlabs = {'waveform','syllables','phones',{'example','windows'}};
plh = stfig_panlab(ax_meas,panlabs,'verticalalignment','top','xoffset',-0.005,'fontsize',fs(2),'fontweight','normal');

%% parameters

arprops = {'length',6,'tipangle',30};
blw = 2;
parlabs = arrayfun(@(c)sprintf('[%i]',c),1:5,'un',0);

%unit type:
axbak = stbgax;
xo = -0.175;
yo = 0.85;
PP = [ax(3).Position*[1 0 xo 0; 0 1 0 yo]'; ax(4).Position*[1 0 xo 0; 0 1 0 yo]'];
bh(1) = drawbrace(PP(2,:),PP(1,:),0.005,'color','k','linew',blw);
thp(1) = text(min(bh(1).XData),mean(bh(1).YData),parlabs{1},'fontsize',fs(2),'hori','right');

%window scale
axes(ax(end));
PP = [rate_win([2 2],1) [-1 -2]'];
PP(:,1)=PP(:,1)-.02;
bh(2) = drawbrace(PP(2,:),PP(1,:),0.005,'color','k','linew',blw);
thp(2) = text(min(bh(2).XData),mean(bh(2).YData),parlabs{2},'fontsize',fs(2),'hori','right');

%window loc
PP = [mean(rate_win(2:3,:),2)+[0.01; -0.01] ([-2 -3]+[-.1 0.1])' ];
arrow(PP(1,:),PP(2,:),arprops{:});
arrow(PP(2,:),PP(1,:),arprops{:});
thp(3) = text(mean(PP(:,1)),mean(PP(:,2)),parlabs{3},...
    'fontsize',fs(2),'verti','mid','hori','center','Backgroundcolor','w');

%inversion
PP = reshape(thr(1).Extent*[1 0 0.25 0; 1 0 .75 0; 0 1 0 1.25; 0 1 0 1.25]',2,[]);
bh(4) = drawbrace(PP(1,:),PP(2,:),0.01,'color','k','linew',blw);
thp(4) = text(mean(bh(4).XData),max(bh(4).YData),parlabs{4},'fontsize',fs(2),'hori','center','verti','bot');

%exclusion
axes(ax(end-1));
thp(5) = text(t_anch,0.5,parlabs{5},'fontsize',fs(2),'hori','center','verti','bot');

%%
set(ax(1),'Visible','off');
set(ax_meas,'Box','off','tickdir','out','ticklen',0.003*[1 1],...
    'YTick',[],'fontsize',fs(end),'XGrid','on','Ycolor','w');
set(ax_meas(1:end-1),'XTickLabel',[]);
set(ax_meas(1:end-1),'XTick',[]);

dxt = 0.25;
xticks = sort(unique([TRG_t0:-dxt:-5 TRG_t0:dxt:5]));
set(ax_meas(end),'XTick',xticks);
set(ax_meas(end),'XTickLabel',arrayfun(@(c){sprintf('%1.2f',c-TRG_t0)},xticks));
xlabel(ax(end),'time (s) relative to target segment','fontsize',fs(2));


panlabs = {'(A) rate measure classification','(B) unit-based rate measure parameters'};
stfig_panlab(ax(1:2),panlabs,'verticalalignment','bot','xoffset',[0 -0.15],...
    'yoffset',[0.01 0.05],'fontsize',fs(1),'hori','left');


%%
h.printfig(mfilename);

end


