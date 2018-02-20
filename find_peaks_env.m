function [peaksRMS, peaksENV, peaksRMS_diff, peaksENV_diff] = find_peaks_env(data, mpd)
% This function uses the envelope (RMS and Analytic) to find pulses. To
% find the uprising flank of the pulse the derivative of the envelope is
% taken. The resulting peaks are found using the findpeaks() function.
% 
% Copyright Nils Brehm 2018

env = envelope(data , 200, 'analytic');
env = movmean(env, 10);
r = envelope(data , 20, 'rms');
r = movmean(r, 10);
env_diff = diff(env);
r_diff = diff(r);

% Find peak position in samples
[~, peaksRMS] = findpeaks(r, 'MinPeakHeight', 2*rms(data), 'MinPeakDistance', mpd);
[~, peaksENV] = findpeaks(env, 'MinPeakHeight', max(data)/2, 'MinPeakDistance', 2*mpd);

[~, peaksENV_diff] = findpeaks(env_diff, 'MinPeakHeight', max(env_diff)/2, 'MinPeakDistance', 2*mpd);
[~, peaksRMS_diff] = findpeaks(r_diff, 'MinPeakHeight', 2*rms(r_diff), 'MinPeakDistance', mpd);

plot(data, 'k')
hold on
plot(env, 'b')
hold on
plot(r, 'r')
hold on
plot(peaksRMS_diff, data(peaksRMS_diff), 'ro', 'MarkerSize', 10)
hold on
plot(peaksENV_diff, data(peaksENV_diff), 'bo', 'MarkerSize', 10)

end