%% ANALYSIS PART ----------------------------------------------------------
% This script computes pulse by pulse comparison

% Copyright Nils Brehm 2018
% -------------------------------------------------------------------------
% Load Data
% Import data path name
bb = importdata('datapath.txt');
base_path = bb{1};

prompt = {'Recording Number:', 'Call Number:', 'Sampling Rate (kHz):', ...
    'Run Plotting (1=On):'};
dlg_title = 'Select Recording and Call';
num_lines = 1;
try
    defaultans = {num2str(rec_nr), num2str(call_nr+1), num2str(480), num2str(1)};
catch
    defaultans = {num2str(1), num2str(1), num2str(480), num2str(1)};
end
answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
rec_nr = str2double(answer{1});
call_nr = str2double(answer{2});
samplingrate = str2double(answer{3}) * 1000;
run_plotting = str2double(answer{4});
list = dir([base_path, '*.wav']);
rec_path = [base_path, list(rec_nr).name(1:end-4), '/'];

clc
% Get names of recordings
listing = dir([rec_path, '*.wav']);
recs = cell(1, length(listing));
for i = 1:length(listing)
    recs{1, i} = listing(i).name;
end

% Load Data
try
    load([rec_path, 'call_nr_', num2str(call_nr), '/samples.mat'])
    [data, fs] = audioread([rec_path, 'call_nr_', num2str(call_nr), '.wav']);
catch
    disp('Cannot find data!')
    exit();
end

% Choose analysis window
clc
% disp(['min. pulse length: ', num2str(min(singlepulselength)), ' samples'])
% ---------------------------------
ms = 0.2; % estimate for pulse length in milliseconds
start = -0.02; % start of pulse relative to peak detection in milliseconds
% ---------------------------------
pulsewindowstart = round((start/1000)*samplingrate);
pulsewindowend = round((ms/1000)*samplingrate);
baseline = 5;  % Is used to align y values to zero (offset)

% !!! SET CORRECT SAMPLING RATE !!! --------------------------------------
% samplingrate = 480 * 1000;
disp(['Used Sampling Rate: ', num2str(samplingrate/1000), ' kHz'])

% =========================================================================
% =========================================================================
% Run Analysis Script:Cut out single pulses from recording
[time, pulses, envs, phas, repulses, reenvs, rephas] = ...
    CutOutPulses(data, samples, pulsewindowstart,...
    pulsewindowend, baseline, samplingrate);

noPulsesA = size(samples.active,2);
noPulsesP = size(samples.passive,2);
noPulses = max([noPulsesA, noPulsesP]);

% Plot Raw Pulses to determine analysis window
figure('units','normalized','outerposition',[0 0.5 1 0.5]);
plot_stuff(time, pulses.active, pulses.passive)
disp(['Active Pulses: ', num2str(noPulsesA)])
disp(['Passive Pulses: ', num2str(noPulsesP)])
disp("Press 'ENTER' to continue")
currkey = 0;
start_analysis = 0;

while currkey ~= 1
    pause('on');
    pause;
    currkey = get(gcf,'CurrentKey');
    if strcmp(currkey, 'escape')
        currkey = 1;
        disp('Do you want to adjust analysis window?')
        close all
    end
    if strcmp(currkey, 'return')
        currkey = 1;
        start_analysis = 1;
        disp('Pulse to Pulse Analysis started')
        close all
    end
end

% Cross Correlation
if start_analysis == 1
    windowstart = 1;
    % sz_a = size(pulses.active);
    % sz_p = size(pulses.passive);
    % windowend = min([sz_a(1), sz_p(1)]);
    windowend = pulsewindowend;
    [ccAP, MaxCorr_AP, BestLag_AP] = crosscorr(pulses.active, pulses.passive, windowstart, windowend, 'coeff');
    [ccAA, MaxCorr_AA, BestLag_AA] = crosscorr(pulses.active, pulses.active, windowstart, windowend, 'coeff');
    [ccPP, MaxCorr_PP, BestLag_PP] = crosscorr(pulses.passive, pulses.passive, windowstart, windowend, 'coeff');

    % Shifted MSE
    [minMSE_AP, shift_AP] = shifted_MSE(pulses.active, -pulses.passive, windowstart, windowend);
    [minMSE_AA, shift_AA] = shifted_MSE(pulses.active, pulses.active, windowstart, windowend);
    [minMSE_PP, shift_PP] = shifted_MSE(pulses.passive, pulses.passive, windowstart, windowend);

    % %not normalized:
    % [ccAP, MaxCorr_AP, BestLag_AP] = crosscorr(pulses.active, pulses.passive, windowstart, windowend, 'unbiased');
    % [ccAA, MaxCorr_AA, BestLag_AA] = crosscorr(pulses.active, pulses.active, windowstart, windowend, 'unbiased');
    % [ccPP, MaxCorr_PP, BestLag_PP] = crosscorr(pulses.passive, pulses.passive, windowstart, windowend, 'unbiased');

    % [crosscorrelation_FIT_raw, MaxCorr_FIT_raw, BestLag_FIT_raw] = crosscorr(FIT_a, FIT_p, 1, length(FIT_a), 'coeff');
    % [crosscorrelation_envs, MaxCorr_envs, BestLag_envs] = crosscorr(E1, E2, windowstart, windowend, 'coeff');
    %[crosscorrelation_spc, MaxCorr_spc, BestLag_spc] = crosscorr(specpulses.active, specpulses.passive, windowstart, windowend, 'coeff');

    % specpulses.active = abs(fft(pulses.active)); specpulses.active = specpulses.active(1:60,:);
    % specpulses.passive = abs(fft(pulses.passive)); specpulses.passive = specpulses.passive(1:60,:);
    % [crosscorrelation_spc, MaxCorr_spc, BestLag_spc] = crosscorr(specpulses.active, specpulses.passive, windowstart, 60, 'coeff');

    % Save Data
    filename = [rec_path, 'call_nr_', num2str(call_nr), '/matrix_analysis'];
    save([filename, '.mat'])
    disp('Analysis done and data saved')
    
    % Start Plotting Script
    if run_plotting == 1
        disp('-- STARTING PLOTTING SCRIPT -----------------')
        run('Plotting.m')
    end
    run('PulseAnalysis.m')
end

%% ========================================================================
%  ========================================================================
% %[minMSE_FIT_raw, shift_FIT_raw] = shifted_MSE(FIT_a, FIT_p, 1, length(FIT_a));
% %% PLOT MSE
% imagesc(minMSE_AP);axis xy; 
% c = colorbar; colormap(flipud(parula))
% xlabel('Passive Pulse Number')
% ylabel('Active Pulse Number')
% xticks(1:1:noPulsesP)
% yticks(1:1:noPulsesA)
% c.Label.String = 'min. Mean Squared Error';
% 
% %% Find max freq
% Amainfreqs = cell(1,size(pulses.active,2));
% for i = 1:size(pulses.active,2)
% x = pulses.active(:,i);
% [ppx, f] = periodogram(x,rectwin(length(x)),length(x),samplingrate);
% [vals, locs] = findpeaks(ppx, 'MinPeakDistance', 5);
% plot(f,ppx)
% hold on
% plot(f(locs), ppx(locs), 'ro')
% hold off
% Amainfreqs{i} = f(locs);
% text(median(f), median(ppx)+max(ppx)/2, num2str(i), 'Color', 'r')
% pause(1)
% end
% 
% Pmainfreqs = cell(1,size(pulses.passive,2));
% for i = 1:size(pulses.passive,2)
% x = pulses.passive(:,i);
% [ppx, f] = periodogram(x,rectwin(length(x)),length(x),samplingrate);
% [vals, locs] = findpeaks(ppx, 'MinPeakDistance', 5);
% plot(f,ppx)
% hold on
% plot(f(locs), ppx(locs), 'ro')
% hold off
% Pmainfreqs{i} = f(locs);
% text(median(f), median(ppx)+max(ppx)/2, num2str(i), 'Color', 'b')
% pause(1)
% end
% %% Plot Difference in MainFreqs per Pulse
% for i = 1:size(pulses.active,2)
%     Add = round(diff(Amainfreqs{i}));
%     if isempty(Add)
%         continue
%     end
%     plot(i,Add(end),'ro')
%     hold on
% end
% for i = 1:size(pulses.passive,2)
%     Pdd = round(diff(Pmainfreqs{i}));
%     if isempty(Pdd)
%         continue
%     end
%     plot(i,Pdd(end),'bo')
%     hold on
% end
% xticks(1:1:13)
% 
% 
% %% ------------------------------------------------------------------------
% % Save Data
% save([filename, '.mat'])
% disp('done')

%% ========================================================================
% ++++ JUNKYARD +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% %% Define what you want to compare:
% compare_what = 'AvsP';
% 
% if strcmp(compare_what, 'AvsP')
%     pulses.active = pulses.active;
%     pulses.passive = pulses.passive;
%     E1 = envs.active;
%     E2 = envs.passive;
%     PH1 = phas.active;
%     PH2 = phas.passive;
%     labely = 'Active #';
%     labelx = 'Passive #';
%     disp('Comparison Mode: AvsP selected')
% elseif strcmp(compare_what, 'AvsA')
%     pulses.active = pulses.active;
%     pulses.passive = pulses.active;
%     E1 = envs.active;
%     E2 = E1;
%     PH1 = phas.active;
%     PH2 = PH1;
%     labely = 'Active #';
%     labelx = 'Active #';
%     disp('Comparison Mode: AvsA selected')
% elseif strcmp(compare_what, 'PvsP')
%     pulses.passive = pulses.passive;
%     pulses.active = pulses.passive;
%     E2 = envs.passive;
%     E1 = E2;
%     PH2 = phas.passive;
%     PH1 = PH2;
%     labely = 'Passive #';
%     labelx = 'Passive #';
%     disp('Comparison Mode: PvsP selected')
% else
%     error('Comparison Mode is not available: Use either "AvsP", "AvsA" or "PvsP"')
% end
% 
% mkdir([path, file(1:end-4),'/',compare_what]);
% filename1 = [path, file(1:end-4),'/',compare_what, '/', file(1:end-4)];
% filename = [path, file(1:end-4),'/',compare_what, '/'];
% 
% % windowstart = 1;
% % windowend = length(pulses.active);