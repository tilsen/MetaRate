function [varargout] = tprops(varargin)

props = {};

for i=1:length(varargin)

    switch(varargin{i})
        case {'top','bot','bottom','mid','middle'}
            props = [props {'verticalalignment' varargin{i}}];

        case {'left','l','right','r','center','c','cent'}
            props = [props {'horizontalalignment' varargin{i}}];
    end

end

%evalin("caller",strjoin(props,','));
varargout = props;


end