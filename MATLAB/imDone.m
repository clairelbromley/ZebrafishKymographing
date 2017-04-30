function imDone()

    load handel;
    player = audioplayer(y, Fs);
    try
        play(player)
    catch
        beep;
    end
    uiwait(msgbox('Hallelujah, I''m finished!x', 'Done!'));
    stop(player)
    
end