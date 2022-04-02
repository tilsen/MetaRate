function [Xs,Ys,Zs,varargout] = smooth_scalogram(X,Y,Z,dxy,H,clipinvalid)

%X: x-coordinates (vector of window centers)
%Y: y-coordinates (vector of window scales)
%Z: matrix of scalogram values
%dxy: vector interpolation steps in x and y coordinates
%sigma


X0 = X;
Y0 = Y;
Z0 = Z;

validpp = [min(X0) min(Y0); max(X0) min(Y0); ...
    X0(find(Z0(end,:)~=0,1,'last')) max(Y0); ...
    X0(find(Z0(end,:)~=0,1,'first')) max(Y0); ...
    ];

interp_method = 'spline'; 
% interp_method = 'linear'; 
% interp_method = 'makima'; 
% interp_method = 'cubic'; 

if nargin==4
    H = [];
elseif nargin==3
    dxy = [];
end

%% extrapolation and smoothing
if ~isempty(H)
    
    Z(Z==0) = nan;
    Z0 = Z;
    
    
    [xx,yy] = meshgrid(X,Y);
    XY = [xx(:) yy(:)];
    Zn = nan(size(Z));
    
    %
    for r =1:size(Z,1)
        for c=1:size(Z,2)
            %win = mvnpdf(XY,[X(c) Y(r)],H.sigma);
            win = reshape(mvnpdf(XY,[xx(r,c) yy(r,c)],diag(H.sigma.^2)),size(Z,1),[]);
            win(isnan(Z)) = nan;
            win = win/nansum(win(:));
            
            W{r,c} = win;
            
            Zn(r,c) = nansum(Z(:).*win(:));
            
        end
    end
    
    Z = Zn;
    varargout{2} = Z;
    
    %restore original size
    %Z(isnan(Z0)) = 0;

end

%% interpolation
if ~isempty(dxy)
    dx = dxy(1);
    dy = dxy(2);
    
    Xs = X(1):dx:X(end);
    Ys = Y(1):dy:Y(end);
    
    %Xi = linspace(0,1,length(Xs));
    %Yi = linspace(0,1,length(Ys));
    
    %Xn = linspace(0,1,size(Z,2));
    %Yn = linspace(0,1,size(Z,1));
    
    [xxi,yyi] = meshgrid(Xs,Ys);
    [xx,yy] = meshgrid(X,Y);
    
    Zs = interp2(xx,yy,Z,xxi,yyi,interp_method);
    
    Xs = Xs';
    Ys = Ys';
    
    [xx,yy] = meshgrid(Xs,Ys);
    
    [in,on] = inpolygon(xx,yy,validpp(:,1),validpp(:,2));
    Zs(~(in | on)) = nan;

else
    Xs = X;
    Ys = Y;
    Zs = Z;
end

%%
if clipinvalid
    ix_scales = [find(any(~isnan(Zs),2),1,'first') find(any(~isnan(Zs),2),1,'last')];
    Zs = Zs(ix_scales(1):ix_scales(2),:);
    Ys = Ys(ix_scales(1):ix_scales(2));
    
    ix_centers = [find(any(~isnan(Zs),1),1,'first') find(any(~isnan(Zs),1),1,'last')];
    Zs = Zs(:,ix_centers(1):ix_centers(2));
    Xs = Xs(ix_centers(1):ix_centers(2));    
end

end



%     Z0 = Z;
%     Z(Z==0) = nan;
%     
%     [rc] = (size(H)-1)/2;
%     %Hr = -rc(1):rc(1);
%     %Hc = -rc(2):rc(2);
%     
%     %surround with nan and extrapolate
%     hsize = size(H);
%     %b = 2*hsize;
%     %Zn = nan(size(Z,1)+b(1),size(Z,2)+b(2));
%     
%     %pad with nan
%     Zn = nan(size(Z,1)+2*hsize(1),size(Z,2)+2*hsize(2));
%     
%     %orig_ixs = {b(1)/2+1:size(Zn,1)-b(1)/2,b(2)/2+1:size(Zn,2)-b(2)/2};
%     orig_ixs = {(1+hsize(1)):size(Zn,1)-hsize(1),(1+hsize(2)):size(Zn,2)-hsize(2)};
%     Zn(orig_ixs{1},orig_ixs{2}) = Z;
%     
%     %linear indices for all windows:
%     R=1:(size(Zn,1)-hsize(1)+1);
%     C=1:(size(Zn,2)-hsize(2)+1);
%     [RR,CC]=meshgrid(R,C);
%     IX0 = [RR(:) CC(:)];
%     IX1 = IX0 + hsize-1;
%     Z = arrayfun(@(c)nansum(Zn(IX0(c,1):IX1(c,1),IX0(c,2):IX1(c,2)).*H,[1 2]),(1:size(IX0,1)));
%     Z = reshape(Z,size(RR,1),[])';
%     
% %     %extrapolation
% %     Zn1 = Zn;
% %     for n=1:max(size(H))
% %         for r=(1+rc(1)):size(Zn,1)-rc(1)
% %             for c=(1+rc(2)):size(Zn,2)-rc(2)
% %                 if isnan(Zn(r,c)) && any(reshape(~isnan(Zn(r+Hr,c+Hc)),1,[]))
% %                     Zn1(r,c) = nanmean(reshape(Zn(r+Hr,c+Hc),1,[]).*reshape(~isnan(Zn(r+Hr,c+Hc)),1,[]));
% %                 else
% %                     Zn1(r,c) = Zn(r,c);
% %                 end
% %             end
% %         end
% %         Zn = Zn1;
% %     end
% %     %Zn = Zn1;
% %     
% %     dx = mean(diff(X));
% %     dy = [Y(2)-Y(1) Y(end)-Y(end-1)];
% %     Z_extrap.Z = Zn;
% %     Z_extrap.X = [X(1)-dx*((b(1)/2):-1:1)'; X; X(end)+dx*(1:(b(1)/2))'];
% %     Z_extrap.Y = [Y(1)-dy(1)*((b(1)/2):-1:1)'; Y; Y(end)+dy(2)*(1:(b(1)/2))'];
% %     
% %     varargout{1} = Z_extrap;
%     
%     %2d smoothing filter
%     %Z = filter2(H,Zn,'same');  %#ok<*UNRCH>
%     varargout{2} = Z;
%     
%     %restore original size
%     
%     Z(isnan(Z)) = 0;
%     
%     %Z = Z(orig_ixs{1},orig_ixs{2});
%     
%     X = Z_extrap.X;
%     Y = Z_extrap.Y;
