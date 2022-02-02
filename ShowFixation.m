function fixdura=ShowFixation(window, white, squarephoto)
% Displays fixation cross
[nx, ny, bbox] = DrawFormattedText(window, '+', 'center', 'center',[255 255 255], 50);
Screen('FillRect', window, white, squarephoto)
fixdura=Screen ('Flip', window);