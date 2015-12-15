function imDone()

    load handel;
    player = audioplayer(y, Fs);
    play(player)
    uiwait(msgbox('Hallelujah, I''m finished!x', 'Done!'));
    stop(player)
    
end