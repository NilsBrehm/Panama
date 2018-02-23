function [pulse_locations, samples, r, lags, template] = TemplatePeaks(data,samplingrate, pulse_length, frequency, tau, mph, mpd, template, moth)
% The idea here ist to use a template pulse, eihter cuting out one of the
% pulses in the recording or using a model template pulse (damped sinus),
% to find the active and passive pulses in a recording. The template is
% cross correlated with the data in the recording returning a cross
% correlation function. The peaks of this function indicate the temporal
% position of the pulses.
%
% INPUT:
% data: moth recording
% samplingrate: sampling rate of data recording in kHz
% pulse_length: template pulse lenth in ms
% frequency: template pulse frequency in kHz
% tau: time constant of damped sinus in ms
% mph: min. peak heigth (parameter of findpeaks())
% mpd: min. peak distance (parameter of findpeaks())
%
% OUTPUT:
% pulse_locations: Starting Points of pulses in samples
% pulse_times: Starting Points of pulses in time (seconds)
%
% Copyright Nils Brehm 2018

%% TEMPLATE SECTION =======================================================
% % Get data template and call it 'temp'
% plot(data)
% % Get data template pulse
% template = temp(:,2);

% Model Template (damped sinus)
samplingrate = samplingrate * 1000; % sampling rate in Hz
t = 0:1/samplingrate:pulse_length/1000; % pulse length = 0.4 ms
amp = round(max(data), 1);
f = frequency*1000*2*pi; % 2*pi*Hz for pulse to have freq = Hz
dumping = tau/1000; % tau in seconds (0.1 ms)
xshift = 0; % no shift
if template == 0
    template = artifical_moth(t,amp,f, dumping, xshift);
end
% =========================================================================
% CROSS CORRELATION SECTION===============================================
% Compute cross correlation between data and template pulse
[r, lags] = xcorr(data, template);
[r2, lags2] = xcorr(data, -template);
[p ,locs] = findpeaks(r, 'MinPeakHeight', mph, 'MinPeakDistance', mpd);
[p2 ,locs2] = findpeaks(r2, 'MinPeakHeight', mph, 'MinPeakDistance', mpd);

% Active or Passive?
if moth
    id_a = p > p2;
    id_p = p < p2;
    aa = locs(id_a);
    pp = locs2(id_p);
    
    % Get the starting point of pulses in sanmples
    pulse_locations = lags(locs);
    samples.active = lags(aa);
    samples.passive = lags2(pp);
else
    pulse_locations = lags(locs);
    samples.active = [];
    samples.passive = [];
end
end
