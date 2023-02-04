function [h] = matrix_gridlines(varargin)

if nargin==0
    color = [1 1 1];
    ax = gca;
elseif nargin==1
    if ishandle(varargin{1})
        ax = varargin{1};
        color = [1 1 1];
    else
        color = varargin{1};
        ax = gca;
    end
elseif nargin==2
    ax = varargin{1};
    color = varargin{2};
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