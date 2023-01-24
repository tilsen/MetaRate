function [panlab] = metarate_labels(G,labtype)

targets = metarate_targets;

%trg_symb = targets.symb(ismember(targets.target,G.target));
trg_symb = @(x)targets.symb{ismember(targets.target,x)};

exc_strs = {'inc.)','exc.)'};
exc_str = @(x)exc_strs{x+1};

inv_strs = {'(prop.','(inv.'};
inv_str = @(x)inv_strs{x+1};

paren = @(x)['(' x ')'];

ratestr = @(x)[x{:} ' rate '];

switch(labtype)
    case 'panel'
        panlab = strtrim(append(trg_symb(G.target),' \sim ', ratestr(G.unit)));

    case 'panel1'             
        panlab = strtrim(append(G.target,paren(G.datasel),' \sim ',ratestr(G.unit),inv_str(G.inversion),', ',exc_str(G.exclusion)));   

    otherwise
        panlab = strtrim(append(G.target,' \sim ',rate_str(G.unit)));   
end

switch(G.inversion)
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