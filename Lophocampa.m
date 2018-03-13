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

%%
clc
results = [];
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
    th = 7*std(x);
    [locs_ps, ~] = peakseek(x, mpd, th);
    figure()
    plot(x, 'k')
    hold on
    plot(locs_ps, x(locs_ps), 'mx', 'MarkerSize', 10)
    disp(length(locs_ps))
    
    currkey=0;
    % do not move on until enter key is pressed
    while currkey~=1
        pause; % wait for a keypress
        currkey=get(gcf,'CurrentKey');
        if strcmp(currkey, 'return')
            currkey=1;
        elseif strcmp(currkey, 'c')
            currkey=0;
            mpd = 100;
            th = 4*std(x);
            [locs_ps, ~] = peakseek(x, mpd, th);
            hold off
            plot(x, 'k')
            hold on
            plot(locs_ps, x(locs_ps), 'mx', 'MarkerSize', 10)
            disp(length(locs_ps))
        else
            currkey=0;
        end
    end
    close all
    
    % Find Active and Passive Pulses and detect pulse duration
    th_factor = .5 ; % th = th_factor * mad(pulse)
    limit = 20;
    filter_pulse = false;
    show = [true, true];
    method = 'raw';
    apriori = false; % assumption that first half is active and second is passive
    [samples, pulse_duration, freq, power] = activeorpassive(x, th_factor, locs_ps, fs, limit, filter_pulse, method, apriori, show);
    disp(['active ', num2str(length(samples.active))])
    disp(['passive ', num2str(length(samples.passive))])
    
    if isempty(samples.passive)
        disp('Only active pulses found')
        continue
    elseif isempty(samples.active)
        disp('Only passive pulses found')
        continue
    end
    
    % Detect Call Statistics
    Peak = [samples.active, samples.passive];
    phase = [zeros(1, length(samples.active)), ones(1, length(samples.passive))];
    
    IPIs = (diff(Peak)/samplingrate)*1000;
    
    % Plot marked pulses with their respective pulse length
    figure()
    plot(x)
    hold on
    for p = 1:length(Peak)
        plot(Peak(p):Peak(p)+pulse_duration(p), x(Peak(p):Peak(p)+pulse_duration(p)), 'r')
        hold on
    end
    hold off
    currkey=0;
    % do not move on until enter key is pressed
    while currkey~=1
        pause; % wait for a keypress
        currkey=get(gcf,'CurrentKey');
        if strcmp(currkey, 'return')
            currkey=1;
        else
            currkey=0;
        end
    end
    close all
    
    % Put all call statistics in one table
    record = convertCharsToStrings(recs{k});
    re = cell(length(Peak), 6);
    for q = 1:length(Peak)
        %call_stats = table(record, q, pulse_duration(q), freq(1), power(q), 'VariableNames', VarNames);
        %results = [results; call_stats];
        re{q, 1} = record;
        re{q, 2} = q;
        re{q, 3} = (pulse_duration(q)/fs)*1000;
        re{q, 4} = freq(q)/1000;
        re{q, 5} = power(q);
        re{q, 6} = phase(q);
    end
    
    results = [results; re];
    % save samples
    %     mkdir([path, file(1:end-4)]);
    %     filename = [path, file(1:end-4), '/', file(1:end-4)];
    %     save([filename, '_samples.mat'],'samples')
    %     disp('Samples saved')
    %
    clc
end

% Make Table
VarNames = {'Recording', 'PulseNr', 'Duration', 'Frequency', 'Power', 'Phase'};
T = cell2table(results, 'VariableNames', VarNames);

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
