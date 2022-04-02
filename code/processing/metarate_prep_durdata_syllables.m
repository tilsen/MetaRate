function [] = metarate_prep_durdata_syllables()

%makes table of syllable durations and segmental context for regression:

dbstop if error;
h = metarate_helpers();
load([h.data_dir 'metarate_segmentdata.mat'],'TR');

%add duration fields
TR.phones_dur = cellfun(@(c,d){d-c},TR.phones_t0,TR.phones_t1);
TR.sylbs_dur = cellfun(@(c,d){d-c},TR.sylbs_t0,TR.sylbs_t1);
TR.words_dur = cellfun(@(c,d){d-c},TR.words_t0,TR.words_t1);

%copy these fields from TR
copyf = {'subj' 'block' 'sent' 'rep' 'rate' 'text'};

D=[];
for i=1:height(TR)
    
    status_str = status(sprintf('processing trial %i/%i',i,height(TR))); %#ok<NASGU>
    
    sylbs = TR.sylbs{i};
    for j=1:length(sylbs)

        D(end+1).sylb = sylbs{j};
        D(end).dur = TR.sylbs_dur{i}(j);
        D(end).t0 = TR.sylbs_t0{i}(j);
        D(end).t1 = TR.sylbs_t1{i}(j);
        D(end).ix = j;
        
        wix = find(TR.words_t0{i}<=D(end).t0 & TR.words_t1{i}>=D(end).t1);
        D(end).word = TR.words{i}(wix);
        D(end).word_t0 = TR.words_t0{i}(wix);
        D(end).word_t1 = TR.words_t1{i}(wix);
        D(end).word_ix = wix;
        
        pix = find(TR.phones_t0{i}>=D(end).t0 & TR.phones_t1{i}<=D(end).t1); %note reversal of inequalities
        D(end).phones = TR.phones{i}(pix);
        D(end).phones_t0 = TR.phones_t0{i}(pix);
        D(end).phones_t1 = TR.phones_t1{i}(pix);
        D(end).phones_ix = pix;        
        
        for k=1:length(copyf), D(end).(copyf{k}) = TR.(copyf{k})(i); end  
        
        if i==1 && j==1
            for k3={'phones' 'sylbs' 'words'}
                for k1={'pre_' 'post_'}
                    for k2 = {'' '_t0' '_t1'}
                        D(end).([k1{1} k3{1} k2{1}]) = [];
                    end
                end
            end
        end
        
        phone_sylb_ix = TR.phones_sylb_ix{i};
        p0 = find(phone_sylb_ix==j,1,'first');
        p1 = find(phone_sylb_ix==j,1,'last');
        
        D(end) = add_context_info(D(end),[TR.phones_t0{i}(p0) TR.phones_t1{i}(p1)],'phones',TR(i,:));
        D(end) = add_context_info(D(end),[TR.phones_t0{i}(p0) TR.phones_t1{i}(p1)],'sylbs',TR(i,:));
        D(end) = add_context_info(D(end),[TR.phones_t0{i}(p0) TR.phones_t1{i}(p1)],'words',TR(i,:));
         
        D(end).utt_t0 = TR.words_t0{i}(2);
        D(end).utt_t1 = TR.words_t1{i}(end-1);        
    end
    
end

D = struct2table(D);

%%
PH = metarate_phones();

D.sylb_form = D.sylb;
D = movevars(D,'sylb_form','after',1);

cons = strjoin(PH.label(PH.cons),'|');
cons_regexp_init = ['^(' cons ')\s{1}'];
cons_regexp_final = ['\s{1}(' cons ')$'];
cons_regexp_medial = ['\s{1}(' cons ')\s{1}'];
D.sylb_form = cellfun(@(c)regexprep(c,cons_regexp_init,'C '),D.sylb_form,'un',0);
D.sylb_form = cellfun(@(c)regexprep(c,cons_regexp_final,' C'),D.sylb_form,'un',0);
D.sylb_form = cellfun(@(c)regexprep(c,cons_regexp_medial,' C '),D.sylb_form,'un',0);
D.sylb_form = cellfun(@(c)regexprep(c,cons_regexp_medial,' C '),D.sylb_form,'un',0);

for i=0:2
    vows = strjoin(PH.label(PH.stress==i),'|');
    vow_regexp_init{i+1} = ['^(' vows ')']; %#ok<*AGROW>
    vow_regexp_final{i+1} = ['(' vows ')$'];
    vow_regexp_medial{i+1} = ['\s{1}(' vows ')\s{1}'];
end

for i=0:2
    D.sylb_form = cellfun(@(c)regexprep(c,vow_regexp_init{i+1},['V' num2str(i)]),D.sylb_form ,'un',0);
    D.sylb_form = cellfun(@(c)regexprep(c,vow_regexp_final{i+1},['V' num2str(i)]),D.sylb_form ,'un',0);
    D.sylb_form = cellfun(@(c)regexprep(c,vow_regexp_medial{i+1},[' V' num2str(i) ' ']),D.sylb_form ,'un',0);
end

notsp = ~ismember(D.sylb_form,'sp');
D.stress(notsp) = cellfun(@(c)str2double(c{:}),regexp(D.sylb_form(notsp),'V(\d{1})','tokens','once'));

%%
D.trcode = arrayfun(@(c,d,e,f)sprintf('%s_%02i_%02i_%i_%s',D.subj{c},d,e,f,D.rate{c}),(1:height(D))',D.block,D.sent,D.rep,'un',0);
D.fname = arrayfun(@(c)sprintf('%s_B%02i_S%02i_R%02i_%s',D.subj{c},D.block(c),D.sent(c),D.rep(c),D.rate{c}),(1:height(D))','un',0);

save([h.data_dir 'metarate_durdata_syllables.mat'],'D');

end

%%
function [D] = add_context_info(D,tt,unit,TR)

pre_ix = TR.([unit '_t0']){1}<tt(1);
post_ix = TR.([unit '_t1']){1}>tt(2);

pre_str = ['pre_' unit];
post_str = ['post_' unit];
D.([pre_str]) = TR.([unit]){1}(pre_ix);
D.([pre_str '_t0']) = TR.([unit '_t0']){1}(pre_ix);
D.([pre_str '_t1']) = TR.([unit '_t1']){1}(pre_ix);
D.([post_str]) = TR.([unit]){1}(post_ix);
D.([post_str '_t0']) = TR.([unit '_t0']){1}(post_ix);
D.([post_str '_t1']) = TR.([unit '_t1']){1}(post_ix);
end


