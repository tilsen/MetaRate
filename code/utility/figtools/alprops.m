function [props] = alprops(str)

str1='HorizontalAlignment';
str2='VerticalAlignment';
switch(str)
    case 'ct'
        val1 = 'center';
        val2 = 'top';
end

props = {str1,val1,str2,val2};

evalin('caller',['ce = @(x)x{:}']);

end