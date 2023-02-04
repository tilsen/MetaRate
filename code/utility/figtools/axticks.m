function [] = axticks(axh,direc,len)

if nargin==1
    direc = 'out';
    len = 0.005;
end

set(axh,'tickdir',direc,'ticklen',len*[1 1]);

end

