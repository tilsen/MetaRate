function [PH] = metarate_phones()

%{ 
    sonority_levels
    5: vowel
    4: liquid, glide
    3: nasal
    2: fricative
    1: stop/affricate
%}

% vowel label, n moras

vows = [...
    {'AA0'}  1;
    {'AA1'}  2;
    {'AE0'}  1;
    {'AE1'}  2;
    {'AE2'}  2;
    {'AH0'}  1;
    {'AH1'}  1;
    {'AH2'}  1;
    {'AO1'}  2;
    {'AO2'}  2;
    {'AW1'}  2;
    {'AW2'}  2;
    {'AY0'}  1;
    {'AY1'}  2;
    {'AY2'}  2;
    {'EH0'}  1;
    {'EH1'}  1;
    {'EH2'}  1;
    {'ER0'}  1;
    {'ER1'}  2;
    {'EY1'}  2;
    {'EY2'}  2;
    {'IH0'}  1;
    {'IH1'}  1;
    {'IH2'}  1;
    {'IY0'}  1;
    {'IY1'}  2;
    {'IY2'}  2;
    {'OW0'}  1;
    {'OW1'}  2;
    {'OW2'}  2;
    {'OY1'}  2;
    {'UH1'}  1;
    {'UH2'}  1;
    {'UW0'}  1;
    {'UW1'}  2];

cons = [...
    {'B'  } 1   'STOP'      'VOICE'; ...
    {'CH' } 1   'AFFR'      'NOVOICE'; ...
    {'D'  } 1   'STOP'      'NOVOICE'; ...
    {'DH' } 2   'FRIC'      'VOICE'; ...
    {'F'  } 2   'FRIC'      'NOVOICE'; ...    
    {'G'  } 1   'STOP'      'VOICE'; ...
    {'HH' } 2   'FRIC'      'NOVOICE'; ...
    {'JH' } 1   'AFFR'      'VOICE'; ...
    {'K'  } 1   'STOP'      'NOVOICE'; ...
    {'L'  } 4   'LIQ'      'VOICE'; ...
    {'M'  } 3   'NAS'      'VOICE'; ...
    {'N'  } 3   'NAS'      'VOICE'; ...
    {'NG' } 3   'NAS'      'VOICE'; ...
    {'P'  } 1   'STOP'      'NOVOICE'; ...
    {'R'  } 4   'LIQ'      'VOICE'; ...
    {'S'  } 2   'FRIC'      'NOVOICE'; ...
    {'SH' } 2   'FRIC'      'NOVOICE'; ...
    {'T'  } 1   'STOP'      'NOVOICE'; ...
    {'TH' } 2   'FRIC'      'NOVOICE'; ...
    {'V'  } 2   'FRIC'      'VOICE'; ...
    {'W'  } 4   'GLIDE'      'VOICE'; ...
    {'Y'  } 4   'GLIDE'      'VOICE'; ...
    {'Z'  } 2   'FRIC'      'VOICE'; ...
    {'ZH' } 2   'FRIC'      'VOICE'];


PH.label = [vows(:,1); cons(:,1); {'sp'}];
PH.son = [5*ones(length(vows),1); cell2mat(cons(:,2)); nan];
PH.son1 = PH.son; 
PH.son1(PH.son1==1) = 2;
PH.vow = [true(length(vows),1); false(size(cons,1),1); false];
PH.moras = [cell2mat(vows(:,2)); nan(size(cons,1),1); nan];
PH.cons = [false(length(vows),1); true(size(cons,1),1); false];
PH.phone = PH.vow | PH.cons;
PH.stress = regexp(PH.label,'\d','match','once');
PH.manner = [repmat({'VOW'}, length(vows),1); cons(:,3); 'NONE'];
PH.voice = [repmat({'VOICE'}, length(vows),1); cons(:,4); 'NONE'];

PH = struct2table(PH);
PH = sortrows(PH,'son','descend');

PH.stress(cellfun(@(c)isempty(c),PH.stress)) = {'NaN'};
PH.stress = str2double(PH.stress);

PH.stop = PH.son==1;
PH.obstruent = PH.son<=2;

PH.form = repmat({''},height(PH),1);
PH.form(PH.stress==0) = {'V0'};
PH.form(PH.stress==1) = {'V1'};
PH.form(PH.stress==2) = {'V2'};
PH.form(PH.cons) = {'C'};
PH.form(ismember(PH.label,{'sp'})) = {'sp'};

end