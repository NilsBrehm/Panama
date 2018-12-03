fs = 100*1000;
x = bandpassfilter_data(volt, 100, 6000, 4, fs, true, true);

% NonLinear Energy Operator
% http://gaidi.ca/weblog/extracting-spikes-from-neural-electrophysiology-in-matlab
neo = zeros(length(x),1);
for n = 2:1:length(x)-1
    neo(n) = x(n).^2 - x(n+1)*x(n-1);
end

plot(x, 'k')
hold on
plot(neo, 'r')

%% Normalised cumulative energy difference
% Nhamoinesu Mtetwa and Leslie S. Smith - Smoothing and thresholding in
% neuronal spike detection (2006)
energy = sum(x.^2);
nce = cumsum(x.^2)/energy;
nced = diff(nce);
plot(x*mean(nced), 'k')
hold on
plot(nced, 'r')

%%
sg = downsample(neo, 1);
peaks_pos = ampd(sg);
plot(sg); hold on; plot(peaks_pos, sg(peaks_pos),'ro')

%% Smoothing and Spike Detection
clc
temp = volt(a1.DataIndex:a2.DataIndex);
fs = 100*1000;
x = bandpassfilter_data(volt, 300, 4000, 2, fs, true, true);

% Convolution
c = conv(x,-temp, 'same');

% Sum of Squared Difference
ssd = conv2(x,rot90(temp,2),'same');

% Spike Detection
th = 2*(mad(x));
th_c = 2*(mad(c));
th_ssd = 2*(mad(ssd));
mpd = 100;
[st, ~] = peakseek(x, mpd, th);
%st = st/fs;
[st_c, ~] = peakseek(c, mpd, th_c);
%st_c = st_c/fs;
[st_ssd, ~] = peakseek(ssd, mpd, th_ssd);
%st_ssd = st_ssd/fs;

% Plot
t = 0:1/fs:length(x)/fs;
t(end) = [];
%t = t*1000;

ha(1) = subplot(4,1,1);
plot(t, volt, 'k')
title('Original')

ha(2) = subplot(4,1,2);
plot(t, x, 'k'); hold on;
plot([0, t(end)], [th, th], 'r--'); hold on;
plot(st/fs, x(st), 'ro')
for k=1:length(st)
    hold on
    plot([st(k)/fs, st(k)/fs], [min(x), max(x)], 'r--')
end
title(['Filtered Data: ', num2str(length(st)), ' spikes'])

ha(3) = subplot(4,1,3);
plot(t, c, 'k'); hold on;
plot([0, t(end)], [th_c, th_c], 'r--'); hold on;
plot(st_c/fs, c(st_c), 'ro')
for k=1:length(st_c)
    hold on
    plot([st_c(k)/fs, st_c(k)/fs], [min(c), max(c)], 'r--')
end
title(['Conv: ', num2str(length(st_c)), ' spikes'])

ha(4) = subplot(4,1,4);
plot(t, ssd, 'k'); hold on;
plot([0, t(end)], [th_ssd, th_ssd], 'r--'); hold on;
plot(st_ssd/fs, ssd(st_ssd), 'ro')
for k=1:length(st_ssd)
    hold on
    plot([st_ssd(k)/fs, st_ssd(k)/fs], [min(ssd), max(ssd)], 'r--')
end
title(['SSD: ', num2str(length(st_ssd)), ' spikes'])
xlabel('time [s]')
linkaxes(ha, 'x'); 