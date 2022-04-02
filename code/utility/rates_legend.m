function [legax] = rates_legend(D,bh,h,loc,numcol,fs)

units = {'phones' 'moras' 'sylbs' 'words' 'artics'}';

%----legend
uu = [reshape(repmat(units,1,2)',[],1) repmat({'proper'; 'inverse'},numel(units),1)];
ixs = cellfun(@(c,d)find(ismember(D.unit,c) & ismember(D.ratio,d),1,'first'),uu(:,1),uu(:,2));

legstrs = strcat(uu(:,1),{' '},uu(:,2));
legobjs = bh(ixs);
legh = legend(legobjs,legstrs,'fontsize',fs,'location',loc,'NumColumns',numcol,'AutoUpdate','off');

legch = legh.EntryContainer.NodeChildren;
for i=1:length(legch)
    legobjs(i) = legch(i).Object;
end

[legobjh,legth,legax] = stfig_legend(legh,fs);
axrescaley([0 0.02],legax);

quickhatch(legobjh(2:2:end),'vertical','w',0.5,0.04);
set(legobjh(2:2:end),'FaceAlpha',0.75);

end