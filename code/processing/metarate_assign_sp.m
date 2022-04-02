function [] = metarate_assign_sp()

%assigns sp below tol to preceding or following stop (splits the difference if both
%are stops)

tol = 0.1;

dbstop if error;
[h,PH] = metarate_helpers();
load([h.data_dir 'metarate_segmentdata_raw.mat'],'TR');

TR.phones_dur = cellfun(@(c,d){d-c},TR.phones_t0,TR.phones_t1);
TR.words_phone_ix = cellfun(@(c)arrayfun(@(d){find(ismember(c,d))},unique(c)),TR.phones_word_ix,'un',0);

%count non-initial/final sp's before
count_sp_before = sum(cellfun(@(c)sum(ismember(c,'sp')),TR.phones)) - 2*height(TR);

%%
for i=1:height(TR)
    
    status_str = status(sprintf('processing %03i/%03i',i,height(TR))); %#ok<NASGU> 

    exc_ix_sp = [];
    while 1
        IX_sp = find(ismember(TR.phones{i},'sp') & TR.phones_dur{i}<tol);
        IX_sp = setdiff(IX_sp,[1 length(TR.phones{i}) exc_ix_sp]);
        
        if ~any(IX_sp), break; end
        P = extract_phones_table(TR(i,:));
        W = extract_words_table(TR(i,:));
        ix_sp = IX_sp(1);
        ix_sp_word = find(cellfun(@(c)any(ismember(c,ix_sp)),W.words_phone_ix));
        
        next_son = TR.phones_son{i}(ix_sp+1);
        prev_son = TR.phones_son{i}(ix_sp-1);
        
        %followed by stop, preceded by non-stop
        if next_son==1 && prev_son>1
            
            P.phones_t0(ix_sp+1) = P.phones_t0(ix_sp);
            P = P(setdiff(1:height(P),ix_sp),:);
            
            %remove sp word   
            W.words_t0(ix_sp_word+1) = W.words_t0(ix_sp_word);
            W = W(setdiff(1:height(W),ix_sp_word),:);
            
        %preceded by stop, followed by non-stop
        elseif prev_son==1 && next_son>1

            P.phones_t1(ix_sp-1) = P.phones_t1(ix_sp);
            P = P(setdiff(1:height(P),ix_sp),:);  
            
            %remove sp word 
            W.words_t1(ix_sp_word-1) = W.words_t1(ix_sp_word);
            W = W(setdiff(1:height(W),ix_sp_word),:);   
            
        %preceded by stop, followed by stop
        elseif next_son==1 && prev_son==1
           
            dur_sp = P.phones_dur(ix_sp);
            P.phones_t1(ix_sp-1) = P.phones_t1(ix_sp-1)+dur_sp/2;
            P.phones_t0(ix_sp+1) = P.phones_t0(ix_sp+1)-dur_sp/2;
            P = P(setdiff(1:height(P),ix_sp),:);  
            
            %remove sp word 
            W.words_t1(ix_sp_word-1) = W.words_t1(ix_sp_word-1)+dur_sp/2;
            W.words_t0(ix_sp_word+1) = W.words_t0(ix_sp_word+1)-dur_sp/2;
            
            W = W(setdiff(1:height(W),ix_sp_word),:);                 
            
        else 
            %metarate_view_trial(TR(i,:),h);
            exc_ix_sp = [exc_ix_sp ix_sp];
        end
        
        TR = update_trial(TR,i,P,W);
    end
end

%count non-initial/final sp's after
count_sp_after = sum(cellfun(@(c)sum(ismember(c,'sp')),TR.phones)) - 2*height(TR);

fprintf('\nreassigned %i/%i sp (%1.3f%%)\n',count_sp_before-count_sp_after,count_sp_before,100*(count_sp_before-count_sp_after)/count_sp_before);

%check consistency of word and phone times
phone_time_consistency_bytrial = cellfun(@(c,d)all(c(1:end-1)==d(2:end)),TR.phones_t1,TR.phones_t0);
word_time_consistency_bytrial = cellfun(@(c,d)all(c(1:end-1)==d(2:end)),TR.words_t1,TR.words_t0);

phone_time_consistency = all(phone_time_consistency_bytrial);
word_time_consistency = all(word_time_consistency_bytrial);

if ~phone_time_consistency
    fprintf('warning: phone times are inconsistent\n');
elseif ~word_time_consistency
    fprintf('warning: phone times are inconsistent\n');
else
    fprintf('phone and word times are consistent\n');
end

%check consistency of word and phone maps

%%
save([h.data_dir 'metarate_segmentdata.mat'],'TR');

end

%%
function [P] = extract_phones_table(TR)
ff = setdiff(TR.Properties.VariableNames(contains(TR.Properties.VariableNames,'phone')),{'words_phone_ix'});
for i=1:length(ff), P.(ff{i}) = [TR.(ff{i}){:}]'; end
P = struct2table(P);
end

%%
function [W] = extract_words_table(TR)
ff = setdiff(TR.Properties.VariableNames(contains(TR.Properties.VariableNames,'word')),{'phones_word_ix'});
for i=1:length(ff), W.(ff{i}) = [TR.(ff{i}){:}]'; end
W = struct2table(W);
end

%%
function [TR] = update_trial(TR,i,P,W)

%remap 
W.words_phone_ix = arrayfun(@(c,d){find(P.phones_t0>=c & P.phones_t1<=d)'},W.words_t0,W.words_t1);
P.phones_word_ix = arrayfun(@(c,d)find(W.words_t0<=c & W.words_t1>=d),P.phones_t0,P.phones_t1);

ff = setdiff(TR.Properties.VariableNames(contains(TR.Properties.VariableNames,'phone')),{'words_phone_ix'});
for j=1:length(ff), TR.(ff{j}){i} = [P.(ff{j})]'; end

ff = setdiff(TR.Properties.VariableNames(contains(TR.Properties.VariableNames,'word')),{'phones_word_ix'});
for j=1:length(ff), TR.(ff{j}){i} = [W.(ff{j})]'; end

end


