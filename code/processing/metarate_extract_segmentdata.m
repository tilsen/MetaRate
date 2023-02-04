function [] = metarate_extract_segmentdata()

dbstop if error;
[h,PH] = metarate_helpers();

files = rdir([h.corpus_dir '**' filesep 'data' filesep '*.mat']);

vows = PH.label(PH.vow);
cons = PH.label(PH.cons);

TR = [];
for i=1:length(files)
    
    status_str = status(sprintf('processing %i/%i',i,length(files))); %#ok<NASGU>
    
    X = load(files(i).name);
    ff = fieldnames(X);
    
    if contains(ff,'palate'), continue; end
    
    strs = strsplit(ff{1},'_');
    X = X.(ff{1});
    
    ac_ix = strcmp({X.NAME},'AUDIO');
    X = X(ac_ix);
    
    TR(i).subj = strs{1};
    TR(i).block = str2double(strs{2}(2:end));
    TR(i).sent = str2double(strs{3}(2:end));
    TR(i).rep = str2double(strs{4}(2:end));
    TR(i).rate = strs{end};
    TR(i).text = X.SENTENCE;
    %TR(i).source = X.SOURCE;
    
    TR(i).words = {X.WORDS.LABEL};
    
    offs = vertcat(X.WORDS.OFFS);
    TR(i).words_t0 = offs(:,1)';
    TR(i).words_t1 = offs(:,2)';
    
    TR(i).phones = {X.PHONES.LABEL};
    
    offs = vertcat(X.PHONES.OFFS);
    TR(i).phones_t0 = offs(:,1)';
    TR(i).phones_t1 = offs(:,2)';    
    


end

TR = TR(~cellfun(@(c)isempty(c),{TR.subj}));
TR = struct2table(TR);
TR.trcode = arrayfun(@(c,d,e,f)sprintf('%s_%02i_%02i_%i_%s',TR.subj{c},d,e,f,TR.rate{c}),(1:height(TR))',TR.block,TR.sent,TR.rep,'un',0);
TR.fname = arrayfun(@(c,d,e,f)sprintf('%s_B%02i_S%02i_R%02i_%s',TR.subj{c},d,e,f,TR.rate{c}),(1:height(TR))',TR.block,TR.sent,TR.rep,'un',0);

valid_phones = cellfun(@(c)all(ismember(c,PH.label)),TR.phones);
ix_invalid = find(~valid_phones);

%% corrections
if any(ix_invalid)
    
    TR.phones{ix_invalid(1)}{2} = 'AH0'; %"AH" -> "AH0" %{'F03_10_29_1_F'}
    TR.phones{ix_invalid(2)}{2} = 'HH'; %"SHH" -> "HH" %{'M04_03_12_1_F'}
    
end

%also correct for word-phone time mismatch:
ix = find(ismember(TR.trcode,'F03_10_29_1_F'));
TR.words_t0{ix}(3) = TR.phones_t0{ix}(3);
TR.words_t1{ix}(2) = TR.words_t0{ix}(3); 

%%

TR.phones_word_ix = arrayfun(@(c){arrayfun(@(d)find(TR.words_t0{c}<=d,1,'last'),TR.phones_t0{c})},(1:height(TR))');
TR.phones_son = arrayfun(@(c){arrayfun(@(d)PH.son(ismember(PH.label,d)),TR.phones{c})},(1:height(TR))');
TR.phones_son1 = arrayfun(@(c){arrayfun(@(d)PH.son1(ismember(PH.label,d)),TR.phones{c})},(1:height(TR))');
TR.phones_vow = arrayfun(@(c)arrayfun(@(d){ismember(d{1},vows)},c),TR.phones);
TR.phones_cons = arrayfun(@(c)arrayfun(@(d){ismember(d{1},cons)},c),TR.phones);
TR.phones_type = arrayfun(@(c,d){[c{1} + 2*d{1}]},TR.phones_vow,TR.phones_cons);

save([h.data_dir 'metarate_segmentdata_raw.mat'],'TR');

%this only needs to be run once:
%fix_segmentdata();

end

%%
function [] = fix_segmentdata()

[h,PH] = metarate_helpers();
vows = PH.label(PH.vow);
cons = PH.label(PH.cons);

load([h.data_dir 'metarate_segmentdata_raw.mat'],'TR');

%% find invalid phones
valid_phones = cellfun(@(c)all(ismember(c,PH.label)),TR.phones);

ix_invalid = find(~valid_phones);

for i=1:length(ix_invalid)
    TR.phones{ix_invalid(i)} %#ok<NOPRT>
end

% these are invalid labels in the original corpus:
%{'F03_10_29_1_F'}  "AH" -> "AH0"
%{'M04_03_12_1_F'}  "SHH" -> "HH"

reps = {'"AH"' '"AH0"'; '"SHH"' '"HH"'};

%fix them here:
for i=1:length(ix_invalid)
    ff(i) = rdir([h.corpus_dir '**' filesep TR.fname{ix_invalid(i)} '*.TextGrid']);
    
    fid = fopen(ff(i).name,'r');
    f=fread(fid,'*char')';
    fclose(fid);
    
    for j=1:size(reps,1)
        f = regexprep(f,reps(j,1),reps(j,2));
    end
    
    fid  = fopen(ff(i).name,'w');
    fprintf(fid,'%s',f);
    fclose(fid);
    
end
end
