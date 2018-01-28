function [pulse_locations, pulse_times, samples, r, lags, template] = TemplatePeaks(data,samplingrate, pulse_length, frequency, tau, mph, mpd, template)
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

%% Model Template (damped sinus)
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

% Next thing to do is to detect the peaks of the correlation fucntion using
% the matlab function 'findpeaks()'. After this we need to get back the
% correct time points for the pulses (correlation function peaks) since the
% function is sampled in lags.

% Use this two parameters to optimize peak detection
% mph = .2; % Min Peak Heigth
% mpd = 150; % Min Peak Distance
[~ ,locs] = findpeaks(r, 'MinPeakHeight', mph, 'MinPeakDistance', mpd);

% Get the starting point of pulses in sanmples
pulse_locations = lags(locs);
pulse_times = pulse_locations / samplingrate;
samples.active = [];
samples.passive = [];

% Active or Passive?
for k = 1:length(pulse_locations)
    pulse = data(pulse_locations(k)-50:pulse_locations(k)+50);
    for i = 1:length(pulse) 
        if 2*std(pulse(1:i+10)) > std(pulse(i+10:end))
            peak = i;
            break;
        end
    end
    if mean(pulse(peak:peak+2)) > 0
        samples.active = [samples.active, pulse_locations(k)];
    else
        samples.passive = [samples.passive, pulse_locations(k)];
    end
end
% pulsepeak = 10;
% y = pulse(1:pulsepeak);
% x = 1:length(y);
% P = polyfit(x',y,1);
% yfit = P(1)*x+P(2);
% plot(x,yfit);hold on;plot(y)





% % Difference beteween new and old method
% % Template Method aligns at start of pulse not at first peak!
% old_samples = [samples.active, samples.passive];
% disp(['New Method: Pulses found = ', num2str(length(pulse_locations))])
% disp(['Old Method: Pulses found = ', num2str(length(old_samples))])
% if length(pulse_locations) == length(old_samples)
%     dd = pulse_locations - old_samples;
%     disp(['Difference between old and new method (in samples): ', num2str(dd)])
% end

end
