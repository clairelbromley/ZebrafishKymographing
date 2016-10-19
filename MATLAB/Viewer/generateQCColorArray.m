function qcColor = generateQCColorArray(handles, qcColor, direction)

filt = strcmp({handles.includedData.date}, handles.date) & strcmp({handles.includedData.embryoNumber}, handles.embryoNumber) & ...
    ([handles.includedData.cutNumber] == str2double(handles.cutNumber)) & strcmp({handles.includedData.direction}, direction);
tempQC = {handles.includedData.userQCLabel};
tempQC = tempQC(filt);
tempQC(strcmp(tempQC, 'no edge')) = [];

% % this bit is cumbersome - must be a better way of dealing
% % with case when all elements in logical indexing array are
% % false?
% lindarr = strcmp(tempQC, 'Good')';
% if sum(lindarr) > 0
%     qcColor(lindarr, :) = [0 1 0];
% end
% 
% lindarr = strcmp(tempQC, 'not QCd')';
% if sum(lindarr) > 0
%     qcColor(lindarr, :) = [1 1 1];
% end
% 
% lindarr = strcmp(tempQC, 'Manual')';
% if sum(lindarr) > 0
%     qcColor(lindarr, :) = [0 0 1];
% end
% 
% lindarr = strcmp(tempQC, 'Noise')';
% if sum(lindarr) > 0
%     qcColor(lindarr, :) = [1 0 0];
% end
% 
% lindarr = strcmp(tempQC, 'Misassigned')';
% if sum(lindarr) > 0
%     qcColor(lindarr, :) = [0 1 1];
% end

for ind = 1:length(tempQC)

    switch tempQC{ind}
        case 'Good'
            qcColor(ind, :) = [0 1 0];
        case 'Manual'
            qcColor(ind, :) = [0 0 1];
        case 'Noise'
            qcColor(ind, :) = [1 0 0];
        case 'Misassigned edge'
            qcColor(ind, :) = [0 1 1];
        case 'no edge'
            qcColor(ind, :) = [0.3 0.3 0.3];
        otherwise
            qcColor(ind, :) = [0.95 0.95 0.95];    % for now, change back to white after debug
    end
end