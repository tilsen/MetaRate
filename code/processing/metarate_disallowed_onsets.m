function [do] = metarate_disallowed_onsets(PH)

do = [];
for a=2:3
    for b=(a:a+1)
        ci = combvec(find(ismember(PH.son1,[a b]))',find(ismember(PH.son1,[a b]))');
        cc = PH.label(ci)';
        do = [do; arrayfun(@(c)strjoin(cc(c,:),' '),(1:size(cc,1))','un',0)];
    end
end

%allow S-stop/nasal cluster
do = setdiff(do,{'S T','S K','S P','S M','S N'});

%disallow coronal stop-lateral cluster
do = [do; {'D L' 'T L'}'];
    

end
