%% Get names of recordings
clear
clc
close all
% base_path = '/media/brehm/Data/Panama/DataForPaper/Lophocampa/';
base_path = '/media/brehm/Data/MasterMoth/stimuli/';
animal = 'moths';
species = 'callseries';
rec_path = [base_path, species, '/', animal, '/'];
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
filter_signal = 'on';
add_to_left = true;
skip_pulses = true;
crashed = 0;

% Default Peak Detection Parameters:
mpd = 100;
thf = 4;

% Default Pulse Detection Parameters:
th_factor = 1 ; % th = th_factor * mad(pulse)
limit_left = 40;
limit_right = 60;
env_th_factor = 1;

uiwait(helpdlg({'Press "c" to enter correction mode',...
    'Press "z" to enter zoom mode', ...
    'Press "p" show enlarged periodogram', ...
    'Press "enter" to continue', ...
    'Press "r" to go back', ...
    'Press "n" to redo pulse detection', ...
    'Press "ESC" to exit', ...
    '',...
    ['Filter is ', filter_signal]}, ...
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
all_samples = cell(1, length(recs));
%for k = 1:length(recs)
k = 1;
while k <= length(recs)
    % Open data
    path_linux = [rec_path, recs{k}];
    [data, ~] = audioread(path_linux);
    
    % Filter Data
    fs = 480 * 1000;
    samplingrate = fs;
    
    if strcmp(filter_signal, 'on')
        x = bandpassfilter_data(data, 4000, 150*1000, 1, fs, true, true);
    else
        % Only remove DC
        x = data - mean(data);
    end
    
    if add_to_left == true
        x = [zeros(500, 1); x];
    end
    
    % Parameters
    show_plot = true;
    
    % Find peaks in recording
    % x = [zeros(200, 1); x];
    th = thf*std(x);
    [locs_ps, ~] = peakseek(x, mpd, th);
    ff = figure(5);
    pos_fig = [1000 500 800 600];
    set(ff, 'Color', 'white', 'position', pos_fig)
    plot(x, 'k')
    hold on
    plot(locs_ps, x(locs_ps), 'mx', 'MarkerSize', 10)
    title(recs{k}, 'Interpreter', 'None')
    xlabel(['Found: ', num2str(length(locs_ps)), ' Pulses'])
    
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
            title(recs{k}, 'Interpreter', 'None')
            xlabel(['Found: ', num2str(length(locs_ps)), ' Pulses'])
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
    
    filter_pulse = false;
    if skip_pulses == true
        show = [false, true];
        prompt = {'Threshold Factor:','Limit Left:','Limit Right:','Envelope Threshold Factor'};
        dlg_title = 'Detection Settings';
        num_lines = 1;
        defaultans = {num2str(th_factor), num2str(limit_left), num2str(limit_right), num2str(env_th_factor)};
        answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
        limit_left = str2double(answer{2});
        limit_right = str2double(answer{3});
        th_factor = str2double(answer{1});
        env_th_factor = str2double(answer{4});
    else
        show = [true, true];
        th_factor = 0.4 ; % th = th_factor * mad(pulse)
        limit_left = 40;
        limit_right = 60;
        env_th_factor = 0.6;
        filter_pulse = false;
    end
    method = 'raw';
    apriori = false; % assumption that first half is active and second is passive
    [samples, pulse_duration, freq, freq_range, power] = activeorpassive(x, th_factor,...
        locs_ps, fs, limit_left, limit_right, env_th_factor, filter_pulse, method, apriori, show);
    
    redo_pulse_detection = questdlg('Continue or Redo?', ...
        'Recording finished', ...
        'Continue','Redo', 'Continue');
    
    %     % do not move on until enter key is pressed
    %     currkey=0;
    %     redo_pulse_detection = 0;
    %     while currkey~=1
    %         pause; % wait for a keypress
    %         currkey=get(gcf,'CurrentKey');
    %         if strcmp(currkey, 'return')
    %             currkey=1;
    %         elseif strcmp(currkey, 'n') % Jump back to pulse detection
    %             redo_pulse_detection = 1;
    %             disp('Redo pulse detection')
    %             currkey=1;
    %         elseif strcmp(currkey, 'escape')
    %             disp('Exit Program')
    %             close all
    %             return
    %         else
    %             currkey=0;
    %         end
    %     end
    
    if strcmp(redo_pulse_detection, 'Redo')
        continue
    end
    
    if isempty(samples)
        k = k+1;
        continue
    end
    if isempty(samples.passive)
        disp([recs{k} ,': Only active pulses found'])
        %continue
    elseif isempty(samples.active)
        disp([recs{k} ,': Only passive pulses found'])
        %continue
    end
    
    % Detect Call Statistics
    Peak = sort([samples.active, samples.passive]);
    all_samples{k} = Peak;
    phase = [zeros(1, length(samples.active)), ones(1, length(samples.passive))];
    
    IPIs = (diff(Peak)/samplingrate)*1000;
    
    % Put all call statistics in one table
    % Record Name | pulse number | duration | Freq | Freq Min | Freq Max | Power | Phase | Pulse Time | Sample | IPI | CallDur
    record = convertCharsToStrings(recs{k});
    re = cell(length(Peak), 12);
    for q = 1:length(Peak)
        %call_stats = table(record, q, pulse_duration(q), freq(1), power(q), 'VariableNames', VarNames);
        %results = [results; call_stats];
        re{q, 1} = record;
        re{q, 2} = q;
        re{q, 3} = (pulse_duration(q)/fs)*1000;
        re{q, 4} = freq(q)/1000;
        re{q, 5} = freq_range(q, 1);
        re{q, 6} = freq_range(q, 2);
        re{q, 7} = power(q);
        re{q, 8} = phase(q);
        re{q, 9} = (Peak(q) / fs) * 1000;
        re{q, 10} = Peak(q);
        if q == length(Peak)
            re{q, 11} = 0;
            re{q, 12} = (abs(min(Peak)-max(Peak)) / fs) * 1000;
        else
            re{q, 11} = ((abs(Peak(q) - Peak(q+1))) / fs) * 1000;
            re{q, 12} = 0;
        end
    end
    
    results = [results; re];
    call_stats{k, 1} = record;
    call_stats{k, 2} = abs(min(Peak)-max(Peak))/fs;
    
    % Make Backup after every record is finished
    mkdir([rec_path, recs{k}(1:end-4), '/']);
    save([rec_path, recs{k}(1:end-4), '/results.mat'], 'results')
    save([rec_path, recs{k}(1:end-4), '/call_stats.mat'], 'call_stats')
    save([rec_path, recs{k}(1:end-4), '/samples.mat'], 'samples')
    
    disp([recs{k}, ' done'])
    k = k+1;
end

disp('All Done')
close all
%% Make Table
VarNames = {'Recording', 'PulseNr', 'Duration', 'Frequency','FreqMin',...
    'FreqMax', 'Power', 'Phase', 'PulseTime', 'PulseSample', 'IPI', 'CallDuration'};
T = cell2table(results, 'VariableNames', VarNames);

% Save all
save([rec_path, 'complete_analysis.mat'])

% Save to csv
writetable(T,[rec_path, 'results.csv'])
disp('All Data Saved')

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
