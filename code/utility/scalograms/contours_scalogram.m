function [C] = contours_scalogram(M,c,varargin)

p = inputParser;

addRequired(p,'M');
addRequired(p,'c');

parse(p,M,c,varargin{:});

res = p.Results;

%parse contour:
c=1; n=1;
while c < size(M,2)
    level = M(1,c);
    numvert = M(2,c);
    C(n).level = level;
    C(n).x = M(1,c+1:c+numvert)';
    C(n).y = M(2,c+1:c+numvert)';
    n=n+1;
    c=c+numvert+1;
end

C = struct2table(C);



end