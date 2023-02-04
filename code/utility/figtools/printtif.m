function [] = printtif(varargin)

if nargin==1
    print('-dtiff','-r400',[varargin{1} '.tif']);
else
    ST = dbstack;
    print('-dtiff','-r400',[ST(end).name '.tif']);
end

end