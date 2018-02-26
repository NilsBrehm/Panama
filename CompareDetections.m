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
clc
fs = 480 * 1000;
y = [zeros(200, 1); data];
x = bandpassfilter_data(y, 4000, 200*1000, 4, fs, true, true);

% Parameters
show_plot = true;

%% Detection Methods
%% Spectral
% Detection lies between start and first peak of pulse. Only peak detection
% and no discrimination between active and passive pulses.
% Parameters: 1 (Min Peak Distance of spectral power peaks (n))
% Thresholding: automatic: th*mad(n);
clc
th = 20;
mpd = 10;
locs_spec = find_peaks_spec(x, fs, mpd, th, false);
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
mpd = 40;
th = 4*std(x);
[~, locs_fp] = findpeaks(x, 'MinPeakHeight', th, 'MinPeakDistance', mpd);
[locs_ps, ~] = peakseek(x, mpd, th);

if show_plot
    plot(x, 'k');hold on; 
    plot(locs_fp, x(locs_fp), 'go', 'MarkerSize', 8); hold on;
    plot(locs_ps, x(locs_ps), 'mx', 'MarkerSize', 8);
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
window = 2;
mpd = 500;
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
% My first one.
clc
th_a = 0.1;
th_p = 0.1;
mpd = 80;
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
% Uses a template model pulse to find pulses. The template is cross
% correlated with the recording. This reduces noise and increses signal to
% noise ratio. Peaks in the cross correlation function are found using 
% findpeaks(). A second template which is in anti-phase to the first one is
% used to discriminate between active and passive pulses. Peaks in the
% cross correlation function for signal and template with the same phase
% are usually larger.
% Pulses are deteced somewhere in the first half of the pulse.
% Parameters: 
% - Template length, tau and frequency
% - Peak detection: MinPeakDistance and Threshold
clc
pulse_length = .5;
tau = 0.1;
frequency = 50;
mpd = 100;
th = 0.01;
[locs_temp, samples_temp, r, ~, template] = TemplatePeaks(x ,fs/1000,...
    pulse_length, frequency, tau, th, mpd, 0, true);
if show_plot
    figure()
    plot(x, 'k');hold on; 
    plot(samples_temp.active, x(samples_temp.active), 'ro'); hold on;
    plot(samples_temp.passive, x(samples_temp.passive), 'bo'); hold on;
    plot(template,'r')
    figure()
    plot(r)
    disp(file)
    disp(['active: ', num2str(length(samples_temp.active))])
    disp(['passive: ', num2str(length(samples_temp.passive))])
end

%% ThresholdingAlgo
% Peak detection in the rising flank of pulse close to the start.
% Uses an moving average and deviation to prepare data. Then thresholding
% the peaks using x*deviation. Active and Passive can be discriminated.

cutrec = 0.1*fs; % = 100 ms in samples
xx = x;
%xx(end-cutrec:end) = [];
lag = 40;
th_tha = 10; % in x times std
influence = 0.5;
[signals,avgFilter,stdFilter] = ThresholdingAlgo(xx,lag,th_tha,influence, 'median');
peaks = diff(signals);


% Find Peaks in diff(signal) and take the first one in time
p = find(abs(peaks) == 1);
p = [0 ;p];
dummy = diff(p);
locs_tha = p(find(dummy>50)+1);

% Active or Passive?
id_a = peaks(locs_tha) > 0;
id_p = peaks(locs_tha) < 0;
samples_tha.active = locs_tha(id_a);
samples_tha.passive = locs_tha(id_p);

% Plot
if show_plot
    figure()
    plot(xx, 'k'); hold on; 
    plot(samples_tha.active, xx(samples_tha.active), 'ro'); hold on;
    plot(samples_tha.passive, xx(samples_tha.passive), 'bo')
    figure()
    plot(xx, 'k'); hold on; plot(avgFilter, 'r'); hold on;
    plot(avgFilter+stdFilter, 'r--'); hold on; plot(avgFilter-stdFilter, 'r--');
    hold on; plot(signals, 'g'); hold on; plot(diff(signals), 'b--')
    disp(['pulses: ', num2str(length(locs_tha))])
end

%% Automatic Multiscale-based Peak Detection
% The AMPD needs no parameters but finds all the peaks in the recording. To
% sort out the import peaks two additional parameters are needed.
% Takes much longer to compute than all the other methods.
clc
cutrec = 0.1*fs; % = 100 ms in samples
xx = x;
%xx(end-cutrec:end) = [];
sg = downsample(xx,4);
peaks_pos = ampd(sg);
peaks_neg = ampd(-sg);
plot(sg); hold on; plot(peaks_pos(2:end), sg(peaks_pos(2:end)),'ro')

%% Look for the first peak and remove all the others
th_ampd = 0.0035;%2*mad(sg);
th_diff = 100;

% Delete all peaks that are smaller than threshold:
peaks_pos(sg(peaks_pos) < th_ampd) = [];
peaks_neg(sg(peaks_neg) > -th_ampd) = [];
pp_backup_pos = peaks_pos;
pp_backup_neg = peaks_neg;
peaks_pos = [0, peaks_pos];
peaks_neg = [0, peaks_neg];

% Find the first peak of the remaining peaks:
pp_diff_pos = diff(peaks_pos);
pp_diff_neg = diff(peaks_neg);
locs_ampd_pos = peaks_pos(find(pp_diff_pos>th_diff)+1);
locs_ampd_neg = peaks_neg(find(pp_diff_neg>th_diff)+1);

% Acitve or Passive?
if length(locs_ampd_pos) == length(locs_ampd_neg)
    avsp = locs_ampd_pos - locs_ampd_neg;
    samples.active = locs_ampd_pos(avsp < 0);
    samples.passive = locs_ampd_neg(avsp > 0);
else
    disp('pos and neg pulse number not the same!')
    samples.active = [];
    samples.passive = [];
end
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
    disp(['active: ', num2str(length(samples.active))])
    disp(['passive: ', num2str(length(samples.passive))])
end
