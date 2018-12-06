%% MOTH PULSE DETECTION
% This script detects pulses and computes some simple statistics
% 
% Copyright Nils Brehm 2018

%%
rec_path = [pathname, '/'];

%%
clear
clc
close all
base_path = '../../DataForPaper/callseries/PP111_A82750026_480kHz_4sec/';
species = 'Carales_astur';
animal = 'PK1289';
recnr = 'Pk12890007';

rec_path = [base_path, species, '/', animal, '/', recnr, '/'];
rec_path = base_path;
%% Get names of recordings
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
add_to_left = false;
skip_pulses = false;
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

% Window for sampling rate
prompt = {'Audio Sampling Rate (kHz):'};
            dlg_title = 'Audio File Settings';
            num_lines = 1;
            defaultans = {num2str(480)};
            answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
            fs = str2double(answer{1})*1000;
            
clc
disp('Press "c" to enter correction mode')
disp('Press "z" to enter zoom mode')
disp('Press "p" show enlarged periodogram')
disp('Press "r" to redo active/passive detection')
disp('Press "n" to redo pulse detection')
disp('Press "enter" to continue')
disp('Press "ESC" to exit')

if crashed == 0
    results = [];
    call_stats = cell(length(recs), 2);
end
all_samples = cell(1, length(recs));
%for k = 1:length(recs)
% DEFAULT: k=1, if program crashed set k to crash point
k = 1;
while k <= length(recs)
    % Open data
    path_linux = [rec_path, recs{k}];
    [data, fs_data] = audioread(path_linux);
    
    % Filter Data
%     fs = fs_data;
    samplingrate = fs;
    
    if strcmp(filter_signal, 'on')
        x = bandpassfilter_data(data, 4000, 125*1000, 1, fs, true, true);
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
        prompt = {'Threshold Factor:','Limit Left:','Limit Right:','Envelope Threshold Factor', 'Sampling Rate'};
        dlg_title = 'Detection Settings';
        num_lines = 1;
        defaultans = {num2str(th_factor), num2str(limit_left), num2str(limit_right), num2str(env_th_factor), num2str(fs)};
        answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
        limit_left = str2double(answer{2});
        limit_right = str2double(answer{3});
        th_factor = str2double(answer{1});
        env_th_factor = str2double(answer{4});
        fs = str2double(answer{5});
        samplingrate = fs;
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
    
    % Save Call Stats as csv
    VarNames = {'Recording', 'PulseNr', 'Duration', 'Frequency','FreqMin',...
    'FreqMax', 'Power', 'Phase', 'PulseTime', 'PulseSample', 'IPI', 'CallDuration'};
    TT = cell2table(re, 'VariableNames', VarNames);
    % Save to csv
    writetable(TT,[rec_path, recs{k}(1:end-4), '/DescriptiveCallStatistics.csv'])
    
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
save([rec_path, 'complete_detection_analysis.mat'])

% Save to csv
writetable(T,[rec_path, 'DescriptiveCallStatistics.csv'])
disp('All Data Saved')

%% Error Handling: Use this when program crashed
clc
last_rec = recs{k};
disp('Program crashed:')
disp(['Set k to ', num2str(k), ' (', recs{k}, ')'])

%% When program crashed: Load all saved results.mat and combine them.
% rr = cell(1, length(recs));
% rr = [];
% for i = 1:length(recs)
%     pp = [rec_path, recs{i}(1:end-4)];
%     aa = struct2array(load([pp, '/results']));
%     rr = [rr; aa];
% end
% results = rr;
kk1 = 18;  % Point before crahs occured
kk2 = length(recs);  % Last recording
crash1 = struct2array(load([rec_path, recs{kk1}(1:end-4), '/results']));
crash2 = struct2array(load([rec_path, recs{kk2}(1:end-4), '/results']));
results = [crash1; crash2];

%% Ersatzbank
% Recs that were used as stimuli
% Only for my master thesis
% recs = {'BCI1062_07x07.wav',
%                  'aclytia_gynamorpha_24x24.wav',
%                  'agaraea_semivitrea_07x07.wav',
%                  'carales_12x12_01.wav',
%                  'chrostosoma_thoracicum_05x05.wav',
%                  'creatonotos_01x01.wav',
%                  'elysius_conspersus_11x11.wav',
%                  'epidesma_oceola_06x06.wav',
%                  'eucereon_appunctata_13x13.wav',
%                  'eucereon_hampsoni_11x11.wav',
%                  'eucereon_obscurum_14x14.wav',
%                  'gl005_11x11.wav',
%                  'gl116_05x05.wav',
%                  'hypocladia_militaris_09x09.wav',
%                  'idalu_fasciipuncta_05x05.wav',
%                  'idalus_daga_18x18.wav',
%                  'melese_12x12_01_PK1297.wav',
%                  'neritos_cotes_10x10.wav',
%                  'ormetica_contraria_peruviana_09x09.wav',
%                  'syntrichura_12x12.wav'};

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
