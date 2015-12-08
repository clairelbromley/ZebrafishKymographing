function errorLog(outputFolder, errString)
% Store error messages to a log file

    logPath = [outputFolder filesep 'error log.txt'];
    disp(errString);
    c = clock;
    dateStr = [num2str(c(1)) '-' num2str(c(2)) '-' num2str(c(3)) ' ' num2str(c(4)) ':' num2str(c(5))];
    outStr = [dateStr ': ' errString '\n\r'];
    if exist(logPath, 'file') == 2
        fid = fopen(logPath, 'at');
    else
        fid = fopen(logPath, 'w');
    end                            
    fprintf(fid, outStr);
    fclose(fid);
end