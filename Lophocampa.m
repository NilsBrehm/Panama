%% Get names of recordings
clear
clc
close all
rec_path = '/media/brehm/Data/Panama/DataForPaper/Lophocampa/8016/X51241 m (N=28)/';
listing = dir(rec_path);
recs = {};
count = 1;
for i = 3:length(listing)
    if strcmp(listing(i).name(end-2:end), 'wav')
        recs{count} = listing(i).name;
        count = count + 1;
    end
end

%% Start Detection
crashed = 0;
uiwait(helpdlg({'Press "c" to enter correction mode',...
        'Press "z" to enter zoom mode', ...
        'Press "p" show enlarged periodogram', ...
        'Press "enter" to continue', ...
        'Press "ESC" to exit'}, ...
        'Welcome to the Pulse Detection Tool'));
clc
disp('Press "c" to enter correction mode')
disp('Press "z" to enter zoom mode')
disp('Press "p" show enlarged periodogram')
disp('Press "enter" to continue')
disp('Press "ESC" to exit')

if crashed == 0
    results = [];
    call_stats = cell(length(recs), 2);
end
for k = 1:length(recs)
    % Open data
    path_linux = [rec_path, recs{k}];
    [data, ~] = audioread(path_linux);
    
    % Filter Data
    fs = 480 * 1000;
    samplingrate = fs;
    x = bandpassfilter_data(data, 4000, 150*1000, 2, fs, true, true);
    % Parameters
    show_plot = true;
    
    % Find peaks in recording
    % x = [zeros(200, 1); x];
    mpd = 100;
    thf = 7;
    th = thf*std(x);
    [locs_ps, ~] = peakseek(x, mpd, th);
    ff = figure(5);
    pos_fig = [1000 500 800 600];
    set(ff, 'Color', 'white', 'position', pos_fig)
    plot(x, 'k')
    hold on
    plot(locs_ps, x(locs_ps), 'mx', 'MarkerSize', 10)
    title(recs{k}, 'Interpreter', 'None')
    
    currkey=0;
    % do not move on until enter key is pressed
    while currkey~=1
        pause; % wait for a keypress
        currkey=get(gcf,'CurrentKey');
        if strcmp(currkey, 'return')
            currkey=1;
        elseif strcmp(currkey, 'c')
            currkey=0;
            prompt = {'threshold factor:','min peak distance:'};
            dlg_title = 'Pulse Detection Settings';
            num_lines = 1;
            defaultans = {num2str(thf), num2str(mpd)};
            answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
            thf = str2double(answer{1});
            mpd = str2double(answer{2});
            th = thf*std(x);
            [locs_ps, ~] = peakseek(x, mpd, th);
            hold off
            plot(x, 'k')
            hold on
            plot(locs_ps, x(locs_ps), 'mx', 'MarkerSize', 10)
        elseif strcmp(currkey, 'escape')
            disp('Exit Program')
            close all
            return
        else
            currkey=0;
        end
    end
    % close all
    
    % Find Active and Passive Pulses and detect pulse duration
    th_factor = .5 ; % th = th_factor * mad(pulse)
    limit_left = 20;
    limit_right = 20;
    env_th_factor = 1;
    filter_pulse = false;
    show = [true, true];
    method = 'raw';
    apriori = false; % assumption that first half is active and second is passive
    [samples, pulse_duration, freq, power] = activeorpassive(x, th_factor,...
        locs_ps, fs, limit_left, limit_right, env_th_factor, filter_pulse, method, apriori, show);
%     disp(['active ', num2str(length(samples.active))])
%     disp(['passive ', num2str(length(samples.passive))])
    if isempty(samples)
        return
    end
    if isempty(samples.passive)
        disp([recs{k} ,': Only active pulses found'])
        continue
    elseif isempty(samples.active)
        disp([recs{k} ,': Only passive pulses found'])
        continue
    end
    
    % Detect Call Statistics
    Peak = [samples.active, samples.passive];
    phase = [zeros(1, length(samples.active)), ones(1, length(samples.passive))];
    
    IPIs = (diff(Peak)/samplingrate)*1000;
    
%     % Plot marked pulses with their respective pulse length
%     figure()
%     plot(x)
%     hold on
%     for p = 1:length(Peak)
%         plot(Peak(p):Peak(p)+pulse_duration(p), x(Peak(p):Peak(p)+pulse_duration(p)), 'r')
%         hold on
%     end
%     hold off
%     currkey=0;
%     % do not move on until enter key is pressed
%     while currkey~=1
%         pause; % wait for a keypress
%         currkey=get(gcf,'CurrentKey');
%         if strcmp(currkey, 'return')
%             currkey=1;
%         else
%             currkey=0;
%         end
%     end
%     close all
    
    % Put all call statistics in one table
    record = convertCharsToStrings(recs{k});
    re = cell(length(Peak), 8);
    for q = 1:length(Peak)
        %call_stats = table(record, q, pulse_duration(q), freq(1), power(q), 'VariableNames', VarNames);
        %results = [results; call_stats];
        re{q, 1} = record;
        re{q, 2} = q;
        re{q, 3} = (pulse_duration(q)/fs)*1000;
        re{q, 4} = freq(q)/1000;
        re{q, 5} = power(q);
        re{q, 6} = phase(q);
        re{q, 7} = (Peak(q) / fs) * 1000;
        re{q, 8} = Peak(q);
    end
    
    results = [results; re];
    call_stats{k, 1} = record;
    call_stats{k, 2} = abs(min(Peak)-max(Peak))/fs;
    
    % Make Backup after every record is finished
    save([rec_path , 'results.mat'], 'results')
    save([rec_path , 'call_stats.mat'], 'call_stats')
    
    disp([recs{k}, ' done'])
end

% Make Table
VarNames = {'Recording', 'PulseNr', 'Duration', 'Frequency', 'Power', 'Phase'};
T = cell2table(results, 'VariableNames', VarNames);

%% Compute Intervals
for j = 1:length(recs)
    ids = find([results{:, 1}] == recs{j});
    pulse_number = length(ids);
    durs = results{ids, 3};
    cdur = call_stats{ids, 2};
end

%% Error Handling
clc
last_rec = recs{k};
disp('Program crashed:')
disp(['Set k to ', num2str(k), ' (', recs{k}, ')'])

%% Ersatzbank
% %% Open data
% clear
% clc
% close all
%
% path_linux = '/media/brehm/Data/MasterMoth/stimuli/naturalmothcalls/';
% path_windows = 'D:\Masterarbeit\PanamaProject\DataForPaper\';
%
% [file,path] = uigetfile([path_linux, '*.wav'],'select a wav file');
% open(fullfile(path,file))
