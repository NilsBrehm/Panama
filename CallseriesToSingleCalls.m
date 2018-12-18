%% Callseries To Single Calls
% This script converts call series to single calls
% Single calls must be cut out manually
% 
% Copyright Nils Brehm 2018

%% ========================================================================
% CHECK ALL RECORDINGS IN DIRECTORY AND LABEL THEM AS GOOD AND BAD
% -------------------------------------------------------------------------

% Open data
clear
clc
close all

base_path = '../../Recordings/Carales_astur/PK1285/';
list = dir(base_path);
samplingrate = 480 * 1000;
% 
% [file,path] = uigetfile([base_path, '/*.wav'],'select a wav file');
% open(fullfile(path,file))
% 
% samplingrate = 480 * 1000;

bad_recs_idx = [];
good_recs_idx = [];
test = [];
recs = cell(length(list)-2, 3);
for k = 3:length(list) 
    rec_path = [base_path, list(k).name];
    [wav, fs] = audioread(rec_path);
    recs{k-2, 1} = list(k).name;
    recs{k-2, 3} = rec_path;
    plot(wav)
    currkey = 0;
    breakkey = 0;
    % do not move on until enter key is pressed
    while currkey~=1
        pause; % wait for a keypress
        currkey=get(gcf,'CurrentKey');
        if strcmp(currkey, 'space')
            currkey = 1;
            recs{k-2, 2} = 'bad';
            disp([list(k).name, ' rejected', [' (', rec_path, ')']])
        end
        if strcmp(currkey, 'return')
            currkey = 1;
            recs{k-2, 2} = 'good';
            disp([list(k).name, ' accepted', [' (', rec_path, ')']])
        end
        
        % Exit program
        if strcmp(currkey, 'escape')
            currkey = 1;
            breakkey = 1;
        end
    end
    % Exit program
    if breakkey == 1
        disp('Program closed!')
        close all
        break
    end
end
close all

% Save as csv
VarNames = {'Recording', 'Quality', 'Path'};
TT= cell2table(recs, 'VariableNames', VarNames);
writetable(TT,[base_path, 'Recordings.csv']);
save([base_path, 'recordings.mat'], 'recs')
disp('Done')

%% ========================================================================
% CUT OUT SINGLE CALLS AND SAVE THEM AS SINGLE WAV FILES =================
% ------------------------------------------------------------------------
% [file, path] = uigetfile([base_path, '/*.wav'],'select a wav file');
% open(fullfile(path,file))
aa = exist('rec_nr');
if aa == 1
    clearvars -except rec_nr
else
    clear
    rec_nr = 0;
end
clc
close all

prompt = {'Recording Number:'};
dlg_title = 'Select Recording';
num_lines = 1;
defaultans = {num2str(rec_nr+1)};
answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
rec_nr = str2double(answer{1});


disp('-- Use space to start cutting out a new call --')
disp('-- First click: Call starting point --')
disp('-- Second click: Call ending point --')
disp('-- Press ENTER or ESC to end program --')

base_path = '../../Recordings/Carales_astur/PK1285/';
list = dir(base_path);

load([base_path, 'recordings.mat'])
% rec_nr = 2;
% get the good recordings
idx = strcmp(recs(:, 2), 'good');
good_recs = recs(idx);
pp = [base_path, good_recs{rec_nr}];
[data, fs] = audioread(pp);

samplingrate = 480 * 1000;
disp(['Recording: ', good_recs{rec_nr}, ' has been selected! (nr. ', num2str(rec_nr), ')'])

jj = 1;
figure('units','normalized','position',[0 0 1 1])
plot(data, 'k')
title(good_recs{rec_nr})
xlabel([num2str(jj-1),' calls already cutted'])
% [x, y, w, h]
dim = [0.15 0.1 0.2 0.2];

str = {"-- Use 'space' to start cutting out a new call --", ...
    "-- First 'click': Call starting point --", ...
    "-- Second 'click': Call ending point --", ...
    "-- Press 'BACKSPACE' to undo cutting --", ...
    "-- Press 'ENTER' or 'ESC' to end program --"};

annotation('textbox',dim,'String',str,'FitBoxToText','on', 'color', 'red');

currkey = 0;
call_pos = {};
while currkey ~=1
    pause('on');
    pause;
    currkey = get(gcf,'CurrentKey');
    if strcmp(currkey, 'space')
        disp('Plese select start and end point of call')
        [px, ~, ~] =  ginput(2);
        call_pos{jj} = round(px);
        
        % Update plot
%         title(good_recs{rec_nr})
        xlabel([num2str(jj),' call(s) already cutted'])
        hold on
        plot(call_pos{jj}(1):call_pos{jj}(2), data(call_pos{jj}(1):call_pos{jj}(2)))
        jj = jj +1;
    end
    if strcmp(currkey, 'return')
        disp('Finished cutting calls!')
        currkey = 1;
        close all
    end
    if strcmp(currkey, 'escape')
        disp('Cutting calls stopped!')
        currkey = 1;
        close all
    end
    if strcmp(currkey, 'backspace')
        jj = jj -1;
        hold on
        plot(call_pos{jj}(1):call_pos{jj}(2), data(call_pos{jj}(1):call_pos{jj}(2)), 'k')
    end
end

% Remoce potential left overs from redo option
call_pos = call_pos(1:jj-1);

% Start decomposing?
answer = questdlg('Would you like to save all single calls?', ...
	'Save', ...
	'Yes', 'Cancel','Yes');
% Handle response
switch answer
    case 'Yes'
        % Decompose the recording into single calls
        call_path = [base_path, good_recs{rec_nr}(1:end-4), '/'];
        mkdir(call_path);
        for k = 1:length(call_pos)
            callaudio = data(call_pos{k}(1):call_pos{k}(2));
            audiowrite([call_path, 'call_nr_', num2str(k),'.wav'], ...
                callaudio, samplingrate)
        end
        disp([num2str(length(call_pos)),' call(s) saved'])
    case 'Cancel'
        rec_nr = rec_nr-1;
        disp('Canceled, nothing was saved!')
end



%% JUNKYARD ---------------------------------------------------------------
% %% Decompose the recording into single calls
% variablesInCurrentWorkspace = who;
% no_callstarts = sum(strncmp('cs',variablesInCurrentWorkspace, 2));
% no_callends = sum(strncmp('ce',variablesInCurrentWorkspace, 2));
% callstarts = [];
% callends = [];
% for i = 1:no_callstarts
%     aa = "callstarts = [callstarts, cs" +  num2str(i) + ".DataIndex]";
%     eval(aa);
%     bb = "callends = [callends, ce" +  num2str(i) + ".DataIndex]";
%     eval(bb);
% end
% clc
% 
% %% Save Single Calls as wave files
% pathname = [path, file(1:end-4)];
% mkdir(pathname);
% for i = 1:length(callstarts)
%     callaudio = data(callstarts(i):callends(i));
%     audiowrite([pathname, '/call_nr_', num2str(i),'.wav'],callaudio,samplingrate)
% end
% disp('single call audio saved')