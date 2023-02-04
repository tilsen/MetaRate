function [h] = matrix_gridlines(ax,color)

if nargin==0
    color = 'k';
    ax = gca;
elseif nargin==1
    color = 'k';
end

if all(xlim==ylim)
    ix = min(xlim):max(xlim);
    h(:,1) = line(repmat(xlim,length(ix),1)',repmat(ix,2,1),'color',color,'parent',ax);
    h(:,2) = line(repmat(ix,2,1),repmat(ylim,length(ix),1)','color',color,'parent',ax);
else
    ixx = min(xlim):max(xlim);
    ixy = min(ylim):max(ylim);
    h{1} = line(repmat(xlim,length(ixy),1)',repmat(ixy,2,1),'color',color,'parent',ax);
    h{2}= line(repmat(ixx,2,1),repmat(ylim,length(ixx),1)','color',color,'parent',ax);   
end


end