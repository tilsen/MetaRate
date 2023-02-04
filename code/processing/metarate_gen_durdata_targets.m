function [] = metarate_gen_durdata_targets()

h = metarate_helpers;

if ~exist(h.datasets_dir,'dir'), mkdir(h.datasets_dir); end

%target datasets:
targets = {
    'vowels'                    %all vowels
    'consonants'                %all consonants
    'vowels_stress0'            %unstressed vowels
    'vowels_stress1'            %primary stressed vowels
    'consonants_onsets'         %consonants in onsets
    'consonants_codas'          %consonants in codas
    'consonants_simplexonsets'  %consonants in simplex onsets
    'consonants_simplexcodas'   %consonants in simplex codas    
    'consonants_stops'          %stop consonants
    'consonants_nonstops'};       %non-stop consonants

for i=1:length(targets)
    status_str = status(sprintf('generating dataset: %s',targets{i})); %#ok<NASGU>
    gen_durdata(h,targets{i});
end

status('reset');

end

%%
function [D,targetf] = gen_durdata(h,target)

if contains(target,'vowel')
    load([h.data_dir 'metarate_durdata_vowels.mat'],'D');
    targetf = 'phones';
    
elseif contains(target,'consonant')
    load([h.data_dir 'metarate_durdata_consonants.mat'],'D');
    targetf = 'phones';
    
elseif contains(target,'syllable')
    load([h.data_dir 'metarate_durdata_syllables.mat'],'D');
    targetf = 'sylbs_form'; %use forms not segment sequences
    D = D(~ismember(D.sylbs,'sp'),:);
    
else
    fprintf('target %s not identified\n',target); return;
end


switch(target)
    case {'vowels_stress0','syllables_stress0'}
        D = D(D.stress==0,:);
        
    case {'vowels_stress1','syllables_stress1'}
        D = D(D.stress==1,:);
        
    case {'vowels_stress2','syllables_stress2'}
        D = D(D.stress==2,:);
        
    case 'consonants_onsets'
        D = D(D.onset,:);
        
    case 'consonants_codas'
        D = D(D.coda,:);
        
    case 'consonants_simplexonsets'
        D = D(D.onset & D.nclust==1,:);
        
    case 'consonants_simplexcodas'
        D = D(D.coda & D.nclust==1,:);
        
    case 'consonants_complexonsets'
        D = D(D.onset & D.nclust>1,:);
        
    case 'consonants_complexcodas'
        D = D(D.coda & D.nclust>1,:);
        
    case 'consonants_stops'
        D = D(D.stop,:);
        
    case 'consonants_nonstops'
        D = D(~D.stop,:);
        
end

%unit midpoints:
D.tmid = (D.t0+D.t1)/2;

save([h.datasets_dir 'data_' target '.mat'],'D');

end

