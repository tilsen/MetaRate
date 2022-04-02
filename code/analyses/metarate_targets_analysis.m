function [] = metarate_targets_analysis()

dbstop if error;
h = metarate_helpers;

files = rdir([h.datasets_dir 'data*.mat']);
C = metarate_targets;

for i=1:height(C)
    status_str = status(sprintf('%i/%i',i,height(C))); %#ok<NASGU> 
    fname = [h.datasets_dir 'data_' C.target{i} '.mat'];
    load(fname);
    C.N(i) = height(D);
end

C.cons = contains(C.target,'consonants');
C.stop = contains(C.target,'stops');
C.vow = contains(C.target,'vowels');
C = sortrows(C,{'cons' 'stop' 'vow' 'N'},{'a' 'a' 'a' 'd'});

%{
fprintf('\n');
cellfun(@(c,d,e)fprintf('%s\t%s\t%i\n',c,d,e),C.symb,C.description,num2cell(C.N));
%}

disp(C);

%% syllable shapes
X = load('M:\Data\metarate_opendata\metarate_durdata_syllables.mat');
S = tabulate(X.D.sylb_form);

S = array2table(S,'VariableNames',{'form' 'count' 'proportion'});
S.count = cell2mat(S.count);
S.proportion = cell2mat(S.proportion)/100;
S = sortrows(S,'count','descend');

%remove sp
S = S(~ismember(S.form,'sp'),:);
S.proportion = S.count/sum(S.count);

S.onset = regexp(S.form,'(\w.*)V','tokens','once');
S.vowel = regexp(S.form,'V\d{1}','match','once');
S.coda = regexp(S.form,'V\d{1} (\w.*)','tokens','once');

S.onset(cellfun(@(c)isempty(c),S.onset)) = {{' '}};
S.coda(cellfun(@(c)isempty(c),S.coda)) = {{' '}};

S.onset = cellfun(@(c){strtrim(c{:})},S.onset);
S.coda = cellfun(@(c){strtrim(c{:})},S.coda);

%{
fprintf('\n');
cellfun(@(c,d,e,f,g,h)fprintf('%s\t%s\t%s\t%s\t%i\t%1.2f\n',c,d,e,f,g,h),...
    S.form,S.onset,S.vowel,S.coda,num2cell(S.count),num2cell(S.proportion));
%}

S.cum_prop = cumsum(S.proportion);

disp(S);

end
