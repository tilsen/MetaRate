function [C] = connection_constructor(obj1,obj2,varargin)

if isempty(obj1) || isempty(obj2), C=[]; return; end    
    
p = inputParser;

def_linewidth = 2;
def_linecolor = [0 0 0];
def_conntype = 'forward';
def_label = '';

addRequired(p,'obj1');
addRequired(p,'obj2');
addParameter(p,'label',def_label);
addParameter(p,'linewidth',def_linewidth);
addParameter(p,'linecolor',def_linecolor);
addParameter(p,'conntype',def_conntype);

parse(p,obj1,obj2,varargin{:});

C.label = {p.Results.label};
C.obj1 = obj1.handles.fh;
C.obj2 = obj2.handles.fh;
C.name = {[obj1.name '_' obj2.name]};
C.name1 = {obj1.name};
C.name2 = {obj2.name};
C.linewidth = p.Results.linewidth;
C.linecolor = p.Results.linecolor;
C.conntype = {p.Results.conntype};


C = struct2table(C);

end