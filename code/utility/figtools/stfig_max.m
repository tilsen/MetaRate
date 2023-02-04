function [varargout] = stfig_max(varargin)

[~,hn] = system('hostname');

switch(strtrim(hn))
    case 'DESKTOP-QVDSML8'
        nfpos = [-1 0 1 1];
    case 'SAM-DESKTOP'
        
    otherwise
        nfpos = [0 0 1 1];
end

if ~exist('WindowAPI','file')
    h=figure;
    set(gcf,'units','normalized','position',nfpos);
    varargout = {h};
    drawnow;
    return;
end

if isempty(varargin)
    h=figure; set(gcf,'units','normalized','position',nfpos);
    if ispc
        WindowAPI(h,'Maximize');
    end
else
    h = varargin{1};
    set(h,'units','normalized');
    if ispc
        WindowAPI(h,'Maximize'); 
    end
end
varargout = {h};
drawnow;
stfig_bare;
end