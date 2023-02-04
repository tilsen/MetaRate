function [figh] = stfig_bare(figh)

if nargin==0
    figh = gcf;
end

set(figh,'menubar','none','toolbar','none','name','','numbertitle','off');

end

