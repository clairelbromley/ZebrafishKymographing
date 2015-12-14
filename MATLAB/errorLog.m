function errorLog(outputFolder, errString)
% Store error messages to a log file

    logPath = [outputFolder filesep 'error log.txt'];
    disp(errString);
    c = clock;
    dateStr = sprintf('%d-%02d-%02d %02d:%02d', c(1), c(2), c(3), c(4), c(5));
    outStr = [dateStr ': ' errString '\n\r'];
    if exist(logPath, 'file') == 2
        fid = fopen(logPath, 'at');
    else
        fid = fopen(logPath, 'w');
    end                            
    fprintf(fid, outStr);
    fclose(fid);
end