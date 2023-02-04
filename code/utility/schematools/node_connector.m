function [C] = node_connector(obj1,obj2,varargin)

p = inputParser;

def_linewidth = 2;
def_linecolor = [0 0 0];
def_conntype = 'forward';
def_label = '';
def_reduceline = [0 0]; %amount to reduce in normalized figure units

addRequired(p,'obj1');
addRequired(p,'obj2');
addParameter(p,'label',def_label);
addParameter(p,'linewidth',def_linewidth);
addParameter(p,'linecolor',def_linecolor);
addParameter(p,'conntype',def_conntype);
addParameter(p,'reduceline',def_reduceline);

parse(p,obj1,obj2,varargin{:});

C.label = {p.Results.label};
C.obj1 = obj1.fh;
C.obj2 = obj2.fh;
C.name = {[obj1.name{:} '_' obj2.name{:}]};
C.name1 = obj1.name;
C.name2 = obj2.name;
C.linewidth = p.Results.linewidth;
C.linecolor = p.Results.linecolor;
C.conntype = {p.Results.conntype};

C = struct2table(C);

cc = connecting_line(C.obj1,C.obj2);

if ~all(p.Results.reduceline==0)
    [rdux,rduy] = nfu2axu(p.Results.reduceline(1),p.Results.reduceline(2));
    cc_len = sqrt(sum(diff(cc).^2));
    rd_len = sqrt(sum(rdux^2+rduy^2));
    sc = (cc_len-rd_len)/cc_len;
    cc = scale_connection(cc,sc);
end

C.conn{1} = cc;

end