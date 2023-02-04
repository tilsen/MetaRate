function [Ca] = adjust_connection(C,f)

%reduces length of a connection line by factor f, maintaining center

%assumes [x1 y1; x2 y2] (rows are points)

%set first point to origin
Cn = C-C(1,:);

%rotate
a = -atan2(Cn(2,2),Cn(2,1));
Cr = ([cos(a) -sin(a); sin(a) cos(a)]*Cn')';

%find center
xc = mean(Cr(:,1));

%find length
len = diff(Cr(:,1));

PP = [xc+f*len*[-1/2; 1/2] [0; 0]];

Cr2 = ([cos(-a) -sin(-a); sin(-a) cos(-a)]*PP')';
Ca = Cr2+C(1,:);


end