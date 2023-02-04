function [] = metarate_prep_durdata_segments()

%makes data tables of vowels and consonant durations for regressions

dbstop if error;
[h,PH] = metarate_helpers();

load([h.data_dir 'metarate_segmentdata.mat'],'TR');
X = load([h.data_dir 'metarate_propdurs.mat'],'TR');

%add duration fields
TR.phones_dur = cellfun(@(c,d){d-c},TR.phones_t0,TR.phones_t1);
TR.sylbs_dur = cellfun(@(c,d){d-c},TR.sylbs_t0,TR.sylbs_t1);
TR.words_dur = cellfun(@(c,d){d-c},TR.words_t0,TR.words_t1);

%copy these fields from TR
copyf = {'subj' 'block' 'sent' 'rep' 'rate' 'text'};
units = h.units;

D=[];
c=0;
for i=1:height(TR)
    
    status_str = status(sprintf('processing trial %i/%i',i,height(TR))); %#ok<NASGU>
    
    phones = TR.phones{i};
    for j=1:length(phones)
        
        if ismember(phones{j},'sp'), continue; end
        
        c=c+1;

        %phones only
        D(c).phones = phones{j};
        D(c).dur = TR.phones_dur{i}(j);
        D(c).t0 = single(TR.phones_t0{i}(j));
        D(c).t1 = single(TR.phones_t1{i}(j));
        D(c).tmid = (D(c).t0+D(c).t1)/2;
        D(c).ix = uint8(j);     
        D(c).utt_t0 = single(TR.utt_t0(i));
        D(c).utt_t1 = single(TR.utt_t1(i));           
        D(c).phones_t0 = D(c).t0;
        D(c).phones_t1 = D(c).t1;
        D(c).phones_ix = uint8(j);

        %loop over rate units
        for k=2:length(units)
            ustr = units{k}; 
            unit_labs = TR.([units{k}]){i};
            units_t0 = single(TR.([units{k} '_t0']){i});
            units_t1 = single(TR.([units{k} '_t1']){i});

            cond1 = units_t0<=D(c).t0 & units_t1>=D(c).t1; %fully contained
            cond2 = units_t0<=D(c).t0 & units_t1>D(c).t0; %partly contained
            cond3 = units_t0<D(c).t1 & units_t1>=D(c).t1; %partly contained
            uix = uint8(find(cond1 | cond2 | cond3));

            D(c).(ustr) = unit_labs(uix);
            D(c).([ustr '_t0']) = min(units_t0(uix));
            D(c).([ustr '_t1']) = max(units_t1(uix));
            D(c).([ustr '_ix']) = uix;
         
        end
       
        %indices of phones relative to syllable:
        ix_phones_sylbs = find(TR.phones_sylbs_ix{i}==D(c).sylbs_ix);
        D(c).sylbs_phones_ix = uint8(find(j==ix_phones_sylbs));  

        for k=1:length(copyf), D(c).(copyf{k}) = TR.(copyf{k})(i); end  
        
        D(c).fname = sprintf('%s_B%02i_S%02i_R%02i_%s',D(c).subj{:},D(c).block,D(c).sent,D(c).rep,D(c).rate{:});
        D(c).trcode = sprintf('%s_%02i_%02i_%i_%s',D(c).subj{:},D(c).block,D(c).sent,D(c).rep,D(c).rate{:});
    end
end
fprintf('\n');

D = struct2table(D);

%
write_vowels(D(ismember(D.phones,PH.label(PH.vow)),:),h,PH);
write_consonants(D(ismember(D.phones,PH.label(PH.cons)),:),h,PH);

end

%% vowels table
function [] = write_vowels(D,h,PH)
D.sylbs_form = D.sylbs;

%sorting phones by label length (descending) prevents accidental partial
%matches in replacement
PH.len_label = cellfun(@(c)numel(c),PH.label);
PH = sortrows(PH,'len_label','descend');
for i=1:height(PH)
    D.sylbs_form = regexprep(D.sylbs_form,['(?<=^|\s)' PH.label{i} '(?=$|\s)'],PH.form{i});
end

D.stress = cellfun(@(c)str2double(c),regexp(D.phones,'\d{1}','match','once'));

save([h.data_dir 'metarate_durdata_vowels.mat'],'D');
end

%% consonants table
function [] = write_consonants(D,h,PH)
D.sylbs_form = D.sylbs;

%sorting phones by label length (descending) prevents accidental partial
%matches in replacement
PH.len_label = cellfun(@(c)numel(c),PH.label);
PH = sortrows(PH,'len_label','descend');
for i=1:height(PH)
    D.sylbs_form = regexprep(D.sylbs_form,['(?<=^|\s)' PH.label{i} '(?=$|\s)'],PH.form{i});
end

D.onset = false(height(D),1);
D.coda = false(height(D),1);
D.nclust = zeros(height(D),1);

D.sylbs_forms = regexp(D.sylbs_form,' ', 'split');
D.sylbs_num_phones = cellfun(@(c)numel(c),D.sylbs_forms);
D.sylbs_vowel_ix = cellfun(@(c)find(ismember(c,{'V0' 'V1' 'V2'})),D.sylbs_forms);

D.stress = cellfun(@(c)find(ismember({'V0' 'V1' 'V2'},c))-1,D.sylbs_forms);

ix_ons = D.sylbs_phones_ix<D.sylbs_vowel_ix;
D.onset(ix_ons) = true;
D.nclust(ix_ons) = D.sylbs_vowel_ix(ix_ons)-1;

ix_cod = D.sylbs_phones_ix>D.sylbs_vowel_ix;
D.coda(ix_cod) = true;
D.nclust(ix_cod) = D.sylbs_num_phones(ix_cod)-D.sylbs_vowel_ix(ix_cod);

D.manner = cellfun(@(c)PH.manner(ismember(PH.label,c)),D.phones);
D.voice = cellfun(@(c)PH.voice(ismember(PH.label,c)),D.phones);
D.stop = cellfun(@(c)PH.stop(ismember(PH.label,c)),D.phones);
D.obstruent = cellfun(@(c)PH.obstruent(ismember(PH.label,c)),D.phones);

save([h.data_dir 'metarate_durdata_consonants.mat'],'D');
end


% %%
% function [D] = add_context_info(D,tt,unit,TR)
% 
% pre_ix = TR.([unit '_t0']){1}<tt(1);
% post_ix = TR.([unit '_t1']){1}>tt(2);
% 
% pre_str = ['pre_' unit];
% post_str = ['post_' unit];
% D.([pre_str]) = TR.([unit]){1}(pre_ix);
% D.([pre_str '_t0']) = single(TR.([unit '_t0']){1}(pre_ix));
% D.([pre_str '_t1']) = single(TR.([unit '_t1']){1}(pre_ix));
% D.([post_str]) = TR.([unit]){1}(post_ix);
% D.([post_str '_t0']) = single(TR.([unit '_t0']){1}(post_ix));
% D.([post_str '_t1']) = single(TR.([unit '_t1']){1}(post_ix));
% end


%         if i==1 && j==2
%             for k3=units
%                 for k1={'pre_' 'post_'}
%                     for k2 = {'' '_t0' '_t1'}
%                         D(end).([k1{1} k3{1} k2{1}]) = [];
%                     end
%                 end
%             end
%         end
%         for k=1:length(units)
%             D(end) = add_context_info(D(end),[TR.phones_t0{i}(j) TR.phones_t1{i}(j)],units{k},TR(i,:));
%         end
%         D(end+1).phone = phones{j};
%         D(end).dur = TR.phones_dur{i}(j);
%         D(end).t0 = TR.phones_t0{i}(j);
%         D(end).t1 = TR.phones_t1{i}(j);
%         D(end).ix = j;
%         D(end).phone_ix = j;
%         
%         wix = find(TR.words_t0{i}<=D(end).t0 & TR.words_t1{i}>=D(end).t1);
%         D(end).word = TR.words{i}(wix);
%         D(end).word_t0 = TR.words_t0{i}(wix);
%         D(end).word_t1 = TR.words_t1{i}(wix);
%         D(end).word_ix = wix;
%                 
%         six = find(TR.sylbs_t0{i}<=D(end).t0 & TR.sylbs_t1{i}>=D(end).t1);
%         D(end).sylb = TR.sylbs{i}(six);
%         D(end).sylb_t0 = TR.sylbs_t0{i}(six);
%         D(end).sylb_t1 = TR.sylbs_t1{i}(six); 
%         D(end).sylb_ix = six;
  %D.fname = arrayfun(@(c)sprintf('%s_B%02i_S%02i_R%02i_%s',D.subj{c},D.block(c),D.sent(c),D.rep(c),D.rate{c}),(1:height(D))','un',0);
%D.trcode = arrayfun(@(c,d,e,f)sprintf('%s_%02i_%02i_%i_%s',D.subj{c},d,e,f,D.rate{c}),(1:height(D))',D.block,D.sent,D.rep,'un',0);
      
 