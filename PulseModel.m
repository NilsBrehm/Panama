%% MOTH PULSE MODEL (artificial moth pulses)
% This script computes an artifical moth pulse based on a damped sinus
% model.

% Constants
samplingrate = 480 * 1000; % sampling rate in Hz
pulse_length = 0.4;
frequency = 50;
tau = 0.1;
t = 0:1/samplingrate:pulse_length/1000; % pulse length = 0.4 ms
amp = 1;
f = frequency*1000*2*pi; % 2*pi*Hz for pulse to have freq = Hz
dumping = tau/1000; % tau in seconds (0.1 ms)
xshift = 0; % no shift

% pulse = artifical_moth(t,amp,f, dumping, xshift);
% plot(t*1000, pulse)

%% Compute pulse
pulse = 0;
frequency = [25, 60];
w = [.05, .6];
for i = 1:length(frequency)
    f = frequency(i)*1000*2*pi;
    pulse = pulse + artifical_moth(t,w(i)*amp,f, dumping, xshift);
end

%% Plot Model vs Data
tO = 0:1/samplingrate:length(pulseO)/samplingrate;
subplot(2,1,1)
plot(t*1000, pulse, 'k', 'LineWidth', 3)
xlabel('Zeit [ms]')
ylabel('Amplitude')
ylim([-1, 1])
yticks(-1:.5:1)
xlim([0, .2])
xticks(0:.05:.2)
set(gca, 'xlabel', [], 'xticklabel', [])
box off

subplot(2,1,2)
plot(tO(1:end-1)*1000, pulseO, 'k', 'LineWidth', 3)
xlabel('Zeit [ms]')
ylabel('Amplitude')
ylim([-1, 1])
yticks(-1:.5:1)
xlim([0, .2])
xticks(0:.05:.2)
box off

%% Spectrogram
figure()
window_size = 80; % the larger the better the spectral res (temp res goes down)
window = hann(window_size);
%noverlap = round(window_size*0.75);
noverlap = window_size-5;
nfft = 512;
spectrogram(pulseO, window, noverlap, nfft, samplingrate, 'yaxis')
ylim([50 150])
cl = colorbar('xlim', [-110 -40], 'Fontsize',10');
cl.Label.String = '[dB/Hz]';
% caxis([-100 -45])
caxis([-100 -50]) % Use this to adjust coloring of spectrak plot
% colorbar off
colormap(c)
box off
% xlim([100, 300])