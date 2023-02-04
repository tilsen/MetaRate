function [] = printpng(varargin)

if nargin==1
    print('-dpng','-r400',[varargin{1} '.png']);
else
    ST = dbstack;
    print('-dpng','-r400',[ST(end).name '.png']);
end

end