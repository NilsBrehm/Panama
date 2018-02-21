% add zeros
data = [zeros(200, 1); data];

%% Compute Spectrogram
window_size = 50; % the larger the better the spectral res (temp res goes down)
window = hann(window_size);
noverlap = window_size-5;
nfft = 512;
[s ,f , t] = spectrogram(data, window, noverlap, nfft, fs, 'yaxis');

%% Get frequency with max. power
m = abs(s);
aa = zeros(length(m), 1);
for i = 1:length(m)
    if sum(m(:,i)) > 0
        aa(i) = mean(find(m(:,i) == max(m(:,i))));
    else
        aa(i) = 20;
    end
end
aa(aa<20) = 20;

%% Get power values over time at frequency fx
fx = find(mean(m,2) == max(mean(m,2)));
fx = 25;
fx = aa;
if length(fx) > 2
    for k = 1:length(m)
        n(k) = m(fx(k),k);
    end
else
    n = m(fx,:);
end
ndt = diff(n)*max(n);


% Plot power values and derivative
figure()
imagesc(m>0.1)
%hold on
%plot([1, length(m)], [fx fx], 'r')
%hold on
%plot(fx,'g')

figure()
plot(n, 'k')
hold on
plot(ndt, 'r')

%% Find peaks in power values or derivative and locate pulse position
clc
mph = .5;
mpd = 20;
[peaks_value, peaks_loc] = findpeaks(n, 'MinPeakHeight', mph, 'MinPeakDistance', mpd);
factor = window_size - noverlap;
peaks_loc = peaks_loc * factor;
plot(data, 'k')
hold on
plot(peaks_loc, data(peaks_loc), 'ro')
disp(['pulses: ', num2str(length(peaks_loc))])
disp(file)
