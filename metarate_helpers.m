function [h,PH] = metarate_helpers()

dbstop if error;
addpath(genpath('.'));

switch(ispc)
    case 1
        h.corpus_dir = 'M:\Data\Haskins_IEEE_Rate_Comparison_DB\';
        h.data_dir = 'M:\Data\metarate_opendata\';

    case 0
        h.corpus_dir = '/home/tilsen/Data/Haskins_IEEE_Rate_Comparison_DB/';
        h.data_dir = '/home/tilsen/Data/meta_rate/';
end

h.rates_dir = [h.data_dir 'RATES' filesep];
h.regress_dir = [h.data_dir 'REGRESSIONS' filesep];
h.datasets_dir = [h.data_dir 'DATASETS' filesep];
h.figures_dir = ['.' filesep 'figures' filesep];

PH = metarate_phones();

h.frame_rate = 1000;

h.units = {'phones' 'moras' 'sylbs' 'words' 'artics'};

h.sigma = [0.025 0.025];
h.nancol = 0.8*ones(1,3);
h.pos_col = [0.1647    0.7059    0.7882];
h.neg_col = [0.6353    0.0784    0.1843];
h.rho_contour_step = 0.10;

h.fs = [36 26 22 18]; %font sizes

h.printfig = @(str)print('-dtiff','-r350',[h.figures_dir str '.tif']);
       
end

%%
function [] = check_and_addpath(path)

if ~exist(path,'dir')
    %1
else
    addpath(path);
end

end

