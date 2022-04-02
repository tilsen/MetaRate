function [] = metarate_moratize_segmentdata()

%parses syllables into moras (treats sp as one mora)

dbstop if error;
[h,PH] = metarate_helpers();

load([h.data_dir 'metarate_segmentdata.mat'],'TR');

%%

%algorithm:
% 1. find vowel of syllable
% 2. if vowel is bimoraic, split syllable at vowel midpoint
% 3. if vowel is monomoraic:
% 4.    if any post-vocalic consonants, split syllable at vowel endpoint
% 5.    else treat syllable as monomoraic

for i=1:height(TR)

    status_str = status(sprintf('moratizing trial %i/%i',i,height(TR))); %#ok<NASGU>

    [M,phones2moras] = moratize(TR(i,:),PH);

    TR.moras{i} = M.moras';
    TR.moras_t0{i} = M.moras_t0';
    TR.moras_t1{i} = M.moras_t1';
    TR.moras_sylb_ix{i} = M.moras_sylb_ix';
    TR.phones_mora_ix{i} = phones2moras;        % n.5 indicates phone is assigned to two moras

end
status('reset');


%%
save([h.data_dir 'metarate_segmentdata.mat'],'TR');

end

%%
function [M,phones_mora_ix] = moratize(tr,PH)

bimoraic_vows = PH.label(PH.moras==2);
all_vows = PH.label(PH.son==5);

p2s = tr.phones_sylb_ix{1};
phones = tr.phones{1};
phones_t0 = tr.phones_t0{1};
phones_t1 = tr.phones_t1{1};
sons = tr.phones_son{1};
sylb_ixs = unique(p2s);

c=1;
moras = {};
moras_t0 = [];
moras_t1 = [];
phones_mora_ix = [];
moras_sylb_ix = [];

for j=sylb_ixs

    %phones in this syllable
    phixs = find(p2s==j);
    ph = phones(phixs);
    son = sons(phixs);

    % nan
    if numel(ph)==1 && isnan(son)
        phones_mora_ix = [phones_mora_ix repmat(c,1,numel(phixs))];
        moras_sylb_ix = [moras_sylb_ix j];
        moras{c} = ph{:};             %#ok<*AGROW>
        moras_t0(c) = phones_t0(phixs(1));
        moras_t1(c) = phones_t1(phixs(end));
        c=c+1;
        continue;
    end

    % check for bimoraic vowel
    ix_bim = find(ismember(ph,bimoraic_vows));
    vowel_is_last = ismember(ph(end),all_vows);

    if numel(ix_bim)==1 %bimoraic vowel

        % split syllable:
        t_split = mean([phones_t0(phixs(ix_bim)) phones_t1(phixs(ix_bim))]);
        phixs_1 = phixs(1:ix_bim);
        phixs_2 = phixs(ix_bim:end);

        phones_mora_ix = [phones_mora_ix repmat(c,1,numel(phixs_1))];
        moras_sylb_ix = [moras_sylb_ix j];
        moras{c} = strjoin(phones(phixs_1),' ');
        moras_t0(c) = phones_t0(phixs_1(1));
        moras_t1(c) = t_split;
        c=c+1;

        %indicates that this phone is split:
        phones_mora_ix(end) = phones_mora_ix(end) + 0.5;

        phones_mora_ix = [phones_mora_ix repmat(c,1,numel(phixs_2)-1)];
        moras_sylb_ix = [moras_sylb_ix j];
        moras{c} = strjoin(phones(phixs_2),' ');
        moras_t0(c) = t_split;
        moras_t1(c) = phones_t1(phixs_2(end));
        c=c+1;
        continue;

    elseif numel(ix_bim)==0 && ~vowel_is_last %monomoraic vowel with coda

        vix = find(ismember(ph,all_vows));
        phixs_1 = phixs(1:vix);
        phixs_2 = phixs((vix+1):end);

        phones_mora_ix  = [phones_mora_ix repmat(c,1,numel(phixs_1))];
        moras_sylb_ix   = [moras_sylb_ix j];
        moras{c}        = strjoin(phones(phixs_1),' ');
        moras_t0(c)     = phones_t0(phixs_1(1));
        moras_t1(c)     = phones_t1(phixs_1(end));
        c=c+1;

        phones_mora_ix  = [phones_mora_ix repmat(c,1,numel(phixs_2))];
        moras_sylb_ix   = [moras_sylb_ix j];
        moras{c}        = strjoin(phones(phixs_2),' ');
        moras_t0(c)     = phones_t0(phixs_2(1));
        moras_t1(c)     = phones_t1(phixs_2(end));
        c=c+1;
        continue;

    elseif numel(ix_bim)==0 && vowel_is_last %monomoraic vowel without coda
        phones_mora_ix = [phones_mora_ix repmat(c,1,numel(phixs))];
        moras_sylb_ix = [moras_sylb_ix j];
        moras{c} = strjoin(ph,' ');
        moras_t0(c) = phones_t0(phixs(1));
        moras_t1(c) = phones_t1(phixs(end));
        c=c+1;
        continue;

    else
        status('reset');
        fprintf('unexpected parse: %s\n',tr.fname{1}); %shou
    end

end

M.moras = moras';
M.moras_t0 = moras_t0';
M.moras_t1 = moras_t1';
M.moras_sylb_ix = moras_sylb_ix';

M = struct2table(M);

%% validate parse:

%all times match
t0t1_match = all(M.moras_t0(2:end)==M.moras_t1(1:end-1));

%all syllables are parsed:
allsylb = all(ismember(sylb_ixs,M.moras_sylb_ix));

%all phones assigned to mora:
allphones = numel(phones)==length(phones_mora_ix);

valid = [t0t1_match allsylb allphones];

if any(~valid)
    status('reset');
    fprintf('invalid parse: %s\n',tr.fname{1});
end

end
