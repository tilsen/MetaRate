function [status_str] = status(status_str)


if nargin==0 || strcmp(status_str,'clear')  %clear instruction
    if evalin('caller','exist(''status_str'',''var'')')
        fprintf(repmat('\b',1,evalin('caller','length(status_str)')));
        evalin('caller','clear(''status_str'')')
    end
    
elseif strcmp(status_str,'reset')
    if evalin('caller','exist(''status_str'',''var'')')
        fprintf('\n');
        evalin('caller','clear(''status_str'')')
    end    
    
else %backspace and update
    
    if evalin('caller','exist(''status_str'',''var'')')
        fprintf(repmat('\b',1,evalin('caller','length(status_str)')));
    end
    fprintf(status_str);
    
end

end

