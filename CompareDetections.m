%% Compare detection methods
%% Open data
clear
clc
close all

path_linux = '/media/brehm/Data/MasterMoth/stimuli/naturalmothcalls/';
path_windows = 'D:\Masterarbeit\PanamaProject\DataForPaper\';

[file,path] = uigetfile([path_linux, '*.wav'],'select a wav file');
open(fullfile(path,file))

%% Filter Data
y = [zeros(200, 1); data];
x = bandpassfilter_data(y, 5000, 150*1000, 4, fs, true, true);

% Parameters
show_plot = true;
mpd = 20;
th = std(x);
method = 'rms';
window = 200;

%% Detection Methods
%% Spectral
% Detection lies between start and first peak of pulse. Only peak detection
% and no discrimination between active and passive pulses.
% Parameters: 1 (Min Peak Distance of spectral power peaks (n))
% Thresholding: automatic: 2*mad(n);
mpd = 20;
locs_spec = find_peaks_spec(x, fs, mpd, false);
if show_plot
    plot(x, 'k');hold on; plot(locs_spec, x(locs_spec), 'go')
    disp(file)
    disp(['pulses ', num2str(length(locs_spec))])
end

%% findpeaks() and peakseek() on raw data
% Both give equal results. They detect the max. peak in the pulse and not
% the first peak or the start of the pulse. Only peak detection and no
% discrimination between active and passive pulses.
% Parameters: 1 (Min Peak Distance ~= Estimate of Pulse Duration)
% Thresholding: automatic: std(signal)
clc
mpd = 150;
th = std(x);
[~, locs_fp] = findpeaks(x, 'MinPeakHeight', th, 'MinPeakDistance', mpd);
[locs_ps, ~] = peakseek(x, mpd, th);

if show_plot
    plot(x, 'k');hold on; 
    plot(locs_fp, x(locs_fp), 'go', 'MarkerSize', 8); hold on;
    plot(locs_ps, x(locs_ps), 'yx', 'MarkerSize', 8);
    legend('data', 'findpeaks()', 'peakseek()')
    disp(file)
    disp(['pulses findpeaks(): ', num2str(length(locs_fp))])
    disp(['pulses peakseek(): ', num2str(length(locs_ps))])
end

%% Envelope (method: analytic or rms)
% Detection for rms_diff: on the left flank of first pulse.
% Detection for rms: somewhere in the center of the pulse.
% AorP: Looks if the detection point is positive or negative.
% Issue: peak env and peak env diff must have the same size to be able to
% discriminate between active and passive!

clc
method = 'rms';
window = 20;
mpd = 200;
[locs_env, locs_env_diff, samples_env] = find_peaks_env(x, mpd, method, window, true);
if show_plot
    figure()
    plot(x, 'k');hold on; 
    plot(locs_env, x(locs_env), 'go', 'MarkerSize', 8); hold on
    plot(locs_env_diff, x(locs_env_diff), 'mx', 'MarkerSize', 8)
    hold on
    plot(samples_env.active, x(samples_env.active), 'ro', 'MarkerSize', 10)
    hold on
    plot(samples_env.passive, x(samples_env.passive), 'bo', 'MarkerSize', 10)
    legend('data', 'env', 'env dt', 'active', 'passive')
    disp(file)
    disp(['active: ', num2str(length(samples_env.active))])
    disp(['passive: ', num2str(length(samples_env.passive))])
end

%% FindPulsesAlgo
clc
th_a = 0.1;
th_p = 0.007;
mpd = 100;
[locs_fpa, samples_fpa] = findpulsesalgo(x, th_a, th_p, mpd, false);
if show_plot
    plot(x, 'k');hold on; plot(locs_fpa, x(locs_fpa), 'mo')
    hold on
    plot([1, length(x)], [th_a, th_a], 'r--')
    hold on
    plot([1, length(x)], [-th_p, -th_p], 'b--')
    disp(file)
    disp(['pulses ', num2str(length(locs_fpa))])
end

%% Template Cross Correlation
% template parameters:
pulse_length = 0.2;
tau = 0.1;
frequency = 50;
mpd = 100;
th = 0.4;
[locs_temp, ~, ~, r, ~, template] = TemplatePeaks(data ,fs,...
    pulse_length, frequency, tau, th, mpd, 0);
if show_plot
    figure()
    plot(x, 'k');hold on; plot(locs_temp, x(locs_temp), 'mo')
    figure()
    plot(r)
    disp(file)
    disp(['pulses ', num2str(length(locs_temp))])
end

%% ThresholdingAlgo
cutrec = 0.1*fs; % = 100 ms in samples
xx = x;
xx(end-cutrec:end) = [];
lag = 20;
th_tha = 7; % in x times std
influence = 0.5;
[signals,avgFilter,stdFilter] = ThresholdingAlgo(xx,lag,th_tha,influence, 'mean');
peaks = diff(signals);


% Find Peaks in diff(signal) and take the first one in time
p = find(peaks == 1);
p = [0 ;p];
dummy = diff(p);
locs_tha = p(find(dummy>20)+1);

% Plot
if show_plot
    figure()
    plot(xx, 'k'); hold on; plot(locs_tha, xx(locs_tha), 'ro')
    figure()
    plot(xx, 'k'); hold on; plot(avgFilter, 'r'); hold on;
    plot(avgFilter+stdFilter, 'r--'); hold on; plot(avgFilter-stdFilter, 'r--');
    hold on; plot(signals, 'g'); hold on; plot(diff(signals), 'b--')
end

%% Automatic Multiscale-based Peak Detection
sg = downsample(xx,2);
peaks_pos = ampd(sg);
peaks_neg = ampd(-sg);

% Look for the first peak and remove all the others
th_ampd = 2*mad(sg);
th_diff = 40;

peaks_pos(sg(peaks_pos) < th_ampd) = [];
peaks_neg(sg(peaks_neg) > -th_ampd) = [];
pp_backup_pos = peaks_pos;
pp_backup_neg = peaks_neg;
peaks_pos = [0, peaks_pos];
peaks_neg = [0, peaks_neg];

pp_diff_pos = diff(peaks_pos);
pp_diff_neg = diff(peaks_neg);
locs_ampd_pos = peaks_pos(find(pp_diff_pos>th_diff)+1);
locs_ampd_neg = peaks_neg(find(pp_diff_neg>th_diff)+1);

% Acitve or Passive?
avsp = locs_ampd_pos - locs_ampd_neg;
samples.active = locs_ampd_pos(avsp < 0);
samples.passive = locs_ampd_neg(avsp > 0);

% Plot
if show_plot
    figure()
    plot(sg, 'k'); hold on;
    plot(locs_ampd_pos, sg(locs_ampd_pos), 'ro', 'MarkerSize', 8); hold on;
    plot(pp_backup_pos, sg(pp_backup_pos), 'rx'); hold on;
    scatter(samples.active, sg(samples.active), 'ro', 'filled')
    hold on
    plot(locs_ampd_neg, sg(locs_ampd_neg), 'bo', 'MarkerSize', 8); hold on;
    plot(pp_backup_neg, sg(pp_backup_neg), 'bx'); hold on;
    scatter(samples.passive, sg(samples.passive), 'bo', 'filled')
end
