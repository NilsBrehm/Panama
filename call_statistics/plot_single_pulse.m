%% Load Data
samplingrate = 480 * 1000;
sig1 = data(start1.DataIndex:end1.DataIndex);
sig2 = data(start2.DataIndex:end2.DataIndex);

%% No Filter:
pulsA = sig1;
pulsP = sig2;

%% Filter
% High Pass Filter
fc = 1000; % Cut off frequency
fs = 480*1000; % Sampling rate
[b,a] = butter(2,fc/(fs/2),'high'); % Butterworth filter of order x
pulsA = filter(b, a, sig1); % Will be the filtered signal
pulsP = filter(b, a, sig2); % Will be the filtered signal

% Low Pass Filter
fc = 150 * 1000; % Cut off frequency
fs = 480*1000; % Sampling rate
[b,a] = butter(2,fc/(fs/2),'low'); % Butterworth filter of order x
pulsA = filter(b, a, pulsA); % Will be the filtered signal
pulsP = filter(b, a, pulsP); % Will be the filtered signal

%%
% pulsA = pulses.active(:,10);
% pulsP = pulses.passive(:,3);


tA = 0:1/samplingrate:length(pulsA)/samplingrate;
tA(end) = [];
tP = 0:1/samplingrate:length(pulsP)/samplingrate;
tP(end) = [];

pos_fig = [500 500 800 600];
fig = figure();
set(fig, 'Color', 'white','position', pos_fig)
subplot(2,1,1)
plot(tA*1000, pulsA, 'k', 'LineWidth',2)
% xlabel('Zeit [ms]')
ylabel('Amplitude')
set(gca, 'FontSize', 16)
box off
xlim([0, 6])

subplot(2,1,2)
plot(tP*1000, pulsP, 'k', 'LineWidth',2)
set(gca, 'FontSize', 16)
xlabel('Time [ms]', 'FontSize', 16)
ylabel('Amplitude', 'FontSize', 16)
box off
xlim([0, 6])

%% Save to HDD
export_fig('D:\Masterarbeit\PanamaProject\Seminar\figs\Erdbeerglas\DeckelOhneGlas_Unterseite_25.png', '-r300', '-q101')
close
%% Save Data
save('D:\Masterarbeit\PanamaProject\Seminar\figs\Erdbeerglas\DeckelOhneGlas__Unterseite_25.mat')


%% Spectrogram
% Parameters
window_size = 100; % the larger the better the spectral res (temp res goes down)
window = hann(window_size);
noverlap = window_size-5;
nfft = 512;
pos_fig = [500 500 200 600];

% Plot
fig = figure();
set(fig, 'Color', 'white', 'position', pos_fig)
spectrogram(pulsA, window, noverlap, nfft, samplingrate, 'yaxis')
% xlim([0, t(end)*1000])
ylim([0 100])
cl = colorbar('xlim', [-110 -40]);
cl.Label.String = '[dB/Hz]';
caxis([-90 -50]) % Use this to adjust coloring of spectral plot
colormap(c)
box off
ylabel('Frequency [kHz]')

%%