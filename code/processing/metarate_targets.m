function [TARGS] = metarate_targets()

% target datasets:
TARGS = {
    'vowels'                    'all vowels'                        'Vx';
    'consonants'                'all consonants'                    'Cx';
    'vowels_stress0'            'unstressed vowels'                 'V0';
    'vowels_stress1'            'primary stressed vowels'           'V1';
    'consonants_onsets'         'consonants in onsets'              '.C';
    'consonants_codas'          'consonants in codas'               'C.';
    'consonants_simplexonsets'  'consonants in simplex onsets'      '.C-';
    'consonants_simplexcodas'   'consonants in simplex codas'       '-C.';
    'consonants_stops'          'stop consonants'                   'T';
    'consonants_nonstops'       'non-stop consonants'               '~T'};

%{
TARGS = {
    'vowels'                    'all vowels'                        'Vx';
    'consonants'                'all consonants'                    'Cx';
    'vowels_stress0'            'unstressed vowels'                 'V0';
    'vowels_stress1'            'primary stressed vowels'           'V1';
    'vowels_stress2'            'secondary stressed vowels'         'V2';
    'consonants_onsets'         'consonants in onsets'              '.C';
    'consonants_codas'          'consonants in codas'               'C.';
    'consonants_simplexonsets'  'consonants in simplex onsets'      '.C-';
    'consonants_simplexcodas'   'consonants in simplex codas'       '-C.';
    'consonants_complexonsets'  'consonants in complex onsets'      '.CC';
    'consonants_complexcodas'   'consonants in complex codas'       'CC.';
    'consonants_stops'          'stop consonants'                   'T';
    'consonants_nonstops'       'non-stop consonants'               '~T';
    'syllables'                 'all syllables'                     '\sigmax'; 
    'syllables_stress0'         'unstressed syllables'              '\sigma0';
    'syllables_stress1'         'primary stressed syllables'        '\sigma1';
    'syllables_stress2'         'secondary stressed syllables'      '\sigma2'};
%}

TARGS = array2table(TARGS,'VariableNames',{'target','description','descr'});

TARGS.symb = TARGS.descr;
TARGS.symb = regexprep(TARGS.symb,'\.$','\\bullet');
TARGS.symb = regexprep(TARGS.symb ,'^\.','\\circ');
TARGS.symb = regexprep(TARGS.symb ,'~','\\sim');

end