function [panlab] = metarate_labels(G,labtype)

targets = metarate_targets;

trg_symb = targets.symb(ismember(targets.target,G.target));

switch(labtype)
    case 'panel'
        panlab = strjoin([...
            trg_symb,...
            ' \sim ',...
            [G.rate_meas{:} ' rate']], ' ');

    case 'panel1'
        inv_strs = {'(prop.','(inv.'};
        exc_strs = {'inc.)','exc.)'};
        panlab = strjoin([...
            G.target,...
            ['(' G.data_selection{:} ')'],...
            ' \sim ',...
            [G.rate_meas{:} ' rate'],...
            [inv_strs{G.inverse_rate+1} ',' exc_strs{G.target_exclusion+1}]], ' ');        

    otherwise
        panlab = strjoin([...
            G.target,...
            ' \sim ',...
            [G.rate_meas{:} ' rate']], ' ');        
end

switch(G.inverse_rate)
    case 0
        panlab = regexprep(panlab,'phones rate','ph/s');
        panlab = regexprep(panlab,'sylbs rate','\\sigma/s');
        panlab = regexprep(panlab,'words rate','word/s');
        panlab = regexprep(panlab,'moras rate','\\mu/s');
        
    case 1
        panlab = regexprep(panlab,'phones rate','s/ph');
        panlab = regexprep(panlab,'sylbs rate','s/\\sigma');
        panlab = regexprep(panlab,'words rate','s/word');
        panlab = regexprep(panlab,'moras rate','s/\\mu');
        
end

panlab = regexprep(panlab,'_',' ');

end