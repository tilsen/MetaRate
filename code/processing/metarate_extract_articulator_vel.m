function [] = metarate_extract_articulator_vel()

dbstop if error;
[h,PH] = metarate_helpers();

files = rdir([h.corpus_dir '**' filesep 'data' filesep '*.mat']);

DD = load([h.data_dir 'metarate_segmentdata.mat']);

%chans = {'TR' 'TB' 'TT' 'UL' 'LL' 'ML' 'JAW' 'JAWL'};
chans = {'TR' 'TB' 'TT' 'UL' 'LL' 'ML' 'JAW'};

%{
EMA trajectory format [nSamps x 6 dimensions]:
	posX (mm)
	posY
	posZ
	rotation around X (degrees)
	         around Y
	         around Z 
%}

Fs = h.frame_rate; %resample to this

chan_dims = [1 2 3];

TR = [];
for i=1:length(files)

    status_str = status(sprintf('processing %i/%i',i,length(files))); %#ok<NASGU>

    X = load(files(i).name);
    ff = fieldnames(X);

    if contains(ff,'palate'), continue; end

    strs = strsplit(ff{1},'_');
    X = X.(ff{1});

    audio_ix = ismember({X.NAME},'AUDIO');
    A = X(audio_ix);

    artic_ix = ismember({X.NAME},chans);
    X = X(artic_ix);

    %check for uniform sampling rate
    sr = [X.SRATE];
    if numel(unique(sr))>1
        fprintf('error: %s more than one sample rate\n',files(i).name); return;
    end
    Fs_orig = sr(1);

    %check for uniform length
    len = arrayfun(@(c)size(c.SIGNAL,1),X);
    if numel(unique(len))>1
        fprintf('error: %s mismatching signal lengths\n',files(i).name); return;
    end

    %collect signals
    Y = arrayfun(@(c){c.SIGNAL(:,chan_dims)'},X');
    Y = double(vertcat(Y{:}));

    dY = cell2mat(arrayfun(@(c){gradient(Y(c,:))},(1:size(Y,1))'));
    sysvel = sqrt(nansum(dY.^2)); %#ok<NANSUM> 

    dYc = reshape(dY,3,[],size(dY,2));
    sumvel = sum(squeeze(sqrt(dYc.^2)));    

    %resample velocity
    if Fs~=Fs_orig
        t_orig = (0:len-1)/Fs_orig;
        t_interp = (0:(Fs_orig/Fs):len-1)/Fs_orig;
        ixnotnan = ~isnan(sysvel);
        sysveli = interp1(t_orig(ixnotnan),sysvel(ixnotnan),t_interp,'makima');
        sumveli = interp1(t_orig(ixnotnan),sumvel(ixnotnan),t_interp,'makima');
    end

    t=t_interp;

    TR(i).subj = strs{1};
    TR(i).block = str2double(strs{2}(2:end));
    TR(i).sent = str2double(strs{3}(2:end));
    TR(i).rep = str2double(strs{4}(2:end));
    TR(i).rate = strs{end};
    TR(i).t = t;
    TR(i).sysvel = sysveli;
    TR(i).sumvel = sumveli;

    word_labs = {A.WORDS.LABEL}';
    word_t = vertcat(A.WORDS.OFFS);

    phone_labs = {A.PHONES.LABEL}';
    phone_t = vertcat(A.PHONES.OFFS);  

    TR(i).utt_t0 = word_t(find(~ismember(word_labs,'sp'),1,'first'),1);
    TR(i).utt_t1 = word_t(find(~ismember(word_labs,'sp'),1,'last'),2);

    TR(i).N_words = sum(~ismember(word_labs,'sp'));
    TR(i).N_phones = sum(~ismember(phone_labs,'sp'));
    
end
status('reset');

TR = TR(~cellfun(@(c)isempty(c),{TR.subj}));
TR = struct2table(TR);
TR.trcode = arrayfun(@(c,d,e,f)sprintf('%s_%02i_%02i_%i_%s',TR.subj{c},d,e,f,TR.rate{c}),(1:height(TR))',TR.block,TR.sent,TR.rep,'un',0);
TR.fname = arrayfun(@(c,d,e,f)sprintf('%s_B%02i_S%02i_R%02i_%s',TR.subj{c},d,e,f,TR.rate{c}),(1:height(TR))',TR.block,TR.sent,TR.rep,'un',0);

% for i=1:height(TR)
%     ix_TR = ismember(DD.TR.fname,TR.fname{i});
%     TR.N_sylbs(i) = sum(~ismember(DD.TR.sylbs{ix_TR},'sp'));
% end

%%
save([h.data_dir 'metarate_artic_vel.mat'],'TR');


end
