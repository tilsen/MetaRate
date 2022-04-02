%% Metarate processing and analysis workflow
% The following is the workflow used for all analyses in the paper "Parameters 
% of unit-based measures of speech rate". The steps in the section "*initial data 
% extraction*" require a path to the Haskins IEEE Rate comparison corpus, which 
% is freely available at <http://bit.ly/2s4mtOq http://bit.ly/2s4mtOq>. These 
% steps can be skipped.
%% 
% Define system-specific paths, various utility functions, and some global analysis 
% parameters:

metarate_helpers;
%% 
% NOTE: The following paths in this |metarate_helpers.m| must be edited for 
% the user's system:
%% 
% * h.corpus_dir (directory of Haskins IEEE corpus)
% * h.data_dir     (directory to store processed data )
%% Initial data extraction
% These steps can be skipped if the files |metarate_segmentdata.mat| and |metarate_artic_vel.mat| 
% are in the data directory (defined in |metarate_helpers.m|)
%% 
% Collects metadata and phone/word information from the *Haskins IEEE Rate Comparison* 
% corpus. Saves in file: |metarate_segmentdata_raw.mat.| Also corrects a handful 
% of intervals that are mislabeled in the corpus.

metarate_extract_segmentdata;
%% 
% Incorporates short silent pauses (label "|sp"|) into preceding/following stops. 
% Short pauses are defined as ones below a duration threshold, here $0.100$ seconds. 
% Saves as |metarate_segmentdata.mat:|

metarate_assign_sp;
%% 
% Extracts total articulatory velocity signals from the *Haskins IEEE Rate Comparison* 
% corpus, defined as $\sqrt{\sum_{ij}(\nabla x_{ij})^2}$, where $\nabla x_{ij}$ 
% is the 1-dimensional numerical gradient (central difference) of the position 
% timeseries of the$j$th dimension of the $i$th sensor. Saves in |metarate_artic_vel.mat|.

metarate_extract_articulator_vel;
%% Processing
% The following processing/analysis steps can be conducted using the files |metarate_segmentdata.mat| 
% and |metarate_artic_vel.mat|, without performing the initial data extraction 
% steps above. 
% Syllabification
% Syllabifies segments using constraints (see text for details). Add syllable 
% info to |metarate_segmentdata.mat|:

metarate_syllabify_segmentdata_sonority;
%% 
% Also makes a table of all syllable parses, saved in |word_syllable_parses.csv|
% Moratization
% Parses syllables into moras. Moras are defined as described below. Bimoraic 
% vowels are English tense/long vowels and diphthongs in syllables with primary 
% or secondary stress.
%% 
% * If a syllable is stressed and contains a bimoraic vowel, parse the syllable 
% as two moras, splitting at the midpoint of the vowel.
% * If a syllable contains a monomoraic vowel and one or more codas, parse the 
% syllable as two moras, splitting at the end of the vowel.
% * Otherwise the syllable is parsed into one mora.
%% 
% The moraic parsing can be represented abstractly as follows, with "|" indicating 
% mora boundaries and "." indicating syllable boundaries. Tense vowels and dipththongs 
% are assumed to be represented as "VV":
%% 
% * .|(C(C(C)))V|(*)|.

metarate_moratize_segmentdata;
%% 
% Adds the moraic parsing to the |metarate_segmentdata.mat|
% Velocity-based segmentation
% Segments the negative of the total articulatory velocity signal using the 
% |findpeaks| function, with parameters:
%% 
% * MinPeakProminence: 0.03 (normalized units)
% * MinPeakDistance: 0.05 seconds
%% 
% These parameters were chosen on the basis of an analysis of how the correlation 
% of number of articulatory segments and number of phones varies as a function 
% of the two parameters, defined over a grid. The articulatory velocity signal 
% is normalized to the range $[0,1]$ on each trial. Saves the segmentation in 
% |metarate_segmentation_artic.mat:|

metarate_segment_articulator_vel;
%% 
% Combines the articulatory segmentation in |metarate_segmentation_artic.mat| 
% with the phone, mora, syllable, and word segmentations in |metarate_segmentdata.mat:|

metarate_combine_segmentations;
%% Proportional count timeseries
% Calculates proportional count time series for all event-interval types. Saves 
% as |metarate_propdurs.mat:|

metarate_frame_proportions;
%% Target data tables
% Make separate data tables for vowel, consonant, and syllable durations. 
% 
% Creates |metarate_durdata_vowels.mat| and |metarate_durdata_consonants.mat|:

metarate_prep_durdata_segments;
%% 
% Creates |metarate_durdata_syllables.mat|:

metarate_prep_durdata_syllables;
%% 
% Generates target datasets:

metarate_gen_durdata_targets;
%% Scalographic analyses
% Conduct scalographic analyses of partial correlation for all combinations 
% of rate measures/parameters/targets (specified in file):

metarate_scalographic_analysis_batch;
%% 
% Collect scalographic analyses of partial correlation into a single table:

metarate_collect_scalographs;
%% Analyses and figures
% The following code conducts the analyses reported in the mansucript and generates 
% all figures in the manuscript.
%% 
% Summarizes corpus metadata:

metarate_metadata_analysis;
%% 
% Makes table of scalograph slices and summary measures. Saves as |analysis_comparisons.mat| 
% in figures directory:

metarate_comparison_general;
%% 
% Collects some example data from scalographic analyses. Saves as |example1.mat| 
% and |example2.mat| in figures directory:

metarate_functional_relations_examples;
%% 
% Return table with sizes of datasets and table with all syllable forms sorted 
% by proportion:

metarate_targets_analysis;
%% 
% Conducts simulations of regression analyses with and without inclusion. Saves 
% in |regression_inclusion_simulations.mat| in figures directory:

metarate_regression_inclusion_simulations;
%% 
% Generates all manuscript figures:

metarate_figures_batch;
%% 
% 
% 
% 
% 
%