function [ix] = selax(ax,str)

%select axes from set of axes ax with userdata matching str

ix = [];
for i=1:length(ax)
    if ~isempty(ax(i).UserData)
        if strcmp(ax(i).UserData,str)
            ix = [i ix];
        end
    end
end

end