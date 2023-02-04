function [Ca] = scale_connection(C,f)

%stretches or contracts a line
muC = mean(C);

%center line at origin
Cn = C-repmat(muC,2,1);

%scale
Cn = Cn*f;

%restore position
Ca = Cn+repmat(muC,2,1);


end