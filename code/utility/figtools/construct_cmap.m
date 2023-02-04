function [cmap] = construct_cmap(N,clims,threshval,startcol,midcol,endcol,nancol,nscol)

cvals = linspace(clims(1),clims(end),N);
ix_begin_colors = find(cvals>threshval,1,'first');

if isempty(ix_begin_colors)
    color_cmap = stf_colormap(N+1,startcol,midcol,endcol);
    cmap = [nancol; color_cmap];    
else
    color_cmap = stf_colormap(N-ix_begin_colors+1,startcol,midcol,endcol);
    cmap = [nancol; repmat(nscol,ix_begin_colors-1,1); color_cmap];
end

end

