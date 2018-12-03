function locs = find_peaks_spec(data, fs, mpd, th, show_plot)
% Compute Spectrogram
window_size = 50; % the larger the better the spectral res (temp res goes down)
window = hann(window_size);
noverlap = window_size-5;
nfft = 512;
s = spectrogram(data, window, noverlap, nfft, fs, 'yaxis');

% Get frequency with max. power
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

% Get power values over time at frequency fx
% fx = find(mean(m,2) == max(mean(m,2)));
% fx = 25;
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
if show_plot
    figure()
    imagesc(m>0.1)
    hold on
    plot(fx,'g')
    
    figure()
    plot(n, 'k')
    hold on
    plot(ndt, 'r')
end
% Find peaks in power values or derivative and locate pulse position
mph = th*mad(n);
%[peaks_value, peaks_loc] = findpeaks(n, 'MinPeakHeight', mph, 'MinPeakDistance', mpd);
[locs, ~] = peakseek(n, mpd, mph);
factor = window_size - noverlap;
%peaks_loc = peaks_loc * factor;
locs = locs * factor;
if show_plot
    figure()
    plot(data, 'k')
    hold on
    plot(locs, data(locs), 'ro')
end
end
