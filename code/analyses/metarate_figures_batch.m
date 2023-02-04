function [] = metarate_figures_batch()

dbstop if error; close all;

h = metarate_helpers;

do_copy_to_numbered = true;

if do_copy_to_numbered
    files = rdir([h.figures_dir 'fig_*.tif']); %#ok<UNRCH> 
    for i=1:length(files)
        delete(files(i).name);
    end
end

%%
fig_rate_parameters;
fig_proportional_duration;
fig_method_articulator_vel;
fig_method_scalogram_interpretation;
fig_method_dataselection;
fig_method_scalogram_quantities;

fig_comparison_classes;
fig_comparison_exclusion;            % comparison of inclusion/exclusion
fig_comparison_units;                % comparison of phone, sylb, and word rates
fig_comparison_inversion;            % comparison of proper vs. inverse rates
fig_functional_relations_inversion;
fig_comparison_utterancepos;         % comparison of begin-anchored vs. end-anchored targets
fig_comparison_bytarget;             % comparison of vowels vs. consonants and primary/unstressed vowels
fig_comparison_asymmetries;
fig_utterance_windows;
fig_simulations_inclusion;  

%%
if do_copy_to_numbered
    %assumes figures are generated in order above
    if ~exist([h.figures_dir 'numbered' filesep],'dir')
        mkdir([h.figures_dir 'numbered' filesep]); 
    end
    files = rdir([h.figures_dir 'fig_*.tif']);
    files = struct2table(files);
    files = sortrows(files,'datenum','ascend');
    for i=1:height(files)
        copyfile(files.name{i},[h.figures_dir 'numbered' filesep sprintf('fig_%02i.tif',i)]);
    end
end

%% appendix figures
fig_method_syllabification;

end








