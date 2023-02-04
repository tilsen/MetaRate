function [SC] = prep_scalographs(T,G,varargin)

h = metarate_helpers;

p = inputParser;

def_climsets = {1:size(G,1)};
def_rhostep = h.rho_contour_step;
def_scalogram_var = 'rho';
def_axes_index = 1:length(G);

addRequired(p,'T');
addRequired(p,'G');
addParameter(p,'climsets',def_climsets);
addParameter(p,'rhostep',def_rhostep);
addParameter(p,'scalogram_var',def_scalogram_var);
addParameter(p,'axes_index',def_axes_index);

parse(p,T,G,varargin{:});

rho_step = p.Results.rhostep;
scalogram_var = p.Results.scalogram_var;
climsets = p.Results.climsets;

PAR = T.Properties.UserData;

% prepare scalographs and plotting info

H.sigma = h.sigma;
nancol = h.nancol;
pos_col = h.pos_col;
neg_col = h.neg_col;
Ncol = 5000;

%%
for i=1:length(G)

    %status_str = status('progress_full',i,length(G),'preparing scalographs'); %#ok<NASGU> 
    
    Gx = G(i).subset;
    
    if isempty(Gx), continue; end
    
    %{'target','unit','inversion','datasel','winmethod','exclusion'}

    for j=1:length(Gx)

        if isempty(PAR)
            TT{i,j} = T(ismember(T.target,Gx(j).target) ...
                & ismember(T.unit,Gx(j).unit) ...
                & ismember(T.inversion,Gx(j).inversion)...
                & ismember(T.datasel,Gx(j).datasel)...
                & ismember(T.winmethod,Gx(j).winmethod)...
                & ismember(T.exclusion,Gx(j).exclusion),:);
        else
            TT{i,j} = PAR.index(T,Gx(j).target,Gx(j).unit,Gx(j).inversion,...
                Gx(j).datasel,Gx(j).winmethod,Gx(j).exclusion);
        end
        
        if isempty(TT{i,j})
            
            %fprintf('error: scalogram values not found\n'); 
            %return;
            continue; 
        end
                
        if Gx(j).inversion==0
            TT{i,j}.rho = -TT{i,j}.rho;
        end           
        
        [X{i,j},Y{i,j},Z{i,j}] = gen_scalogram(TT{i,j},scalogram_var,'filter',H); 
        

        if ismember({'endanchored'},Gx(j).winmethod) && length(Gx)==2 %flip when plotting difference
            Z{i,j} = fliplr(Z{i,j});
        end
        
    end
    
    SC(i).XX = X{i,1};
    SC(i).YY = Y{i,1};
    
    switch(length(Gx))
        case 1
            SC(i).varlab = '{\it{r}}^{\prime}';
            SC(i).ZZ = Z{i,1};
            SC(i).rho_range = minmax(SC(i).ZZ(:)');
            SC(i).clims = [SC(i).rho_range];
            SC(i).cmap = [nancol; viridis(Ncol)];
            SC(i).rho_levels = 0:rho_step:1;
            SC(i).panlab = metarate_labels(Gx,'panel');
            
        case 2
            
            SC(i).varlab = '\Delta{\it{r}}^{\prime}';

            ix1 = 1:size(X{i,1},1); ix2 = ix1;
            iy1 = 1:size(Y{i,1},1); iy2 = iy1;
            if size(X{i,1},1)~=size(X{i,2},1)
                 [~,ix1,ix2] = intersect(round(X{i,1},4),round(X{i,2},4));
                 SC(i).XX = X{i,1}(ix1);            
            end
            if size(Y{i,1},1)~=size(Y{i,2},1)
                 [~,iy1,iy2] = intersect(round(Y{i,1},4),round(Y{i,2},4));
                 SC(i).YY = Y{i,1}(iy1);                 
            end
            SC(i).ZZ = Z{i,1}(iy1,ix1)-Z{i,2}(iy2,ix2);
            SC(i).rho_range = minmax(SC(i).ZZ(:)');
            SC(i).clims = max(abs(SC(i).rho_range))*[-1 1];   
            SC(i).cmap = [nancol; stf_colormap(Ncol,neg_col,[1 1 1],pos_col)]; 
            SC(i).rho_levels = -1:rho_step:1;
            SC(i).panlab = {...
                ['[' metarate_labels(Gx(1),'panel') '] - '], ...
                ['[' metarate_labels(Gx(2),'panel') ']']};
    end
    
    SC(i).ax_ix = p.Results.axes_index(i);

end
%status('reset');

for i=1:length(climsets)
    clims = minmax([SC(climsets{i}).clims]);
    for j=climsets{i}
        SC(j).clims = clims + [-0.001 0.001];
    end
end

end
