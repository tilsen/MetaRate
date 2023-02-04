function [] = fig_method_articulator_vel()

dbstop if error; close all;
[h,PH] = metarate_helpers();

files = rdir([h.corpus_dir '**' filesep 'data' filesep '*.mat']);

ix = 2; 

S = get_signals(files(ix));

%% 
min_peak_distance = 0.05;
min_peak_prominence = 0.03;

Fs = 1000;

%%
load([h.data_dir 'metarate_artic_vel.mat'],'TR');

TR = TR(ix,:);

velf = 'sysvel'; 

x = -TR.(velf){1};
x = x-min(x);
x = x/max(x);

totsysvel_norm = 1-x;

[~,minixs_all] = findpeaks(x);
[~,minixs] = findpeaks(x,'MinPeakProminence',min_peak_prominence,'MinPeakDistance',min_peak_distance);

utt_tspan = [TR.utt_t0 TR.utt_t1];
utt_ixs = round(h.frame_rate*utt_tspan);

%check if no valid starting index
ix0 = find(minixs<utt_ixs(1),1,'last');
if isempty(ix0) %fallback: add segment boundary halfway between utterance begin and signal start
    minixs = [round(mean([1 utt_ixs(1)])) minixs];
else
    minixs = minixs(ix0:end);
end

%check if no valid starting index
ix1 = find(minixs>utt_ixs(2),1,'first');
if isempty(ix1) %%fallback: add segment boundary halfway between utterance end and signal end
    minixs = [minixs round(mean([length(x) utt_ixs(2)])) ];
else
    minixs = minixs(1:ix1);
end

%add sps
minixs = unique([1 minixs length(x)]);

artics = [{'sp'} arrayfun(@(c){sprintf('a%02i',c)},1:numel(minixs)-3) {'sp'}];

TR.artics{1} = artics;
TR.artics_t0{1} = TR.t{1}(minixs(1:end-1));
TR.artics_t1{1} = TR.t{1}(minixs(2:end));

%%
ax = stf([1; 2; 3; 3; 4; 4; 5],[0.05 0.075 0.01 0.05],[0 0.01]);

rcolors = lines(5);
acolor = rcolors(end,:);

%---segmentation
axes(ax(1));
PH = S.A.PHONES;
for i=1:length(PH)
    plot(PH(i).OFFS(2)*[1 1],[0 1],'k-'); hold on;
    text(mean(PH(i).OFFS),2/3-mod(i,2)*1/3,PH(i).LABEL,'fontsize',h.fs(end),'hori','center');
end

%--- waveform
axes(ax(2));
x = S.A.SIGNAL;
x = x/max(abs(x));
plot(S.t_audio,x,'color',[.5 .5 .5]); hold on;
plot(TR.utt_t0*[1 1],[-1 1],'color','r','linew',2);
plot(TR.utt_t1*[1 1],[-1 1],'color','r','linew',2);

%--- velocities
axes(ax(3));
V = S.dY;
V = V/max(abs(V(:)));
colors = viridis(7);
colors = colors(reshape(repmat([1:7],3,1),[],1),:);
names = {S.X.NAME};
for i=1:size(V,1)
    plot(S.t_orig,V(i,:)+0.5*(i-1),'color',colors(i,:),'linew',1.5); hold on;
    if mod(i,3)==2
        text(-0.01,0.5*(i-1),names{floor(i/3)+1},'hori','right','fontsize',h.fs(3));
    end
end

%--- total system velocity
axes(ax(4));
plot(S.t_interp,totsysvel_norm,'linew',2,'color','k'); hold on;

tt = unique([TR.artics_t0{1} TR.artics_t1{1}]);
tt_all = TR.t{1}(minixs_all);
axis tight;
axrescaley(0.05,gca);
plot([tt_all; tt_all],repmat(ylim',1,length(tt_all)),'color',[.5 .5 .5],'linew',1.5,'linestyle','--');
plot([tt; tt],repmat(ylim',1,length(tt)),'color',acolor,'linew',3);

%--- articulatory event intervals
axes(ax(5));
artics = TR.artics{1};
plot([tt; tt],repmat([0; 1],1,length(tt)),'color',acolor,'linew',3); hold on;
for i=1:length(TR.artics{1})
    text(mean(tt(i:i+1)),2/3-mod(i,2)*1/3,artics{i},'hori','center','fontsize',h.fs(3));
end


%%
axis(ax([1 2 3 5]),'tight');
axrescaley(0.05,ax([1 2 4]));

set(ax,'box','off','tickdir','out','xlim',[0 max(S.t_interp)],...
    'ticklen',0.003*[1 1],'fontsize',h.fs(end));

set(ax(1:end-1),'XTickLabel',[]);
set(ax([1 2]),'XColor','none');
set(ax([1 2 3 5]),'YColor','none');
ylabel(ax(4),'total sys. vel.','fontsize',h.fs(3));
xlabel(ax(end),'time (s)','fontsize',h.fs(3));

stfig_panlab(ax(1),'The birch canoe slide on the smooth planks','hori','left','xoff',0,'fontweight','normal');

%%
h.printfig(mfilename);


end

%%
function [S] = get_signals(file)

Fs = 1000; %resample to this
chan_dims = [1 2 3];

chans = {'TR' 'TB' 'TT' 'UL' 'LL' 'ML' 'JAW'};

X = load(file.name);
ff = fieldnames(X);

X = X.(ff{1});

audio_ix = ismember({X.NAME},'AUDIO');
A = X(audio_ix);
t_audio = linspace(0,length(A.SIGNAL)-1,length(A.SIGNAL))/A.SRATE;


artic_ix = ismember({X.NAME},chans);
X = X(artic_ix);
len = arrayfun(@(c)size(c.SIGNAL,1),X);

%check for uniform sampling rate
sr = [X.SRATE];
Fs_orig = sr(1);

%collect signals
Y = arrayfun(@(c){c.SIGNAL(:,chan_dims)'},X');
Y = double(vertcat(Y{:}));

dY = cell2mat(arrayfun(@(c){gradient(Y(c,:))},(1:size(Y,1))'));
sysvel = sqrt(nansum(dY.^2)); %#ok<NANSUM>

dYc = reshape(dY,3,[],size(dY,2));
sumvel = sum(squeeze(sqrt(dYc.^2)));

t_orig = (0:len-1)/Fs_orig;
t_interp = (0:(Fs_orig/Fs):len-1)/Fs_orig;
ixnotnan = ~isnan(sysvel);
sysveli = interp1(t_orig(ixnotnan),sysvel(ixnotnan),t_interp,'makima');
sumveli = interp1(t_orig(ixnotnan),sumvel(ixnotnan),t_interp,'makima');

S.t_audio = t_audio;
S.t_orig = t_orig;
S.t_interp = t_interp;
S.X = X;
S.A = A;
S.Y = Y;
S.dY = dY;
S.dYc = dYc;
S.sysveli = sysveli;
S.sumveli = sumveli;

end