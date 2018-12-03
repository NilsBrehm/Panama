%% ANALYSIS PART ----------------------------------------------------------
% -------------------------------------------------------------------------
% Load Data
clear
clc
close all
base_path = '../../TEST/';

% Select single call audio file
[file,path] = uigetfile([base_path, '/*.wav'],'select a wav file');
open(fullfile(path,file))

load([path, file(1:end-4), '/samples.mat'])
samplingrate = 480 * 1000;

%% Choose analysis window
% disp(['min. pulse length: ', num2str(min(singlepulselength)), ' samples'])
% ---------------------------------
ms = 0.25; % estimate for pulse length in milliseconds
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

%% Cross Correlation
windowstart = 1;
windowend = length(pulses.active);

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
filename = [path, file(1:end-4), '/matrix_analysis'];
save([filename, '.mat'])
disp('Analysis done and data saved')

%% ========================================================================
%  ========================================================================
%[minMSE_FIT_raw, shift_FIT_raw] = shifted_MSE(FIT_a, FIT_p, 1, length(FIT_a));
%% PLOT MSE
imagesc(minMSE_AP);axis xy; 
c = colorbar; colormap(flipud(parula))
xlabel('Passive Pulse Number')
ylabel('Active Pulse Number')
xticks(1:1:noPulsesP)
yticks(1:1:noPulsesA)
c.Label.String = 'min. Mean Squared Error';

%% Find max freq
Amainfreqs = cell(1,size(pulses.active,2));
for i = 1:size(pulses.active,2)
x = pulses.active(:,i);
[ppx, f] = periodogram(x,rectwin(length(x)),length(x),samplingrate);
[vals, locs] = findpeaks(ppx, 'MinPeakDistance', 5);
plot(f,ppx)
hold on
plot(f(locs), ppx(locs), 'ro')
hold off
Amainfreqs{i} = f(locs);
text(median(f), median(ppx)+max(ppx)/2, num2str(i), 'Color', 'r')
pause(1)
end

Pmainfreqs = cell(1,size(pulses.passive,2));
for i = 1:size(pulses.passive,2)
x = pulses.passive(:,i);
[ppx, f] = periodogram(x,rectwin(length(x)),length(x),samplingrate);
[vals, locs] = findpeaks(ppx, 'MinPeakDistance', 5);
plot(f,ppx)
hold on
plot(f(locs), ppx(locs), 'ro')
hold off
Pmainfreqs{i} = f(locs);
text(median(f), median(ppx)+max(ppx)/2, num2str(i), 'Color', 'b')
pause(1)
end
%% Plot Difference in MainFreqs per Pulse
for i = 1:size(pulses.active,2)
    Add = round(diff(Amainfreqs{i}));
    if isempty(Add)
        continue
    end
    plot(i,Add(end),'ro')
    hold on
end
for i = 1:size(pulses.passive,2)
    Pdd = round(diff(Pmainfreqs{i}));
    if isempty(Pdd)
        continue
    end
    plot(i,Pdd(end),'bo')
    hold on
end
xticks(1:1:13)


%% ------------------------------------------------------------------------
% Save Data
save([filename, '.mat'])
disp('done')

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