function Touch_movie(parNo)
%% Critical experimental settings
%sca; clc; close all; clear all;
% if (nargin<1)
%     error('needs participant number as input');
% end
send_trig = 1; %originally 1
numBlocks = 15;
HomeDir = [cd];
stims{1} = dir('500ms/001/0*.mov');
stims{2} = dir('500ms/002/0*.mov');
stims{3} = dir('500ms/003/0*.mov');
stims{4} = dir('500ms/004/0*.mov');
stims{5} = dir('500ms/005/0*.mov');
stims{6} = dir('500ms/006/0*.mov');
stimuliAff=length(stims{1})+length(stims{2})+length(stims{3});
stimuliObj=length(stims{4})+length(stims{5})+length(stims{6});
NumTrial=(stimuliAff+stimuliObj)*numBlocks;
numCatch =round((stimuliAff+stimuliObj)*0.05)*numBlocks;
fixDura = random ('unif', 1, 1.5, NumTrial+(numCatch*2),1); %random duration for fixation -> 1 and 1.5s ;
expTime=(numBlocks*(stimuliAff+stimuliObj)+sum(fixDura));

totalExp=expTime/60; % ~ 45 mins [without counting break time]
sprintf('This experiment will take about %d minutes',round(totalExp))
RandomDir = fullfile(HomeDir, 'Random/'); %reading pseudo randomized trial order. 
file1 = dir([char(RandomDir),'P',num2str(parNo),'_randomList_run*.mat']);
file2 = dir([char(RandomDir),'P',num2str(parNo+20),'_randomList_run*.mat']);
file3 = dir([char(RandomDir),'P',num2str(parNo+40),'_randomList_run*.mat']);
TotalrandomList=[];
for i=1:numBlocks
    if i<7
        TotalrandomList{i}=load([file1(1).folder '/' file1(i).name]);
    elseif 6<i  &&  i <13
        TotalrandomList{i}=load([file2(1).folder '/' file1(i-6).name]);
    else
        TotalrandomList{i}=load([file3(1).folder '/' file1(i-12).name]);
    end
end
blockType=[]; blockType1=[];
for i=1:numBlocks
    findR=(TotalrandomList{1,i}.randomList(:,1)>3);
    blockType{i}=zeros(length(TotalrandomList{1,i}.randomList(:,1)),2);
    for k=1:length(findR)
        if findR(k)==1
            blockType1{i}(k,:) = [TotalrandomList{1,i}.randomList(k,1) TotalrandomList{1,i}.randomList(k,2)-13];
        else
            blockType1{i}(k,:) = [TotalrandomList{1,i}.randomList(k,1) TotalrandomList{1,i}.randomList(k,2)];
        end
        blockType{i} = [blockType1{i}];
    end
end
%% Add catch trials
whereRep=zeros(numCatch/numBlocks,numBlocks);
for i=1:numBlocks
    rand = randperm((stimuliAff+stimuliObj),numCatch/numBlocks);
    catchTrial =  blockType{i}(rand,:);
    catchAll = repelem(catchTrial,2,1);
    randAssign = sortrows(randperm((stimuliAff+stimuliObj),numCatch/numBlocks)','ascend');
    block{i} = [blockType{i}(1:randAssign(1),:); catchAll(1:2,:); blockType{i}(randAssign(1)+1:randAssign(2),:); catchAll(3:4,:);...
        blockType{i}(randAssign(2)+1:randAssign(3),:); catchAll(5:6,:); blockType{i}(randAssign(3)+1:randAssign(4),:); catchAll(7:8,:); blockType{i}(randAssign(4)+1:75,:)] ;
    whereRep(:,i)=[randAssign(1)+1;randAssign(2)+3; randAssign(3)+5; randAssign(4)+7]; % where is the catch trial?
end
simTrials=block;
numTrials=length(simTrials{1});
%% Make TrialList to save 
TotaltrialList=[];
for i=1:numBlocks
    trialNum = (length(simTrials{1,1}));
    trialList(:,1) = repmat(parNo,1,trialNum)';
    trialList(:,2) = repmat(i,1,trialNum)';
    trialList(:,3) = repmat(1:trialNum,1)';
    trialList(:,4) = zeros(trialNum,1);
    trialList(whereRep(:,i)+1,4)=1;
    trialList(:,5) = repmat(simTrials{1,i}(:,1),1)';
    trialList(:,6) = repmat(simTrials{1,i}(:,2),1)';
    trialList(:,7) = zeros(trialNum,1);
    trialList(:,8) = zeros(trialNum,1);
    trialList(:,9) = zeros(trialNum,1);
    trialList(:,10) = zeros(trialNum,1);
    TotaltrialList=[TotaltrialList; trialList];
end
%insert break. you should know what you are doing.
breakBlock = numTrials:numTrials:numTrials*numBlocks;
breakDisp = round(breakBlock/(length(simTrials{1})*numBlocks)*100);
%% EEG - initialize
%triggers: 1 = movie start; 2 = movie end; 3 = response
if send_trig
    %    create an instance of the io64 object
    ioObj = io64; %#ok<*UNRCH>
    %   initialize the interface to the inpoutx64 system driver
    status = io64(ioObj); % if status = 0, you are now ready to write and read to a hardware port
    %  EEG port address
    address = hex2dec('4FB8');%standard LPT1 output port address
end
%% Set active keys
KbName('UnifyKeyNames');
active_key(1) = KbName('j');
active_keys = uint8 (zeros (1, 256));
active_keys (active_key) = 1;

%% Open screen
Screen('Preference', 'DefaultFontSize', 48);
screenres = [1680 1050]; %set window resolution
AssertOpenGL; HideCursor;
ListenChar(2);
try
    Screen('Preference', 'SkipSyncTests', 2); %1 for mac %2 for window
    background_color=[0 0 0];
    screens = Screen('Screens');
    screenNumber= max(screens); % external screen
    Screen('Resolution', screenNumber, screenres(1),screenres(2)); %set resolution for window
    window=Screen('OpenWindow', screenNumber,background_color(1)); % full
    % window = Screen('OpenWindow', screenNumber, background_color(1), [0 0 640*2 480*2]); %for debugging
    % [screenWidth screenHeight]=WindowSize(window); % for mac
    [x,y] = WindowCenter(window);
    black=BlackIndex(window);
    white=WhiteIndex(window);
    red = [255 0 0];
    KbCheck; WaitSecs(0.01); GetSecs; HideCursor;
    priorityLevel=MaxPriority(window); Priority(priorityLevel);
    ifi = Screen('GetFlipInterval', window); % Measure the vertical refresh rate of the monitor
    screenRect = Screen ('rect',window);
    centX = screenRect(3)/2; %??
    centY = screenRect(4)/2;
    squarephoto = [95 centY-12 119 centY+12]; %photo diode location
    Screen ('Flip', window);
    %% intro setting
    SaveDir = fullfile(HomeDir, 'DATA/');
    StartText = 'Please stay still during the experiment.'
    Start = [StartText];
    InstructionText = 'Press the button with your right hand each time the current video is the same as the one presented just before.';
    Instruction=[InstructionText];
    %% Instruction Screen
    disp('Starting experiment');
    Screen('TextSize',window, 50);
    [nx, ny, bbox] = DrawFormattedText(window, Start, 'center', 'center',[255 255 255], 50);
    Screen ('Flip', window);
    WaitSecs(3);
    Screen('TextSize',window, 50);
    [nx, ny, bbox] = DrawFormattedText(window, Instruction, 'center', 'center',[255 255 255], 50);
    Screen ('Flip', window);
    %% Pull the Trigger!!
    %Start experiment by pressing F
    key = 0;
    while (~key)
        [keyPressed, seconds, keyCode] = KbCheck;
        if (keyPressed)
            key = find (keyCode) == KbName ('f');
        end
    end
    
    if send_trig, io64(ioObj,address,0); end %set trigger to 0
    %% Experiment starts;
    for currBlock=1:numBlocks % 15 blocks in total, block=repetition.
        sprintf('%dth block begins',currBlock)
        start=GetSecs();
        for currStim = 1:numTrials % 75 stimulus + some catch trials
            starttri=GetSecs();
            StimuliDir=fullfile(HomeDir,sprintf('500ms/%03d/',TotaltrialList(currStim,5)));
            moviefile=fullfile(StimuliDir, sprintf('/%03d.mov',TotaltrialList(currStim,6)));
            ISI=fixDura(currStim+((numBlocks-1)*numTrials)); % ISI=interval showing the fixation cross
           if currStim==1
            ShowFixation(window, white, squarephoto); % start with the fixation cross
            WaitSecs(2);
           else
           end
            [movie dur fps sx sy]= Screen('OpenMovie', window, moviefile, 0); %open movie
            Screen('PlayMovie',movie,1,0,0); %play movie
            % Playback loop: Fetch video frames and display them...
            destrect=[x-sx/4, y-sy/4, x+sx/4, y+sy/4];
            while(1)
                [tex,pts] = Screen('GetMovieImage', window, movie, 1); %get movie as a texture
                % Valid texture returned?
                if (tex>0)
                    % Yes. Draw the new texture immediately to screen:
                    Screen('DrawTexture', window, tex, [], destrect);
                    DrawFormattedText(window, '+', 'center', 'center',[255 255 255], 50);
                    Screen('FillRect', window, black, squarephoto); % to time it on the photodiode
                    Screen('Flip', window);
                    % Update display:
                    if pts==0
                        onsettime=GetSecs;
                        %&&pts<0.04 %1st frame occurs at 0.03 s (30 FPS)
                        if send_trig %send trigger on 1st frame
                            io64(ioObj,address,1);
                            WaitSecs(0.02);
                        end
                        %fprintf('\ntrig %d', t)
                    end
                    
                    %record response - can be delayed to fixation period
                    [keyPressed, seconds, keyCode] = KbCheck;
                    if (keyPressed)
                        if (any ((keyCode > 0) & active_keys))
                            TotaltrialList(currStim+(numTrials*(currBlock-1)),7) = 1;
                            fprintf('response made at block %d,trial %d  \n',TotaltrialList(currStim+(numTrials*(currBlock-1)),2), ...
                            TotaltrialList(currStim+(numTrials*(currBlock-1)),3));
                            if send_trig %send trigger on response
                                io64(ioObj,address,3);
                                WaitSecs(0.02);
                            end
                            
                        end
                    end
                    
                    % Release texture:
                    Screen('Close', tex);
                end
                
                if tex<0
                    videoDuration=GetSecs()-onsettime;
                    if send_trig
                        io64(ioObj,address,2); %trigger on movie end
                        WaitSecs(0.02); %make sure there's enough time to send the trigger
                    end
                    % No. This means that the end of this movie is reached - exit the loop
                    break
                end
                
            end
            
            % Done with old movie. Stop its playback:
            Screen('PlayMovie', movie, 0);
            
            % Close movie object:
            Screen('CloseMovie', movie);
            clear movie
            %fixation cross
            fixdura=ShowFixation(window, white, squarephoto);
            currentTime = GetSecs - fixdura;
            while (currentTime <= ISI) %show fixation until ISI duration (1~1.5 sc)
                currentTime = GetSecs - fixdura;
                [keyPressed, seconds, keyCode] = KbCheck;
                if (keyPressed) % people can still response during this time
                    if (any ((keyCode > 0) & active_keys))
                        TotaltrialList(currStim+(numTrials*(currBlock-1)),7) = 1;
                        fprintf('response made at block %d,trial %d  \n',TotaltrialList(currStim+(numTrials*(currBlock-1)),2), ...
                            TotaltrialList(currStim+(numTrials*(currBlock-1)),3));
                        if send_trig %send trigger on response
                            io64(ioObj,address,3);
                            WaitSecs(0.02);
                        end
                        
                    end
                end
            end
            fixtime=GetSecs()-fixdura;
            TotaltrialList(currStim+(numTrials*(currBlock-1)),8) = videoDuration;
            TotaltrialList(currStim+(numTrials*(currBlock-1)),9) = fixtime;
            trialdura=GetSecs()-starttri;
            TotaltrialList(currStim+(numTrials*(currBlock-1)),10) = trialdura;
        end
        blockdura=GetSecs()-start
        %display break message
        if currStim==length(simTrials{currBlock})
            breakstring = sprintf('Break time!\n %d%% completed. \n \nPress left key to continue.',breakDisp(currBlock));
            Screen('TextSize',window, 50);
            [nx, ny, bbox] = DrawFormattedText(window, breakstring, 'center', 'center',[255 255 255], 50);
            Screen ('Flip', window);
            %Continue experiment by pressing space
            key = 0;
            while (~key)
                [keyPressed, seconds, keyCode] = KbCheck;
                if (keyPressed)
                    key = find (keyCode) == KbName ('f');
                end
            end
        end
        
    end
    disp('save the file');
    save([char(SaveDir),'P',num2str(parNo),'_SocialTouch_EEG.mat'],'TotaltrialList');
    endText= 'Thank you for the participation!'
    Screen('TextSize',window, 50);
    [nx, ny, bbox] = DrawFormattedText(window, endText, 'center', 'center',[255 255 255], 50);
    Screen ('Flip', window);
    WaitSecs(1);
    %% Close screen
    Screen('CloseAll'); ShowCursor; fclose('all'); Priority(0);ListenChar(0);
    % End of experiment:
    return;
catch
    
    % Do same cleanup as at the end of a regular session...
    Screen('CloseAll'); ShowCursor; fclose('all'); Priority(0);ListenChar(0);
    
    % Output the error message that describes the error:
    psychrethrow(psychlasterror);
end