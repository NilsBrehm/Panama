%% Comparison of Spectral Paramters of single pulses
% Based on Magnitude-squared coherence.
% 
% Copyright Nils Brehm 2018

%% High Pass Filter
fc = 5000; % Cut off frequency
fs = 480*1000; % Sampling rate

% sig1 = pulses.active(:,10);
% sig2 = pulses.passive(:,3);
% % Backup
% sig1_backup = sig1;
% sig2_backup = sig2;

[b,a] = butter(4,fc/(fs/2),'high'); % Butterworth filter of order x
% sig1 = filter(b, a, sig1); % Will be the filtered signal
% sig2 = filter(b, a, sig2); % Will be the filtered signal

data = filter(b, a, data);

%% Low Pass Filter
fc = 150 * 1000; % Cut off frequency
fs = 480*1000; % Sampling rate

[b,a] = butter(4,fc/(fs/2),'low'); % Butterworth filter of order x
% sig1 = filter(b, a, sig1); % Will be the filtered signal
% sig2 = filter(b, a, sig2); % Will be the filtered signal

data = filter(b, a, data);

%% Plot Difference between original and filtered data
plot(sig1_backup, 'k'); hold on; plot(sig1, 'r'); hold on; plot([1, length(sig1)], [0, 0], 'k', 'LineWidth', 2)
%plot(data2, 'k'); hold on; plot(data, 'r'); hold on; plot([1, length(data2)], [0, 0], 'k', 'LineWidth', 2)

%%
Fs = 480 * 1000;         % Sampling Rate

% Spectral content
[P1,f1] = periodogram(sig1,[],[],Fs,'power');
[P2,f2] = periodogram(sig2,[],[],Fs,'power');

% Spectrogram Parameters
window_size = ceil(length(sig1)*0.2); % the larger the better the spectral res (temp res goes down)
window = hann(window_size);
noverlap = window_size-5;
nfft = 2048;

% Plot Time Signal, Power Spectrum and Spectrogram
pos_fig = [500 500 1000 600];
fig = figure();
set(fig, 'Color', 'white', 'position', pos_fig)
t1 = (0:numel(sig1)-1)/Fs;
t2 = (0:numel(sig2)-1)/Fs;

subplot(2,3,1)
plot(t1*1000,sig1,'k', 'LineWidth', 2)
ylabel('Amplitude')
grid on
title('Time Signal')
% xticks(0:.1:.5)

subplot(2,3,4)
plot(t2*1000,sig2, 'k', 'LineWidth', 2)
ylabel('Amplitude')
grid on
xlabel('Time [ms]')
% xticks(0:.1:.5)

subplot(2,3,2)
plot(f1/1000,P1,'k', 'LineWidth', 2)
ylabel('Power')
grid on
axis tight
title('Power Spectrum')
xticks(0:2:10)
xlim([0 10])

subplot(2,3,5)
plot(f2/1000,P2, 'k', 'LineWidth', 2)
ylabel('Power')
grid on
axis tight
xlabel('Frequeny (kHz)')
xticks(0:2:10)
xlim([0 10])


subplot(2,3,3)
spectrogram(sig1, window, noverlap, nfft, samplingrate, 'yaxis')
ylim([0 10])
cl = colorbar('xlim', [-110 -40], 'Fontsize',10');
cl.Label.String = '[dB/Hz]';
caxis([-100 -35]) % Use this to adjust coloring of spectrak plot
colormap(c)
box off
set(gca,'xtick',[], 'xlabel', [])
% xticks(0:100:300)
title('Spectrogram')

subplot(2,3,6)
spectrogram(sig2, window, noverlap, nfft, samplingrate, 'yaxis')
ylim([0 10])
cl = colorbar('xlim', [-110 -40], 'Fontsize',10');
cl.Label.String = '[dB/Hz]';
caxis([-100 -35]) % Use this to adjust coloring of spectrak plot
colormap(c)
box off
set(gca,'xtick',[], 'xlabel', [])
% xticks(0:100:300)
xlabel('Time [\mus]')

%%
export_fig('D:\Masterarbeit\PanamaProject\Seminar\figs\Erdbeerglas\DOG_overview.png', '-r300', '-q101')
close

%% Plot Spectral Coherence and Phase
[Cxy,f] = mscohere(sig1,sig2,[],[],[],Fs);
Pxy     = cpsd(sig1,sig2,[],[],[],Fs);
phase   = -angle(Pxy)/pi*180;
[pks,locs] = findpeaks(Cxy,'MinPeakHeight',0.6);

figure()
subplot(2,1,1)
plot(f/1000,Cxy)
title('Coherence Estimate')
ylabel('Spectral Coherence')
xlim([0, 150])
subplot(2,1,2)
plot(f/1000,phase)
title('Cross Spectrum Phase (deg)')
xlabel('Frequency (kHz)')
ylabel('Phase (deg)')
xlim([0, 150])

%% Spectrogram
pos_fig = [500 500 200 500];
figure()
set(gcf, 'Color', 'white', 'position', pos_fig)
window_size = ceil(length(sig1)*0.5); % the larger the better the spectral res (temp res goes down)
window = hann(window_size);
%noverlap = round(window_size*0.75);
noverlap = window_size-5;
nfft = 512;
spectrogram(sig1, window, noverlap, nfft, samplingrate, 'yaxis')
ylim([0 150])
cl = colorbar('xlim', [-110 -40], 'Fontsize',10');
cl.Label.String = '[dB/Hz]';
caxis([-95 -55]) % Use this to adjust coloring of spectrak plot
% colorbar off
colormap(c)
box off
% xlim([100, 300])
