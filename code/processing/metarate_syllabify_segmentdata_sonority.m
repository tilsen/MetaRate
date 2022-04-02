function [] = metarate_syllabify_segmentdata_sonority()

%parses words/segments into syllables (treats sp as syllables)

dbstop if error;
[h,PH] = metarate_helpers();

load([h.data_dir 'metarate_segmentdata.mat'],'TR');

disallowed_onsets = metarate_disallowed_onsets(PH);

%%

for i=1:height(TR)
    
    status_str = status(sprintf('syllabifying trial %i/%i',i,height(TR))); %#ok<NASGU>
    
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
            CANDS.npeaks = sum(CANDS.parse_npeaks,2);
            CANDS.max_ons = (1:height(CANDS))';
            CANDS.cost = 1000*(CANDS.npeaks~=2) + 100*CANDS.phonotactic_violations + CANDS.max_ons;
            
            [~,best_cand_ix] = min(CANDS.cost);
            T.new_sylb(ixs(1)+best_cand_ix) = true;
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
fprintf('\n');

%% make table of word-syllable-phone parses (for manual inspection):
N_words = arrayfun(@(c)length(TR.words{c}),(1:height(TR))');
words = [TR.words{:}];
tr_ixs = arrayfun(@(c)repmat(c,N_words(c),1),(1:height(TR))','un',0);
tr_ixs = vertcat(tr_ixs{:});

[uwords,ia,~] = unique(words);
P.word = uwords';
P.first_trial = tr_ixs(ia);
P = struct2table(P);
P.sylb_1 = repmat({''},height(P),1);
P.sylb_2 = repmat({''},height(P),1);
for i=1:height(P)
    tr = TR(tr_ixs(ia(i)),:);
    wix = find(strcmp(tr.words{:},P.word{i}),1,'first');
    phones_ix = ismember(tr.phones_word_ix{:},wix);
    sylb_ix = tr.phones_sylb_ix{:}(phones_ix);
    usylb_ix = unique(sylb_ix);
    if ~isnan(usylb_ix)
        for j=1:length(usylb_ix)
            P.(['sylb_' num2str(j)]){i} = tr.sylbs{1}{usylb_ix(j)};
        end
    end
end

writetable(P,[h.data_dir 'word_syllable_parses.csv']);

%%
save([h.data_dir 'metarate_segmentdata.mat'],'TR');

end

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