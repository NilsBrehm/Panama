function [peaks, peaks_diff, samples] = find_peaks_env(data, varargin)
% This function uses the envelope (RMS and Analytic) to find pulses. To
% find the uprising flank of the pulse the derivative of the envelope is
% taken. The resulting peaks are found using the findpeaks() function.
%
% Copyright Nils Brehm 2018

% only want 3 optional inputs at most
numvarargs = length(varargin);
if numvarargs > 4
    error('find_peaks_env:TooManyInputs', ...
        'requires at most 3 optional inputs');
end

% set defaults for optional inputs
optargs = {20 'analytic' 20 false};

% now put these defaults into the valuesToUse cell array,
% and overwrite the ones specified in varargin.
optargs(1:numvarargs) = varargin;

% Place optional args in variables
[mpd, method, window, show_plot] = optargs{:};

% Compute Envelope and Find peak position in samples
if strcmp(method, 'rms')
    env = envelope(data , window, method);
    env = movmean(env, 10);
    env_diff = diff(env);
    [~, peaks] = findpeaks(env, 'MinPeakHeight', 2*rms(data), 'MinPeakDistance', mpd);
    [~, peaks_diff] = findpeaks(env_diff, 'MinPeakHeight', 2*rms(env_diff), 'MinPeakDistance', mpd);
    
elseif strcmp(method, 'analytic')
    env = envelope(data , window*10, method);
    env = movmean(env, 10);
    env_diff = diff(env);
    [~, peaks] = findpeaks(env, 'MinPeakHeight', max(data)/2, 'MinPeakDistance', 2*mpd);
    [~, peaks_diff] = findpeaks(env_diff, 'MinPeakHeight', max(env_diff)/2, 'MinPeakDistance', 2*mpd);
else
    error('find_peaks_env:IncorrectMethod', ...
        'Valid methods: "raw" and "analytic"');
end

if show_plot
    figure()
    plot(data, 'k')
    hold on
    plot(env, 'b')
    hold on
    plot(env_diff, 'r')
    hold on
    plot(peaks, data(peaks), 'bo', 'MarkerSize', 10)
    hold on
    plot(peaks_diff, data(peaks_diff), 'ro', 'MarkerSize', 10)
    hold on
    for k = 1:length(peaks_diff)
        x = peaks_diff(k):1:peaks_diff(k)+5;
        plot(x, data(x), 'g')
        hold on
    end
    hold off
end
%legend('data', 'env', 'env dt', 'peaks env', 'peaks env dt')

% Active or Passive?
samples.active = [];
samples.passive = [];

for i = 1:length(peaks)
    cond1 = data(peaks(i)) > 0;
    x = peaks_diff(i):1:peaks_diff(i)+5;
    cond2 = mean(data(x)) > 0;
    
    if cond2 && cond1
        disp(['Pulse ', num2str(i), ' is active'])
        samples.active = [samples.active, peaks_diff(i)];
    elseif ~cond2 && ~cond2
        disp(['Pulse ', num2str(i), ' is passive'])
        samples.passive = [samples.passive, peaks_diff(i)];
    elseif cond2 && ~cond1
        disp(['Pulse ', num2str(i), ' is active (with warning)'])
        samples.active = [samples.active, peaks_diff(i)];
    elseif ~cond2 && cond1
        disp(['Pulse ', num2str(i), ' is passive (with warning)'])
        samples.passive = [samples.passive, peaks_diff(i)];
    else
        disp(['Pulse ', num2str(i), ' is undecidable'])
    end
end
end