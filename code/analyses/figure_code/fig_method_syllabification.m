function [] = fig_syllabification_method()

%parses words/segments into syllables (treats sp as syllables)

dbstop if error; close all;
[h,PH] = metarate_helpers();

load([h.data_dir 'metarate_segmentdata.mat'],'TR');

disallowed_onsets = metarate_disallowed_onsets(PH);

%%
ix(1) = find(cellfun(@(c)ismember('ACTRESS',c),TR.words),1,'first');
ix(2) = find(cellfun(@(c)ismember('ABRUPT',c),TR.words),1,'first');
for i=1:length(ix)
    [T{i},C{i},tr{i}] = sylbparse(TR(ix(i),:),disallowed_onsets);
end

C{1} = C{1}{end};
C{2} = C{2}{end};

%%
ax = stf([1 1; 2 3],[0.05 0.01 0.01 0.05],[0.10 0.15]);

ax(1).Position([1 3])=ax(1).Position([1 3]) + 0.1*[1 -1];

axes(ax(1));
ff = setdiff(fieldnames(T{1}),{'unsyllabified','new_sylb','sylb','phone'},'stable');

ff = {
    'wix'
    'begins_word'
    'ends_word'
    'son1'
    'isphone'
    'isvowel'
    'iscons'
    'prec_isvowel'
    'prec_iscons'
    'prec_insameword'
    'next_isvowel'
    'next_iscons'
    'next_insameword'};

ff_labs = ff;
ff_labs(ismember(ff_labs,'wix')) = {'word index'};
ff_labs(ismember(ff_labs,'son1')) = {'sonority'};
ff_labs = regexprep(ff_labs,'_',' ');

M = nan(numel(ff),length(T{1}.phone));
for i=1:length(ff)
    M(i,:)  = T{1}.(ff{i});
end

for i=1:size(M,1)
    m = M(i,:);
    m(isnan(m))=0;
    mc = m;
    switch(ff{i})
        case 'son1'
            mc(mc==0)=1;
            m(m>0) = m(m>0)-1;
            colors = hsv(numel(unique(m)));            
        case 'wix'
            colors = viridis(numel(unique(m)));
        otherwise
            colors = [1 1 1; .5 .5 .5];
            mc=m+1;
    end
    for j=1:size(m,2)
        fill(j+[-.5 .5 .5 -.5],i+[.5 .5 -.5 -.5],colors(mc(j),:),'EdgeColor','none'); hold on;
        text(j,i,num2str(m(j)),'hori','center','verti','mid','fontsize',h.fs(3));
    end
end
phones = T{1}.phone;
for j=1:length(phones)
    text(j,0,phones{j},'hori','center','verti','mid','fontsize',h.fs(3));
end
ylim(ylim+[-1 0]);
set(gca,'YDir','reverse');

axis tight;
for i=1:length(ff)
    text(min(xlim)-0.1,i,ff_labs{i},'hori','right','fontsize',h.fs(2)-2);
end

ST_matrix_gridlines(ax(1),'k');
set(gca,'XTick',[],'YTick',[]);

%---------------
headers = {'cand' 'parse' 'sonority' 'pks/\sigma' '(i) SSP' '(ii) ph-viol.' '(iii) max-ons' 'cost'};
pp = {'fontsize',h.fs(3)};

for i=1:length(C)
    c = C{i};
    c.parse_son1{end,1} = c.son1{end};
    c = c(1:end-1,:);
    
    axes(ax(i+1));
    for j=1:height(c)

        son_str = [c.parse_son1{j,1}-1 nan c.parse_son1{j,2}-1];
        son_str = regexprep(strrep(num2str(son_str),'NaN','.'),'  ',' ');

        strs = {num2str(j),c.parse_str{j},son_str,num2str(c.parse_npeaks(j,:)),...
            num2str(c.npeaks(j)~=2),...    
            num2str(c.phonotactic_violations(j)),...            
            num2str(c.max_ons(j)),...
            num2str(c.cost(j))};

        for k=1:length(strs)
            th(j,k) = text(k-1,-j,strs{k},pp{:}); hold on;
        end

    end

    %respace columns
    ylim([-height(c)-0.25 0]);
    ext = cell2mat(get(th(:,end),'Extent'));
    xlim([-0.1 max(sum(ext(:,[1 3]),2))]);

    xmarg = 0.2;
    for k=2:size(th,2)
        ext = cell2mat(get(th(:,k-1),'Extent'));
        xo = max(sum(ext(:,[1 3]),2));
        for j=1:size(th,1)
            th(j,k).Position(1) = xo+xmarg;
        end
        drawnow;
        plot(xo+xmarg/2*[1 1],[ylim],'k-');
        colx(k) = xo+xmarg/2;
    end
    ylim([-height(c)-1 0]);
    ext = cell2mat(get(th(:,end),'Extent'));
    xo = max(sum(ext(:,[1 3]),2));
    xlim([-0.1 xo]);

    
    colx(1) = 0;
    colx(end+1) = max(xlim);
    rots = [0 0 0 1 1 1 1 0]*90;
    for j=1:length(headers)
        switch(rots(j)==0)
            case 1
                hth(j) = text(mean(colx(j:j+1)),-0.5,headers{j},...
                    'rotation',rots(j),'fontsize',h.fs(2),'hori','center');
            otherwise
                hth(j) = text(mean(colx(j:j+1)),-0.65,headers{j},...
                    'rotation',rots(j),'fontsize',h.fs(2),'hori','left');
        end
    end
    hth(1).HorizontalAlignment = 'right';
    
    plot(xlim+[-0.25 0],-0.75*[1 1],'k-','Clipping','off');

    [~,ix_lowest] = min(c.cost);

    set(th(:,1),'Hori','right');
    th(ix_lowest,1).String = ['\rightarrow ' th(ix_lowest,1).String];

end

%%
set(ax(2:end),'Visible','off');

stfig_panlab(ax(1),{'A'},'location','southwest','xoff',-0.145);
stfig_panlab(ax(2:3),{'B' 'C'},'xoff',-0.05);
stfig_panlab(ax(2:3),{'"actress"' '"abrupt"'},'xoff',0,'fontweight','normal','hori','left');

%%
h.printfig(mfilename);

end


%% parse trials
function [T,C,TR] = sylbparse(TR,disallowed_onsets)

i=1;

T=[];
N = length(TR.phones{i});

%
T.unsyllabified = true(1,N);
T.new_sylb = nan(1,N);
T.phone = TR.phones{i};
T.son1 = TR.phones_son1{i};
T.wix = TR.phones_word_ix{i};
T.isphone = TR.phones_type{i}>0;
T.isvowel = TR.phones_type{i}==1;
T.iscons = TR.phones_type{i}==2;
T.prec_isvowel = [false T.isvowel(1:end-1)];
T.prec_iscons = [false T.iscons(1:end-1)];
T.next_isvowel = [T.isvowel(2:end) false];
T.next_iscons = [T.iscons(2:end) false];
T.prec_insameword = [false diff(T.wix)==0];
T.next_insameword = [diff(T.wix)==0 false];
T.begins_word = [true diff(T.wix)==1];
T.ends_word = [diff(T.wix)==1 true];

%#{X} - segment that starts a new word is a new syllable
T.new_sylb(T.begins_word) = true;

%{V}{V} vowel hiatus: second vowel is new syllable
T.new_sylb(T.isvowel & T.prec_isvowel) = true;

%for each word, determine if one or more sonority peaks (stops=fricatives)
word_phone_ixs = arrayfun(@(c)find(T.wix==c),unique(T.wix),'un',0);
for j=1:length(word_phone_ixs)
    ixs = word_phone_ixs{j};
    if numel(ixs)>2 && numel(findpeaks([0 T.son1(ixs) 0]))>1
        phones = T.phone(ixs);
        son = T.son1(ixs);
        CANDS = repmat(array2table({phones,son},'variablenames',{'parse' 'son1'}),length(phones),1);
        for k=1:height(CANDS)-1
            CANDS.parse{k} = [CANDS.parse{k}(1:k) {'.'} CANDS.parse{k}(k+1:end)];
            CANDS.parse_son1(k,:) = [{son(1:k), son(k+1:end)}];
            CANDS.parse_npeaks(k,:) = [numel(findpeaks_son(CANDS.parse_son1{k,1})) numel(findpeaks_son(CANDS.parse_son1{k,2}))];
        end
        CANDS.parse_str = cellfun(@(c)strjoin(c),CANDS.parse,'un',0);
        CANDS.phonotactic_violations = sum(cell2mat(cellfun(@(c)contains(CANDS.parse_str,c)',disallowed_onsets,'un',0)))';
        %CANDS.phonotactic_violation = double(contains(CANDS.parse_str,disallowed_onsets));
        CANDS.npeaks = sum(CANDS.parse_npeaks,2);
        CANDS.max_ons = (1:height(CANDS))';
        CANDS.cost = 1000*(CANDS.npeaks~=2) + 100*CANDS.phonotactic_violations + CANDS.max_ons;

        [~,best_cand_ix] = min(CANDS.cost);
        T.new_sylb(ixs(1)+best_cand_ix) = true;

        C{j} = CANDS;
    end
end

T.sylb = cumsum(T.new_sylb,'omitnan');
TR.phones_sylb_ix{i} = T.sylb;

%%
usylbix = unique(TR.phones_sylb_ix{i}(~isnan(TR.phones_sylb_ix{i})));
TR.sylbs{i} = arrayfun(@(c)strjoin(TR.phones{i}(ismember(TR.phones_sylb_ix{i},c)),' '),usylbix,'un',0);
TR.sylbs_t0{i} = arrayfun(@(c)TR.phones_t0{i}(find(T.sylb==c,1,'first')),usylbix);
TR.sylbs_t1{i} = arrayfun(@(c)TR.phones_t1{i}(find(T.sylb==c,1,'last')),usylbix);

if length(TR.sylbs_t0{i})~=length(TR.sylbs_t1{i})
    fprintf('\nERROR parsing syllables: '); disp_parse(T);
    return;
end


end

% %% make table of word-syllable-phone parses (for manual inspection):
% N_words = arrayfun(@(c)length(TR.words{c}),(1:height(TR))');
% words = [TR.words{:}];
% tr_ixs = arrayfun(@(c)repmat(c,N_words(c),1),(1:height(TR))','un',0);
% tr_ixs = vertcat(tr_ixs{:});
%
% [uwords,ia,~] = unique(words);
% P.word = uwords';
% P.first_trial = tr_ixs(ia);
% P = struct2table(P);
% P.sylb_1 = repmat({''},height(P),1);
% P.sylb_2 = repmat({''},height(P),1);
% for i=1:height(P)
%     tr = TR(tr_ixs(ia(i)),:);
%     wix = find(strcmp(tr.words{:},P.word{i}),1,'first');
%     phones_ix = ismember(tr.phones_word_ix{:},wix);
%     sylb_ix = tr.phones_sylb_ix{:}(phones_ix);
%     usylb_ix = unique(sylb_ix);
%     if ~isnan(usylb_ix)
%         for j=1:length(usylb_ix)
%             P.(['sylb_' num2str(j)]){i} = tr.sylbs{1}{usylb_ix(j)};
%         end
%     end
% end
%
% writetable(P,'word_syllable_parses.csv');

%%
%save([h.data_dir 'metarate_segmentdata.mat'],'TR');
%end

function [locs] = findpeaks_son(x)
if numel(x)==1
    locs = 1;
else
    [~,locs] = findpeaks([0 x 0]);
    locs = locs-1;
end
end

%%
function [] = disp_parse(T)

f = fieldnames(T);
for i=1:length(f)
    T.(f{i}) = T.(f{i})';
end
T= struct2table(T);
disp(T);

end

% [~,locs] = findpeaks(-son); %sonority valleys
%
% for k=1:length(locs)
%
%     loci = locs(k);
%
%     %true valley
%     if son(loci)<son(loci-1) && son(loci)>son(loci+1)
%         T.new_sylb(ixs(1)+loci-1-1) = true;
%         continue;
%     end
%
%     %plateau
%     while son(loci)==son(loci+1)
%         phone_seq = strjoin(T.phone(ixs(1)+loci-1-[1 0]));
%         disp(phone_seq);
%         switch(imember(phone_seq,disallowed_onsets))
%             case 1
%                 loci = loci+1;
%             case 0
%                 break;
%         end
%     end
%     T.new_sylb(ixs(1)+loci-1-1) = true;
% end